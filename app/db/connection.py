from typing import Any, Optional

import pyodbc

from .config import DatabaseSettings


def build_connection_string(settings: DatabaseSettings) -> str:
    if settings.connection_string:
        return settings.connection_string

    if not settings.has_complete_parts():
        raise ValueError(
            "Database settings are incomplete. Set DB_CONNECTION_STRING or provide DB_SERVER and DB_DATABASE."
        )

    parts = [
        f"DRIVER={{{settings.driver}}}",
        f"SERVER={settings.server}",
        f"DATABASE={settings.database}",
        f"Encrypt={settings.encrypt}",
        f"TrustServerCertificate={settings.trust_server_certificate}",
        f"Connection Timeout={settings.timeout}",
    ]

    if settings.username and settings.password:
        parts.append(f"UID={settings.username}")
        parts.append(f"PWD={settings.password}")
    else:
        parts.append("Trusted_Connection=yes")

    return ";".join(parts)


def connect(settings: Optional[DatabaseSettings] = None) -> pyodbc.Connection:
    active_settings = settings or DatabaseSettings.from_env()
    connection_string = build_connection_string(active_settings)
    return pyodbc.connect(connection_string)


def test_connection(settings: Optional[DatabaseSettings] = None) -> dict[str, Any]:
    with connect(settings) as conn:
        with conn.cursor() as cursor:
            cursor.execute(
                "SELECT CAST(@@SERVERNAME AS NVARCHAR(128)) AS server_name, CAST(DB_NAME() AS NVARCHAR(128)) AS database_name"
            )
            row = cursor.fetchone()

    return {
        "server": row.server_name,
        "database": row.database_name,
        "connected": True,
    }