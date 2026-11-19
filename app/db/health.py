from typing import Any

from .connection import test_connection


def run_health_check() -> dict[str, Any]:
    try:
        connection_result = test_connection()
        return {
            "status": "ok",
            **connection_result,
        }
    except Exception as exc:
        return {
            "status": "error",
            "message": str(exc),
        }