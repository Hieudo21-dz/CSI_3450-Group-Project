import argparse
import json

from db.queries import (
    add_customer,
    get_customer_allergies,
    get_safe_menu,
    update_customer_phone,
)


def main() -> int:
    parser = argparse.ArgumentParser(description="Exercise FreeBee database integration")
    parser.add_argument("--customer-id", type=int, default=1)
    parser.add_argument("--add-customer", action="store_true")
    parser.add_argument("--first-name", default="Demo")
    parser.add_argument("--last-name", default="Customer")
    parser.add_argument("--email", default="demo.customer@example.com")
    parser.add_argument("--phone")
    parser.add_argument("--update-phone")
    args = parser.parse_args()

    try:
        result = {
            "customerId": args.customer_id,
            "allergies": get_customer_allergies(args.customer_id),
            "safeMenu": get_safe_menu(args.customer_id),
        }

        if args.add_customer:
            result["insertedCustomer"] = add_customer(
                args.first_name,
                args.last_name,
                args.email,
                args.phone,
            )

        if args.update_phone:
            result["updatedCustomer"] = update_customer_phone(
                args.customer_id,
                args.update_phone,
            )

        print(json.dumps(result, indent=2, default=str))
        return 0
    except Exception as exc:
        print(json.dumps({"status": "error", "message": str(exc)}, indent=2))
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
