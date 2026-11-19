import json
import sys

from db.health import run_health_check


def main() -> int:
    result = run_health_check()
    print(json.dumps(result, indent=2))
    return 0 if result.get("status") == "ok" else 1


if __name__ == "__main__":
    raise SystemExit(main())