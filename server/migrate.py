#!/usr/bin/env python3
import os
import sys

import pymysql
from pymysql.constants import CLIENT

from api import ROOT_DIR, db_config, load_env_file


MIGRATIONS = (
    os.path.join(ROOT_DIR, "database", "mysql", "01_schema.sql"),
    os.path.join(ROOT_DIR, "database", "mysql", "02_seed_demo.sql"),
)


def execute_file(connection, path):
    with open(path, "r", encoding="utf-8") as handle:
        sql = handle.read()
    with connection.cursor() as cursor:
        cursor.execute(sql)
        while cursor.nextset():
            pass
    print(f"applied {os.path.relpath(path, ROOT_DIR)}")


def main():
    load_env_file(os.path.join(ROOT_DIR, ".env"))
    load_env_file(os.path.join(ROOT_DIR, "server", ".env"))
    config = db_config()
    config["client_flag"] = CLIENT.MULTI_STATEMENTS
    config["autocommit"] = False
    with pymysql.connect(**config) as connection:
        try:
            for path in MIGRATIONS:
                execute_file(connection, path)
            connection.commit()
        except Exception:
            connection.rollback()
            raise


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        print(f"migration failed: {exc}", file=sys.stderr)
        raise
