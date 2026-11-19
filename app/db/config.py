from dataclasses import dataclass
import os
from pathlib import Path
from typing import Optional


def _load_env_file(env_path: Path) -> None:
    if not env_path.exists():
        return

    for line in env_path.read_text(encoding="utf-8").splitlines():
        cleaned = line.strip()
        if not cleaned or cleaned.startswith("#") or "=" not in cleaned:
            continue

        key, value = cleaned.split("=", 1)
        os.environ.setdefault(key.strip(), value.strip().strip('"').strip("'"))


_load_env_file(Path(__file__).resolve().parents[1] / ".env")


@dataclass(frozen=True)
class DatabaseSettings:
    connection_string: Optional[str]
    server: Optional[str]
    database: Optional[str]
    username: Optional[str]
    password: Optional[str]
    driver: str
    encrypt: str
    trust_server_certificate: str
    timeout: int

    @classmethod
    def from_env(cls) -> "DatabaseSettings":
        timeout_raw = os.getenv("DB_CONNECTION_TIMEOUT", "30")
        timeout = int(timeout_raw) if timeout_raw.isdigit() else 30

        return cls(
            connection_string=os.getenv("DB_CONNECTION_STRING") or None,
            server=os.getenv("DB_SERVER") or None,
            database=os.getenv("DB_DATABASE") or None,
            username=os.getenv("DB_USERNAME") or None,
            password=os.getenv("DB_PASSWORD") or None,
            driver=os.getenv("DB_DRIVER", "ODBC Driver 18 for SQL Server"),
            encrypt=os.getenv("DB_ENCRYPT", "yes"),
            trust_server_certificate=os.getenv("DB_TRUST_SERVER_CERTIFICATE", "no"),
            timeout=timeout,
        )

    def has_complete_parts(self) -> bool:
        return bool(self.server and self.database)