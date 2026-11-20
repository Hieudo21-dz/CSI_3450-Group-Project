USE FreeBee;
GO

CREATE OR ALTER TRIGGER TRG_ORDER_ITEM_SAFETY
ON ORDER_ITEM
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Msg NVARCHAR(400);

    SELECT TOP (1)
           @Msg = CONCAT('Unsafe order blocked: ', M.ItemName, ' contains ', A.AllergenName,
                         ', and ', C.FirstName, ' ', C.LastName, ' has a ',
                         LOWER(CA.Severity), ' ', A.AllergenName, ' allergy.')
    FROM   inserted I
    JOIN   ORDERS O            ON O.OrderID     = I.OrderID
    JOIN   CUSTOMER C          ON C.CustomerID  = O.CustomerID
    JOIN   CUSTOMER_ALLERGY CA ON CA.CustomerID = O.CustomerID
    JOIN   MENU_ALLERGEN MA    ON MA.MenuItemID = I.MenuItemID
                              AND MA.AllergenID = CA.AllergenID
    JOIN   MENU_ITEM M         ON M.MenuItemID  = I.MenuItemID
    JOIN   ALLERGEN A          ON A.AllergenID  = CA.AllergenID
    ORDER BY CASE CA.Severity WHEN 'Severe' THEN 1 WHEN 'Moderate' THEN 2 ELSE 3 END;

    IF @Msg IS NOT NULL
    BEGIN
        THROW 50001, @Msg, 1;
    END
END
GO

CREATE OR ALTER TRIGGER TRG_ORDER_ITEM_TOTAL
ON ORDER_ITEM
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE O
    SET    TotalAmount = ISNULL((SELECT SUM(OI.Quantity * M.Price)
                                 FROM   ORDER_ITEM OI
                                 JOIN   MENU_ITEM M ON M.MenuItemID = OI.MenuItemID
                                 WHERE  OI.OrderID = O.OrderID), 0)
    FROM   ORDERS O
    WHERE  O.OrderID IN (SELECT OrderID FROM inserted
                         UNION
                         SELECT OrderID FROM deleted);
END
GO
