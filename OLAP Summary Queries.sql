/* use database OLAP */
USE CompaccInc_DWMPA

/* meaningful queries supported by the data warehouse */
/* query 1: implement a query to analyse on Sales/Staff */
/* compare the sales performance of the staff over different time periods to identify trends and improvements in their performance */
;WITH SalesData AS (
SELECT
    e.First_Name + ' ' + e.Last_Name AS Employee_Name,
    t.Year,
    t.Quarter,
    SUM(sf.Quantity * sf.Unit_Price) AS TotalSales,
    LAG(SUM(sf.Quantity * sf.Unit_Price)) OVER (PARTITION BY e.Employee_ID ORDER BY t.Year, t.Quarter) AS PreviousPeriodSales,
	(SUM(sf.Quantity * sf.Unit_Price) - LAG(SUM(sf.Quantity * sf.Unit_Price)) OVER (PARTITION BY e.Employee_ID ORDER BY t.Year, t.Quarter)) / LAG(SUM(sf.Quantity * sf.Unit_Price)) OVER (PARTITION BY e.Employee_ID ORDER BY t.Year, t.Quarter) * 100 AS SalesGrowthPercentage
FROM
    EmployeesDim e
JOIN
    SalesFacts sf ON e.Employee_ID = sf.Salesman_ID
JOIN
    TimeDim t ON sf.Time_ID = t.Time_ID
GROUP BY
    e.Employee_ID, e.First_Name, e.Last_Name, t.Year, t.Quarter
)
SELECT
	Employee_Name,
	Year,
	Quarter,
	TotalSales,
	PreviousPeriodSales,
	SalesGrowthPercentage
FROM SalesData
WHERE 
	SalesGrowthPercentage IS NOT NULL AND PreviousPeriodSales IS NOT NULL 
ORDER BY
    Employee_Name, Year, Quarter


/* query 2: implement a query to show any trend in Time series of Sales */
/* show the monthly sales trend over a year, highlighting any patterns/growth. */
;WITH TimeSeries AS (
SELECT
    t.Year,
    t.Month,
    SUM(sf.Quantity * sf.Unit_Price) AS TotalSales,
    LAG(SUM(sf.Quantity * sf.Unit_Price)) OVER (ORDER BY t.Year, t.Month) AS PreviousMonthSales,
    CASE
        WHEN LAG(SUM(sf.Quantity * sf.Unit_Price)) OVER (ORDER BY t.Year, t.Month) IS NULL THEN NULL
        ELSE (SUM(sf.Quantity * sf.Unit_Price) - LAG(SUM(sf.Quantity * sf.Unit_Price)) OVER (ORDER BY t.Year, t.Month)) / LAG(SUM(sf.Quantity * sf.Unit_Price)) OVER (ORDER BY t.Year, t.Month) * 100
    END AS GrowthPercentage
FROM
    TimeDim t
JOIN
    SalesFacts sf ON t.Time_ID = sf.Time_ID
GROUP BY
    t.Year, t.Month
)
SELECT
	Year,
	Month,
	TotalSales,
	PreviousMonthSales,
	GrowthPercentage
FROM TimeSeries
WHERE 
	GrowthPercentage IS NOT NULL AND PreviousMonthSales IS NOT NULL 
ORDER BY
    Year, Month


/* query 3: implement a query to analyse on Sales/Orders/Products */
/* determine the distribution of sales across different product categories to identify top-selling and underperforming product categories. */
SELECT
    pc.Category_Name,
    SUM(sf.Quantity * sf.Unit_Price) AS TotalSales,
    ROW_NUMBER() OVER (ORDER BY SUM(sf.Quantity * sf.Unit_Price) DESC) AS Rank,
	SUM(sf.quantity) as 'TotalQuantitySold',
    DENSE_RANK() OVER (ORDER BY SUM(sf.Quantity * sf.Unit_Price) DESC) AS Dense_Rank
FROM
    SalesFacts sf
JOIN
    ProductsDim p ON sf.Product_ID = p.Product_ID
JOIN
    Product_CategoriesDim pc ON p.Category_ID = pc.Category_ID
GROUP BY
    pc.Category_Name
ORDER BY
    TotalSales DESC


/* query 4: implement a query to analyse on Sales/Customer/Products */
/* identifying customers who have not made a purchase in the last few months */
SELECT
    'Inactive Customers' AS Category,
    c.Cust_ID AS ID,
    c.Cust_Name AS Name,
    c.Email,
    MAX(t.Date_Value) AS LastPurchaseDate,
	Count(Quantity) as 'Quantity of items'
FROM
    CustomersDim c
LEFT JOIN
    SalesFacts sf ON c.Cust_ID = sf.Cust_ID
LEFT JOIN
    TimeDim t ON sf.Time_ID = t.Time_ID
GROUP BY
    c.Cust_ID, c.Cust_Name, c.Email
HAVING
    MAX(t.Date_Value) IS NOT NULL OR MAX(t.Date_Value) < DATEADD(MONTH, -6, GETDATE())
ORDER BY ID ASC


/* query 5: implement a query to analyse stock of components in relation to sales */


