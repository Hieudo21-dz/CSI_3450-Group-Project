
USE FreeBee;
GO

CREATE OR ALTER VIEW VW_SAFE_MENU AS
SELECT C.CustomerID, M.MenuItemID, M.ItemName, M.Category, M.Price
FROM   CUSTOMER C
CROSS JOIN MENU_ITEM M
WHERE  NOT EXISTS (SELECT 1
                   FROM   CUSTOMER_ALLERGY CA
                   JOIN   MENU_ALLERGEN MA ON MA.AllergenID = CA.AllergenID
                   WHERE  CA.CustomerID = C.CustomerID
                     AND  MA.MenuItemID = M.MenuItemID);
GO

CREATE OR ALTER VIEW VW_CUSTOMER_ALLERGIES AS
SELECT C.CustomerID, C.FirstName, C.LastName,
       A.AllergenID, A.AllergenName, CA.Severity, A.SafetyNote
FROM   CUSTOMER C
JOIN   CUSTOMER_ALLERGY CA ON CA.CustomerID = C.CustomerID
JOIN   ALLERGEN A          ON A.AllergenID  = CA.AllergenID;
GO

-- Q1. What is this customer allergic to? (customer 1 as the example)
SELECT FirstName, LastName, AllergenName, Severity, SafetyNote
FROM   VW_CUSTOMER_ALLERGIES
WHERE  CustomerID = 1
ORDER BY CASE Severity WHEN 'Severe' THEN 1 WHEN 'Moderate' THEN 2 ELSE 3 END;

-- Q2. Which dishes are safe for this customer? (the filtered menu)
SELECT Category, ItemName, Price
FROM   VW_SAFE_MENU
WHERE  CustomerID = 1
ORDER BY Category, ItemName;

-- Q3. Which dishes must this customer avoid, and why?
SELECT M.ItemName, M.Category,
       STRING_AGG(A.AllergenName, ', ') WITHIN GROUP (ORDER BY A.AllergenName) AS ConflictingAllergens
FROM   CUSTOMER_ALLERGY CA
JOIN   MENU_ALLERGEN MA ON MA.AllergenID = CA.AllergenID
JOIN   MENU_ITEM M      ON M.MenuItemID  = MA.MenuItemID
JOIN   ALLERGEN A       ON A.AllergenID  = CA.AllergenID
WHERE  CA.CustomerID = 1
GROUP BY M.ItemName, M.Category
ORDER BY M.Category, M.ItemName;

/* ===================== REPORTS ===================== */

-- Q4. Which menu items are free of all tracked allergens? (outer join)
SELECT M.ItemName, M.Category, M.Price
FROM   MENU_ITEM M
LEFT JOIN MENU_ALLERGEN MA ON MA.MenuItemID = M.MenuItemID
WHERE  MA.MenuItemID IS NULL
ORDER BY M.Category, M.ItemName;

-- Q5. Which allergens are most common among our customers?
SELECT A.AllergenName,
       COUNT(CA.CustomerID)                                       AS Customers,
       SUM(CASE WHEN CA.Severity = 'Severe' THEN 1 ELSE 0 END)    AS SevereCases
FROM   ALLERGEN A
LEFT JOIN CUSTOMER_ALLERGY CA ON CA.AllergenID = A.AllergenID
GROUP BY A.AllergenName
ORDER BY Customers DESC, SevereCases DESC, A.AllergenName;

-- Q6. How much of the menu does each allergen affect?
SELECT A.AllergenName,
       COUNT(MA.MenuItemID) AS MenuItems,
       CAST(100.0 * COUNT(MA.MenuItemID) / (SELECT COUNT(*) FROM MENU_ITEM) AS DECIMAL(5,1)) AS PercentOfMenu
FROM   ALLERGEN A
LEFT JOIN MENU_ALLERGEN MA ON MA.AllergenID = A.AllergenID
GROUP BY A.AllergenName
ORDER BY MenuItems DESC, A.AllergenName;

-- Q7. Which menu items contain the most allergens, and which ones?
SELECT M.ItemName, M.Category,
       COUNT(*) AS AllergenCount,
       STRING_AGG(A.AllergenName, ', ') WITHIN GROUP (ORDER BY A.AllergenName) AS Allergens
FROM   MENU_ITEM M
JOIN   MENU_ALLERGEN MA ON MA.MenuItemID = M.MenuItemID
JOIN   ALLERGEN A       ON A.AllergenID  = MA.AllergenID
GROUP BY M.ItemName, M.Category
ORDER BY AllergenCount DESC, M.ItemName;

-- Q8. Which customers have a severe allergy? (staff alert list)
SELECT LastName, FirstName, AllergenName, SafetyNote
FROM   VW_CUSTOMER_ALLERGIES
WHERE  Severity = 'Severe'
ORDER BY LastName, FirstName, AllergenName;

-- Q9. How many safe dishes does each customer have to choose from?
--     (customers at the top have the fewest options)
SELECT C.CustomerID, C.FirstName, C.LastName,
       (SELECT COUNT(*) FROM CUSTOMER_ALLERGY CA WHERE CA.CustomerID = C.CustomerID) AS Allergies,
       COUNT(S.MenuItemID) AS SafeDishes
FROM   CUSTOMER C
LEFT JOIN VW_SAFE_MENU S ON S.CustomerID = C.CustomerID
GROUP BY C.CustomerID, C.FirstName, C.LastName
ORDER BY SafeDishes, C.LastName;

-- Q10. Sales by menu category (cancelled orders left out)
SELECT M.Category,
       SUM(OI.Quantity)           AS UnitsSold,
       SUM(OI.Quantity * M.Price) AS Revenue
FROM   ORDER_ITEM OI
JOIN   ORDERS O    ON O.OrderID    = OI.OrderID
JOIN   MENU_ITEM M ON M.MenuItemID = OI.MenuItemID
WHERE  O.OrderStatus <> 'Cancelled'
GROUP BY M.Category
ORDER BY Revenue DESC;

-- Q11. The five best-selling menu items
SELECT TOP 5 M.ItemName, M.Category,
       SUM(OI.Quantity)           AS UnitsSold,
       SUM(OI.Quantity * M.Price) AS Revenue
FROM   ORDER_ITEM OI
JOIN   ORDERS O    ON O.OrderID    = OI.OrderID
JOIN   MENU_ITEM M ON M.MenuItemID = OI.MenuItemID
WHERE  O.OrderStatus <> 'Cancelled'
GROUP BY M.ItemName, M.Category
ORDER BY UnitsSold DESC, Revenue DESC;

-- Q12. Customers who have spent more than the average customer (HAVING + subquery)
SELECT C.CustomerID, C.FirstName, C.LastName,
       COUNT(*)           AS Orders,
       SUM(O.TotalAmount) AS TotalSpent
FROM   CUSTOMER C
JOIN   ORDERS O ON O.CustomerID = C.CustomerID
WHERE  O.OrderStatus <> 'Cancelled'
GROUP BY C.CustomerID, C.FirstName, C.LastName
HAVING SUM(O.TotalAmount) > (SELECT AVG(T.Spent)
                             FROM (SELECT SUM(TotalAmount) AS Spent
                                   FROM   ORDERS
                                   WHERE  OrderStatus <> 'Cancelled'
                                   GROUP BY CustomerID) AS T)
ORDER BY TotalSpent DESC;

-- Q13. Orders and revenue per month
SELECT CONVERT(CHAR(7), OrderDate, 126) AS OrderMonth,
       COUNT(*)                         AS Orders,
       SUM(TotalAmount)                 AS Revenue,
       CAST(AVG(TotalAmount) AS DECIMAL(8,2)) AS AverageOrder
FROM   ORDERS
WHERE  OrderStatus <> 'Cancelled'
GROUP BY CONVERT(CHAR(7), OrderDate, 126)
ORDER BY OrderMonth;
GO
