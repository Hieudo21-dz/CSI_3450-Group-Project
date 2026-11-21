from typing import Any, Dict, List, Optional

from .connection import connect
from .config import DatabaseSettings


def _fetch_dicts(cursor: Any) -> List[Dict[str, Any]]:
    columns = [column[0] for column in cursor.description]
    return [dict(zip(columns, row)) for row in cursor.fetchall()]


def get_customer_allergies(customer_id: int, settings: Optional[DatabaseSettings] = None) -> List[Dict[str, Any]]:
    with connect(settings) as conn:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                SELECT C.FirstName, C.LastName, A.AllergenName, CA.Severity, A.SafetyNote
                FROM CUSTOMER C
                JOIN CUSTOMER_ALLERGY CA ON CA.CustomerID = C.CustomerID
                JOIN ALLERGEN A ON A.AllergenID = CA.AllergenID
                WHERE C.CustomerID = ?
                ORDER BY CASE CA.Severity
                    WHEN 'Severe' THEN 1
                    WHEN 'Moderate' THEN 2
                    ELSE 3
                END
                """,
                customer_id,
            )
            return _fetch_dicts(cursor)


def get_safe_menu(customer_id: int, settings: Optional[DatabaseSettings] = None) -> List[Dict[str, Any]]:
    with connect(settings) as conn:
        with conn.cursor() as cursor:
            cursor.execute(
                """
                SELECT M.MenuItemID, M.ItemName, M.Category, M.Price
                FROM MENU_ITEM M
                WHERE NOT EXISTS (
                    SELECT 1
                    FROM CUSTOMER_ALLERGY CA
                    JOIN MENU_ALLERGEN MA ON MA.AllergenID = CA.AllergenID
                    WHERE CA.CustomerID = ?
                      AND MA.MenuItemID = M.MenuItemID
                )
                ORDER BY M.Category, M.ItemName
                """,
                customer_id,
            )
            return _fetch_dicts(cursor)


def add_customer(first_name: str, last_name: str, email: str, phone: Optional[str] = None,
                 settings: Optional[DatabaseSettings] = None) -> Dict[str, Any]:
    with connect(settings) as conn:
        try:
            with conn.cursor() as cursor:
                cursor.execute(
                    """
                    INSERT INTO CUSTOMER (FirstName, LastName, Phone, Email)
                    OUTPUT INSERTED.CustomerID, INSERTED.FirstName, INSERTED.LastName,
                           INSERTED.Phone, INSERTED.Email
                    VALUES (?, ?, ?, ?)
                    """,
                    first_name,
                    last_name,
                    phone,
                    email,
                )
                row = cursor.fetchone()
                columns = [column[0] for column in cursor.description]
            conn.commit()
            return dict(zip(columns, row))
        except Exception:
            conn.rollback()
            raise


def update_customer_phone(customer_id: int, phone: str,
                          settings: Optional[DatabaseSettings] = None) -> Optional[Dict[str, Any]]:
    with connect(settings) as conn:
        try:
            with conn.cursor() as cursor:
                cursor.execute(
                    """
                    UPDATE CUSTOMER
                    SET Phone = ?
                    OUTPUT INSERTED.CustomerID, INSERTED.FirstName, INSERTED.LastName,
                           INSERTED.Phone, INSERTED.Email
                    WHERE CustomerID = ?
                    """,
                    phone,
                    customer_id,
                )
                row = cursor.fetchone()
                if row is None:
                    return None
                columns = [column[0] for column in cursor.description]
            conn.commit()
            return dict(zip(columns, row))
        except Exception:
            conn.rollback()
            raise
