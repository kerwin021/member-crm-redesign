#!/usr/bin/env python3
import json
import os
from datetime import date, datetime, timedelta
from decimal import Decimal
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlparse

import pymysql
from pymysql.cursors import DictCursor


ROOT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def load_env_file(path):
    if not os.path.exists(path):
        return
    with open(path, "r", encoding="utf-8") as handle:
        for raw_line in handle:
            line = raw_line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, value = line.split("=", 1)
            key = key.strip()
            value = value.strip().strip('"').strip("'")
            os.environ.setdefault(key, value)


load_env_file(os.path.join(ROOT_DIR, ".env"))
load_env_file(os.path.join(ROOT_DIR, "server", ".env"))


def env(name, default=None):
    return os.environ.get(name, default)


def db_config():
    return {
        "host": env("MYSQL_HOST", env("DB_HOST", "127.0.0.1")),
        "port": int(env("MYSQL_PORT", env("DB_PORT", "3306"))),
        "user": env("MYSQL_USER", env("DB_USER", "crm")),
        "password": env("MYSQL_PASSWORD", env("DB_PASSWORD", "")),
        "database": env("MYSQL_DATABASE", env("DB_NAME", "crm")),
        "charset": "utf8mb4",
        "cursorclass": DictCursor,
        "autocommit": True,
        "connect_timeout": int(env("MYSQL_CONNECT_TIMEOUT", "6")),
        "read_timeout": int(env("MYSQL_READ_TIMEOUT", "12")),
        "write_timeout": int(env("MYSQL_WRITE_TIMEOUT", "12")),
    }


def get_connection():
    config = db_config()
    if not config["password"]:
        raise RuntimeError("MYSQL_PASSWORD is not configured")
    return pymysql.connect(**config)


def json_default(value):
    if isinstance(value, Decimal):
        return float(value)
    if isinstance(value, (datetime, date)):
        return value.isoformat()
    return str(value)


def as_int(value):
    return int(value or 0)


def as_float(value):
    return float(value or 0)


def format_number(value):
    return f"{as_int(value):,}"


def format_money(value):
    return f"¥{as_float(value):,.0f}"


def format_money_exact(value):
    return f"¥{as_float(value):,.2f}"


def format_plain_money(value):
    return f"{as_float(value):,.0f} 元"


def format_dt(value, fmt="%Y-%m-%d %H:%M"):
    if not value:
        return ""
    if isinstance(value, str):
        return value[:16]
    return value.strftime(fmt)


def format_date(value):
    if not value:
        return ""
    if isinstance(value, str):
        return value[:10]
    return value.strftime("%Y-%m-%d")


def parse_date_value(value):
    if not value or isinstance(value, date):
        return value
    return datetime.strptime(str(value)[:10], "%Y-%m-%d").date()


def format_day(value):
    if not value:
        return ""
    if isinstance(value, str):
        return value[5:10].replace("-", "-")
    return value.strftime("%m-%d")


def query_all(conn, sql, params=()):
    with conn.cursor() as cursor:
        cursor.execute(sql, params)
        return list(cursor.fetchall())


def query_one(conn, sql, params=()):
    rows = query_all(conn, sql, params)
    return rows[0] if rows else None


def ratio(value, total):
    if not total:
        return "0.00%"
    return f"{as_int(value) * 100 / as_int(total):.2f}%"


def percent_value(value, total):
    return round(as_int(value) * 100 / as_int(total), 2) if total else 0


def percent_rows(rows, name_key="name", total_key="total", total=0):
    return [{"name": row[name_key], "value": percent_value(row[total_key], total)} for row in rows]


def trend_rows(conn, tenant_id, days):
    rows = query_all(
        conn,
        """
        SELECT DATE(register_at) AS day_value, COUNT(*) AS member_count
        FROM crm_members
        WHERE tenant_id = %s
          AND register_at >= DATE_SUB((SELECT MAX(register_at) FROM crm_members WHERE tenant_id = %s), INTERVAL %s DAY)
        GROUP BY DATE(register_at)
        ORDER BY DATE(register_at)
        """,
        (tenant_id, tenant_id, days),
    )
    result = []
    previous = None
    for row in rows:
        count = as_int(row["member_count"])
        rate = 0 if previous in (None, 0) else round((count - previous) * 100 / previous, 2)
        result.append({"day": format_day(row["day_value"]), "members": count, "rate": rate})
        previous = count
    return result


LEVEL_COLORS = {
    "普通卡": "#2869f6",
    "银卡": "#11bfa8",
    "金卡": "#f6a817",
    "白金卡": "#f36f8e",
    "钻石卡": "#7b61e8",
}

COLOR_CYCLE = ["blue", "green", "orange", "purple", "teal", "pink"]


def status_label(value):
    return {
        "active": "活跃",
        "to_wake": "待唤醒",
        "frozen": "冻结",
        "disabled": "停用",
    }.get(value or "", value or "未知")


def order_status_label(value):
    return {
        "pending_payment": "待付款",
        "pending_ship": "待发货",
        "shipping": "配送中",
        "completed": "已完成",
        "refunding": "退款中",
        "cancelled": "已取消",
    }.get(value or "", value or "未知")


def segment_type_label(value):
    return {
        "dynamic": "动态分群",
        "static": "静态分群",
        "system": "系统分群",
    }.get(value or "", value or "动态分群")


def conversation_type_label(value):
    return {
        "chat": "聊天",
        "group": "群聊",
        "official": "公众号",
    }.get(value or "", value or "聊天")


def gender_label(value):
    return {
        "male": "男",
        "female": "女",
        "unknown": "未知",
    }.get(value or "unknown", value or "未知")


def load_app_data():
    with get_connection() as conn:
        tenant_code = env("APP_TENANT_CODE", "ym-foods")
        tenant = query_one(conn, "SELECT id, code, name, brand_name FROM app_tenants WHERE code = %s LIMIT 1", (tenant_code,))
        if not tenant:
            raise RuntimeError(f"Tenant not found: {tenant_code}")
        tenant_id = tenant["id"]

        total_members = as_int(query_one(conn, "SELECT COUNT(*) AS total FROM crm_members WHERE tenant_id = %s", (tenant_id,))["total"])
        max_register = parse_date_value(query_one(conn, "SELECT MAX(DATE(register_at)) AS max_day FROM crm_members WHERE tenant_id = %s", (tenant_id,))["max_day"])
        latest_day_new = 0
        month_new = 0
        quarter_new = 0
        if max_register:
            latest_day_new = as_int(query_one(conn, "SELECT COUNT(*) AS total FROM crm_members WHERE tenant_id = %s AND DATE(register_at) = %s", (tenant_id, max_register))["total"])
            month_start = date(max_register.year, max_register.month, 1)
            quarter_month = ((max_register.month - 1) // 3) * 3 + 1
            quarter_start = date(max_register.year, quarter_month, 1)
            month_new = as_int(query_one(conn, "SELECT COUNT(*) AS total FROM crm_members WHERE tenant_id = %s AND register_at >= %s", (tenant_id, month_start))["total"])
            quarter_new = as_int(query_one(conn, "SELECT COUNT(*) AS total FROM crm_members WHERE tenant_id = %s AND register_at >= %s", (tenant_id, quarter_start))["total"])

        level_rows_raw = query_all(
            conn,
            """
            SELECT l.name, COUNT(m.id) AS value
            FROM loyalty_membership_levels l
            LEFT JOIN crm_members m ON m.level_id = l.id AND m.tenant_id = l.tenant_id
            WHERE l.tenant_id = %s
            GROUP BY l.id, l.name, l.level_rank
            ORDER BY l.level_rank
            """,
            (tenant_id,),
        )
        level_rows = [
            {
                "name": row["name"],
                "value": as_int(row["value"]),
                "color": LEVEL_COLORS.get(row["name"], "#2869f6"),
                "ratio": ratio(row["value"], total_members),
            }
            for row in level_rows_raw
        ]

        source_raw = query_all(
            conn,
            """
            SELECT source_channel, COUNT(*) AS total
            FROM crm_members
            WHERE tenant_id = %s
            GROUP BY source_channel
            ORDER BY total DESC, source_channel
            """,
            (tenant_id,),
        )
        source_rows = [
            [row["source_channel"], format_number(row["total"]), round(as_int(row["total"]) * 100 / total_members, 2) if total_members else 0, COLOR_CYCLE[index % len(COLOR_CYCLE)]]
            for index, row in enumerate(source_raw)
        ]
        platform_rows = [
            {"name": row["source_channel"], "value": percent_value(row["total"], total_members)}
            for row in source_raw
        ]

        portrait_raw = query_all(
            conn,
            """
            SELECT COALESCE(JSON_UNQUOTE(JSON_EXTRACT(profile_json, '$.age_band')), '未知') AS age_band, COUNT(*) AS total
            FROM crm_members
            WHERE tenant_id = %s
            GROUP BY age_band
            ORDER BY age_band
            """,
            (tenant_id,),
        )
        portrait_bars = [{"name": row["age_band"], "value": round(as_int(row["total"]) * 100 / total_members, 2) if total_members else 0} for row in portrait_raw]
        gender_rows = [
            {"name": gender_label(row["gender_value"]), "value": percent_value(row["total"], total_members)}
            for row in query_all(
                conn,
                """
                SELECT COALESCE(gender, 'unknown') AS gender_value, COUNT(*) AS total
                FROM crm_members
                WHERE tenant_id = %s
                GROUP BY gender_value
                ORDER BY FIELD(gender_value, 'male', 'female', 'unknown')
                """,
                (tenant_id,),
            )
        ]
        active_rows = [
            {"name": row["active_label"], "value": percent_value(row["total"], total_members)}
            for row in query_all(
                conn,
                """
                SELECT CASE status
                         WHEN 'active' THEN '高活跃'
                         WHEN 'to_wake' THEN '低活跃'
                         WHEN 'frozen' THEN '冻结'
                         ELSE status
                       END AS active_label,
                       COUNT(*) AS total
                FROM crm_members
                WHERE tenant_id = %s
                GROUP BY active_label
                ORDER BY FIELD(active_label, '高活跃', '低活跃', '冻结')
                """,
                (tenant_id,),
            )
        ]
        value_rows = [
            {"name": row["value_label"], "value": percent_value(row["total"], total_members)}
            for row in query_all(
                conn,
                """
                SELECT CASE
                         WHEN COALESCE(mm.contribution_score, 0) >= 85 THEN '高价值'
                         WHEN COALESCE(mm.contribution_score, 0) >= 70 THEN '中价值'
                         ELSE '低价值'
                       END AS value_label,
                       COUNT(*) AS total
                FROM crm_members m
                LEFT JOIN crm_member_metrics mm ON mm.member_id = m.id
                WHERE m.tenant_id = %s
                GROUP BY value_label
                ORDER BY FIELD(value_label, '高价值', '中价值', '低价值')
                """,
                (tenant_id,),
            )
        ]
        city_rows = percent_rows(
            query_all(
                conn,
                """
                SELECT COALESCE(JSON_UNQUOTE(JSON_EXTRACT(profile_json, '$.city')), '未知') AS city, COUNT(*) AS total
                FROM crm_members
                WHERE tenant_id = %s
                GROUP BY city
                ORDER BY total DESC, city
                LIMIT 4
                """,
                (tenant_id,),
            ),
            "city",
            "total",
            total_members,
        )

        member_rows = query_all(
            conn,
            """
            SELECT
              m.member_no AS id,
              m.name,
              m.phone_mask AS phone,
              COALESCE(s.name, '-') AS store,
              COALESCE(l.name, '未分级') AS level,
              m.source_channel AS source,
              DATE(m.register_at) AS register_date,
              m.status,
              COALESCE(mm.total_spend, 0) AS total_spend,
              COALESCE(mm.order_count, 0) AS order_count,
              COALESCE(mm.contribution_score, 0) AS contribution_score,
              mm.last_order_at
            FROM crm_members m
            LEFT JOIN loyalty_membership_levels l ON l.id = m.level_id
            LEFT JOIN org_stores s ON s.id = m.register_store_id
            LEFT JOIN crm_member_metrics mm ON mm.member_id = m.id
            WHERE m.tenant_id = %s
            ORDER BY m.register_at DESC, m.id DESC
            LIMIT 100
            """,
            (tenant_id,),
        )
        members = [
            {
                "id": row["id"],
                "name": row["name"],
                "phone": row["phone"],
                "store": row["store"],
                "level": row["level"],
                "source": row["source"],
                "date": format_date(row["register_date"]),
                "status": status_label(row["status"]),
            }
            for row in member_rows
        ]
        high_value_members = [
            {
                "name": row["name"],
                "id": row["id"],
                "level": row["level"],
                "value": format_money(row["total_spend"]),
                "orders": as_int(row["order_count"]),
                "last": format_dt(row["last_order_at"]) or "暂无消费",
                "store": row["store"],
                "score": as_int(row["contribution_score"]),
                "trend": "+0.0%",
            }
            for row in sorted(member_rows, key=lambda item: as_int(item["contribution_score"]), reverse=True)
            if as_int(row["contribution_score"]) > 0
        ][:20]

        segments = [
            {
                "id": row["id"],
                "name": row["name"],
                "desc": row["description"] or "",
                "members": as_int(row["member_count"]),
                "type": segment_type_label(row["segment_type"]),
                "status": bool(row["enabled"]),
                "updated": format_dt(row["updated_at"], "%m-%d %H:%M") or "暂无更新",
                "color": COLOR_CYCLE[index % len(COLOR_CYCLE)],
            }
            for index, row in enumerate(
                query_all(
                    conn,
                    "SELECT id, name, description, member_count, segment_type, enabled, updated_at FROM crm_segments WHERE tenant_id = %s ORDER BY updated_at DESC, id DESC",
                    (tenant_id,),
                )
            )
        ]

        tags = [
            {
                "id": row["id"],
                "name": row["name"],
                "category": row["category"],
                "coverage": as_int(row["coverage_count"]),
                "rules": as_int(row["rules_count"]),
                "updated": format_dt(row["updated_at"], "%m-%d %H:%M") or "暂无更新",
                "color": row["color"] or COLOR_CYCLE[index % len(COLOR_CYCLE)],
                "enabled": bool(row["enabled"]),
            }
            for index, row in enumerate(
                query_all(
                    conn,
                    """
                    SELECT id, name, category, color, enabled, coverage_count,
                           COALESCE(JSON_LENGTH(rules_json), 0) AS rules_count,
                           updated_at
                    FROM crm_tags
                    WHERE tenant_id = %s
                    ORDER BY updated_at DESC, id DESC
                    """,
                    (tenant_id,),
                )
            )
        ]

        products = [
            {
                "id": row["product_no"],
                "name": row["name"],
                "category": row["category"],
                "price": as_float(row["price"]),
                "stock": as_int(row["stock_qty"]),
                "sales": as_int(row["sales_qty"]),
                "status": bool(row["enabled"]),
                "updated": format_dt(row["updated_at"], "%m-%d %H:%M"),
            }
            for row in query_all(
                conn,
                "SELECT product_no, name, category, price, stock_qty, sales_qty, enabled, updated_at FROM catalog_products WHERE tenant_id = %s ORDER BY updated_at DESC, id DESC",
                (tenant_id,),
            )
        ]

        order_rows = query_all(
            conn,
            """
            SELECT o.order_no AS id, COALESCE(m.name, '-') AS member, o.paid_amount AS amount,
                   o.item_count AS items, o.channel, COALESCE(s.name, '-') AS store,
                   o.status, o.ordered_at
            FROM sales_orders o
            LEFT JOIN crm_members m ON m.id = o.member_id
            LEFT JOIN org_stores s ON s.id = o.store_id
            WHERE o.tenant_id = %s
            ORDER BY o.ordered_at DESC, o.id DESC
            LIMIT 100
            """,
            (tenant_id,),
        )
        orders = [
            {
                "id": row["id"],
                "member": row["member"],
                "amount": as_float(row["amount"]),
                "items": as_int(row["items"]),
                "channel": row["channel"],
                "store": row["store"],
                "status": order_status_label(row["status"]),
                "time": format_dt(row["ordered_at"]),
            }
            for row in order_rows
        ]

        log_rows = [
            {
                "time": format_dt(row["event_at"]),
                "member": row["member"] or "-",
                "action": row["action"],
                "detail": row["detail"],
                "operator": row["operator"] or "系统自动",
                "channel": row["channel"] or "系统",
            }
            for row in query_all(
                conn,
                """
                SELECT l.event_at, m.name AS member, l.action, l.detail,
                       u.display_name AS operator, l.channel
                FROM crm_member_logs l
                LEFT JOIN crm_members m ON m.id = l.member_id
                LEFT JOIN iam_users u ON u.id = l.operator_user_id
                WHERE l.tenant_id = %s
                ORDER BY l.event_at DESC, l.id DESC
                LIMIT 50
                """,
                (tenant_id,),
            )
        ]
        if not log_rows:
            coupon_logs = query_all(
                conn,
                """
                SELECT g.issued_at, m.name AS member, c.name AS coupon_name
                FROM marketing_coupon_grants g
                JOIN crm_members m ON m.id = g.member_id
                JOIN marketing_coupons c ON c.id = g.coupon_id
                WHERE g.tenant_id = %s
                ORDER BY g.issued_at DESC
                LIMIT 20
                """,
                (tenant_id,),
            )
            log_rows = [
                {
                    "time": format_dt(row["issued_at"]),
                    "member": row["member"],
                    "action": "优惠券发放",
                    "detail": f"发放{row['coupon_name']}",
                    "operator": "系统自动",
                    "channel": "营销任务",
                }
                for row in coupon_logs
            ]

        tag_log_rows = [
            {
                "time": format_dt(row["assigned_at"]),
                "member": row["member"],
                "tag": row["tag"],
                "change": "新增",
                "source": row["source"],
                "operator": row["operator"] or "系统自动",
            }
            for row in query_all(
                conn,
                """
                SELECT mt.assigned_at, m.name AS member, t.name AS tag, mt.source,
                       u.display_name AS operator
                FROM crm_member_tags mt
                JOIN crm_members m ON m.id = mt.member_id
                JOIN crm_tags t ON t.id = mt.tag_id
                LEFT JOIN iam_users u ON u.id = mt.assigned_by
                WHERE mt.tenant_id = %s
                ORDER BY mt.assigned_at DESC
                LIMIT 50
                """,
                (tenant_id,),
            )
        ]

        conversations = [
            {
                "id": row["id"] or f"conversation-{row['pk']}",
                "name": row["title"],
                "type": conversation_type_label(row["conversation_type"]),
                "date": format_dt(row["last_message_at"], "%Y/%m/%d"),
                "unread": as_int(row["unread_count"]),
                "preview": row["last_message_preview"] or "",
                "tone": COLOR_CYCLE[index % len(COLOR_CYCLE)],
                "icon": "wx" if index == 0 else ("text" if row["conversation_type"] == "chat" else "card"),
                "pinned": bool(row["pinned"]),
            }
            for index, row in enumerate(
                query_all(
                    conn,
                    """
                    SELECT id AS pk, external_id AS id, conversation_type, title, pinned,
                           unread_count, last_message_preview, last_message_at
                    FROM wechat_conversations
                    WHERE tenant_id = %s
                    ORDER BY pinned DESC, last_message_at DESC, id DESC
                    LIMIT 80
                    """,
                    (tenant_id,),
                )
            )
        ]

        messages = []
        if conversations:
            messages = [
                {
                    "id": row["id"],
                    "side": "right" if row["sender_type"] in ("staff", "system") else "left",
                    "author": row["sender_name"] or "客户",
                    "time": format_dt(row["sent_at"], "%m/%d %H:%M:%S"),
                    "text": row["content"],
                }
                for row in query_all(
                    conn,
                    """
                    SELECT m.id, m.sender_type, m.sender_name, m.content, m.sent_at
                    FROM wechat_messages m
                    JOIN wechat_conversations c ON c.id = m.conversation_id
                    WHERE m.tenant_id = %s
                      AND c.external_id = %s
                    ORDER BY m.sent_at ASC, m.id ASC
                    LIMIT 100
                    """,
                    (tenant_id, conversations[0]["id"]),
                )
            ]

        claw_insights = [
            {"title": row["title"], "desc": row["summary"], "tone": row["tone"] or "blue"}
            for row in query_all(
                conn,
                "SELECT title, summary, tone FROM ai_claw_insights WHERE tenant_id = %s AND status = 'active' ORDER BY priority DESC, generated_at DESC LIMIT 12",
                (tenant_id,),
            )
        ]
        claw_suggestions = [
            {
                "title": row["title"],
                "desc": row["description"],
                "action": row["action_label"],
                "tone": COLOR_CYCLE[index % len(COLOR_CYCLE)],
                "expected": row["expected_impact"] or "",
            }
            for index, row in enumerate(
                query_all(
                    conn,
                    "SELECT title, description, action_label, expected_impact FROM ai_claw_suggestions WHERE tenant_id = %s ORDER BY created_at DESC, id DESC LIMIT 12",
                    (tenant_id,),
                )
            )
        ]
        claw_prompts = [
            {
                "scene": row["scene"],
                "prompt": row["prompt"],
                "owner": row["owner"] or "超级管理员",
                "used": as_int(row["use_count"]),
            }
            for row in query_all(
                conn,
                """
                SELECT p.scene, p.prompt, u.display_name AS owner, p.use_count
                FROM ai_claw_prompt_templates p
                LEFT JOIN iam_users u ON u.id = p.owner_user_id
                WHERE p.tenant_id = %s AND p.enabled = 1
                ORDER BY p.use_count DESC, p.id DESC
                LIMIT 20
                """,
                (tenant_id,),
            )
        ]

        sales_total = as_float(query_one(conn, "SELECT COALESCE(SUM(paid_amount), 0) AS total FROM sales_orders WHERE tenant_id = %s", (tenant_id,))["total"])
        order_total = as_int(query_one(conn, "SELECT COUNT(*) AS total FROM sales_orders WHERE tenant_id = %s", (tenant_id,))["total"])
        trends_30 = trend_rows(conn, tenant_id, 30)
        trends_90 = trend_rows(conn, tenant_id, 90)
        period_new_total = sum(row["members"] for row in trends_30)
        peak_row = max(trends_30, key=lambda row: row["members"]) if trends_30 else {"day": "-", "members": 0}
        quadrant_rows = query_all(
            conn,
            """
            SELECT CASE
                     WHEN COALESCE(mm.total_spend, 0) >= 15000 THEN 'keep'
                     WHEN COALESCE(mm.total_spend, 0) >= 5000 THEN 'grow'
                     WHEN COALESCE(mm.total_spend, 0) >= 1000 THEN 'normal'
                     ELSE 'winback'
                   END AS bucket,
                   COUNT(*) AS total,
                   COALESCE(SUM(mm.total_spend), 0) AS spend
            FROM crm_members m
            LEFT JOIN crm_member_metrics mm ON mm.member_id = m.id
            WHERE m.tenant_id = %s
            GROUP BY bucket
            """,
            (tenant_id,),
        )
        quadrant_by_bucket = {row["bucket"]: row for row in quadrant_rows}
        quadrant_labels = [
            ("keep", "重要保持"),
            ("grow", "重要发展"),
            ("normal", "一般保持"),
            ("winback", "低价值挽回"),
        ]
        quadrant_boxes = []
        for bucket, label in quadrant_labels:
            row = quadrant_by_bucket.get(bucket, {"total": 0, "spend": 0})
            quadrant_boxes.append(
                {
                    "className": bucket,
                    "title": label,
                    "value": f"{format_number(row['total'])}人",
                    "note": ratio(row["total"], total_members),
                    "previous": "暂无历史",
                    "spend": format_plain_money(row["spend"]),
                }
            )

        return {
            "meta": {
                "source": "mysql",
                "tenant": {"code": tenant["code"], "name": tenant["name"], "brandName": tenant["brand_name"]},
                "generatedAt": datetime.now().isoformat(timespec="seconds"),
            },
            "dashboard": {
                "summary": {
                    "totalMembers": format_number(total_members),
                    "totalDelta": "0.00%",
                    "yesterdayNew": format_number(latest_day_new),
                    "yesterdayDelta": "0.00%",
                    "monthNew": format_number(month_new),
                    "monthDelta": "0.00%",
                    "quarterNew": format_number(quarter_new),
                    "quarterDelta": "0.00%",
                    "dailyGrowth": "+0.00%",
                    "monthlyGrowth": "+0.00%",
                    "quarterlyGrowth": "+0.00%",
                },
                "periodLabel": f"{format_date(max_register - timedelta(days=30))} 至 {format_date(max_register)}" if max_register else "暂无周期",
                "periodSummary": {
                    "total": format_number(period_new_total),
                    "comparison": "+0.00%",
                    "dailyAverage": format_number(round(period_new_total / len(trends_30))) if trends_30 else "0",
                    "peakMembers": format_number(peak_row["members"]),
                    "peakDay": peak_row["day"],
                },
                "totalMembers": total_members,
                "totalMembersLabel": format_number(total_members),
                "sourceTotal": format_number(total_members),
                "trends30": trends_30,
                "trends90": trends_90,
                "levels": level_rows,
                "sourceRows": source_rows,
                "portraitBars": portrait_bars,
                "portrait": {
                    "gender": gender_rows,
                    "active": active_rows,
                    "valueData": value_rows,
                    "city": city_rows,
                    "platform": platform_rows,
                },
                "valueQuadrant": {
                    "cutoffLabel": format_date(max_register) if max_register else "暂无日期",
                    "compareLabel": "当前数据库累计",
                    "previousMembers": "暂无历史",
                    "currentMembers": format_number(total_members),
                    "salesTotal": format_plain_money(sales_total),
                    "boxes": quadrant_boxes,
                },
            },
            "members": members,
            "highValueMembers": high_value_members,
            "logRows": log_rows,
            "segments": segments,
            "tags": tags,
            "tagLogRows": tag_log_rows,
            "products": products,
            "orders": orders,
            "wechatConversations": conversations,
            "wechatMessages": messages,
            "clawInsightCards": claw_insights,
            "clawSuggestionCards": claw_suggestions,
            "clawPromptTemplates": claw_prompts,
            "clawTrend": [
                {"day": row["day"], "insight": row["members"], "suggestion": max(0, row["members"] - 1)}
                for row in trends_30
            ],
            "fanTrend": [
                {"day": row["day"], "new": row["members"], "lost": 0, "active": row["members"]}
                for row in trends_30
            ],
            "memberTrend": [{"month": row["day"], "active": row["members"], "retention": row["rate"], "value": row["members"]} for row in trends_90],
            "salesTrend": [
                {"day": row["day"], "sales": row["sales"], "orders": row["orders"], "avg": row["avg"]}
                for row in query_all(
                    conn,
                    """
                    SELECT DATE_FORMAT(ordered_at, '%%m-%%d') AS day,
                           ROUND(SUM(paid_amount) / 10000, 2) AS sales,
                           COUNT(*) AS orders,
                           ROUND(AVG(paid_amount), 2) AS avg
                    FROM sales_orders
                    WHERE tenant_id = %s
                    GROUP BY DATE(ordered_at), DATE_FORMAT(ordered_at, '%%m-%%d')
                    ORDER BY DATE(ordered_at)
                    """,
                    (tenant_id,),
                )
            ],
            "businessStats": {
                "salesTotal": format_money(sales_total),
                "orderTotal": format_number(order_total),
                "campaigns": as_int(query_one(conn, "SELECT COUNT(*) AS total FROM marketing_campaigns WHERE tenant_id = %s", (tenant_id,))["total"]),
                "coupons": as_int(query_one(conn, "SELECT COUNT(*) AS total FROM marketing_coupons WHERE tenant_id = %s", (tenant_id,))["total"]),
                "reachTasks": as_int(query_one(conn, "SELECT COUNT(*) AS total FROM marketing_reach_tasks WHERE tenant_id = %s", (tenant_id,))["total"]),
            },
        }


def response(handler, status, body):
    payload = json.dumps(body, ensure_ascii=False, default=json_default).encode("utf-8")
    handler.send_response(status)
    handler.send_header("Content-Type", "application/json; charset=utf-8")
    handler.send_header("Cache-Control", "no-store")
    handler.send_header("Access-Control-Allow-Origin", env("CORS_ORIGIN", "*"))
    handler.send_header("Access-Control-Allow-Methods", "GET, OPTIONS")
    handler.send_header("Access-Control-Allow-Headers", "Content-Type")
    handler.end_headers()
    handler.wfile.write(payload)


class ApiHandler(BaseHTTPRequestHandler):
    def do_OPTIONS(self):
        response(self, 204, {})

    def do_GET(self):
        path = urlparse(self.path).path
        try:
            if path == "/api/health":
                config = db_config()
                response(self, 200, {"ok": True, "database": config["database"], "host": config["host"], "port": config["port"]})
                return
            if path == "/api/app-data":
                response(self, 200, load_app_data())
                return
            response(self, 404, {"error": "not_found"})
        except Exception as exc:
            response(self, 503, {"error": "database_unavailable", "message": str(exc)})

    def log_message(self, fmt, *args):
        print("[%s] %s" % (self.log_date_time_string(), fmt % args))


def main():
    host = env("API_HOST", "127.0.0.1")
    port = int(env("API_PORT", "8787"))
    server = ThreadingHTTPServer((host, port), ApiHandler)
    print(f"member-crm API listening on http://{host}:{port}")
    server.serve_forever()


if __name__ == "__main__":
    main()
