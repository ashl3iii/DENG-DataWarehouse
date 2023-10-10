/* use database OLAP */
USE CompaccInc_DWMPA

/* disable foreign key constraints on OLAP dimensions to speed up and avoid complications in ETL */
ALTER TABLE CountriesDim Nocheck constraint all
ALTER TABLE CustomersDim Nocheck constraint all
ALTER TABLE EmployeesDim Nocheck constraint all
ALTER TABLE SalesFacts Nocheck constraint all
ALTER TABLE LocationsDim Nocheck constraint all
ALTER TABLE ProductsDim Nocheck constraint all
ALTER TABLE Product_CategoriesDim Nocheck constraint all
ALTER TABLE RegionsDim Nocheck constraint all
ALTER TABLE TimeDim Nocheck constraint all
ALTER TABLE WarehousesDim Nocheck constraint all
ALTER TABLE InventoriesDim Nocheck constraint all

/* delete data from OLAP dimensions before loading new data: ensures clean data/no duplicates */
DELETE FROM CountriesDim 
DELETE FROM CustomersDim 
DELETE FROM EmployeesDim 
DELETE FROM SalesFacts 
DELETE FROM LocationsDim 
DELETE FROM ProductsDim 
DELETE FROM Product_CategoriesDim 
DELETE FROM RegionsDim 
DELETE FROM TimeDim 
DELETE FROM WarehousesDim 
DELETE FROM InventoriesDim 

/* insert values into DW dimensions */
------------ CustomersDim (DONE) --------------
INSERT INTO 
	CompAccInc_DWMPA.dbo.CustomersDim (Cust_Name, Cust_Address, Website, Credit_Limit, Contact_ID, First_Name, Last_Name, Email, Phone)
SELECT 
	cu.Cust_Name, cu.Cust_Address, cu.Website, cu.Credit_Limit, co.Contact_ID, co.First_Name, co.Last_Name, co.Email, co.Phone
FROM CompAccInc_OLTPMPA.dbo.Customers cu
JOIN CompAccInc_OLTPMPA.dbo.Contacts co on co.Cust_ID = cu.Cust_ID

select * from CustomersDim


------------ EmployeesDim (DONE) --------------
INSERT INTO 
  CompAccInc_DWMPA.dbo.EmployeesDim (Employee_ID, First_Name, Last_Name, Email, Phone, Hire_Date, Manager_ID, Job_Title)  
SELECT 
  Employee_ID, First_Name, Last_Name, Email, Phone, Hire_Date, Manager_ID, Job_Title
FROM 
  CompAccInc_OLTPMPA.dbo.Employees

select * from EmployeesDim


-------------- Product_CategoriesDim (DONE) ------------
INSERT INTO 
  CompAccInc_DWMPA.dbo.Product_CategoriesDim (Category_ID, Category_Name)  
SELECT 
  Category_ID, Category_Name
FROM 
  CompAccInc_OLTPMPA.dbo.Product_Categories

select * from Product_CategoriesDim


-------------- RegionsDim (DONE) ----------------
INSERT INTO 
  CompAccInc_DWMPA.dbo.RegionsDim (Region_ID, Region_Name)  
SELECT 
  Region_ID, Region_Name
FROM 
  CompAccInc_OLTPMPA.dbo.Regions

select * from RegionsDim


-------------- CountriesDim (DONE) ----------------
INSERT INTO 
  CompAccInc_DWMPA.dbo.CountriesDim (Country_ID, Country_Name, Region_ID)  
SELECT 
  Country_ID, Country_Name, Region_ID
FROM 
  CompAccInc_OLTPMPA.dbo.Countries

select * from CountriesDim


-------------- LocationsDim (DONE) ----------------
INSERT INTO 
  CompAccInc_DWMPA.dbo.LocationsDim (Location_ID, Address, Postal_Code, City, State, Country_ID)  
SELECT 
  Location_ID, Address, Postal_Code, City, State, Country_ID
FROM 
  CompAccInc_OLTPMPA.dbo.Locations

select * from LocationsDim


-------------- WarehousesDim (DONE) ----------------
INSERT INTO 
  CompAccInc_DWMPA.dbo.WarehousesDim (Warehouse_ID, Warehouse_Name, Location_ID)  
SELECT 
  Warehouse_ID, Warehouse_Name, Location_ID
FROM 
  CompAccInc_OLTPMPA.dbo.Warehouses

select * from WarehousesDim


-------------- ProductsDim (DONE) ----------------
INSERT INTO 
  CompAccInc_DWMPA.dbo.ProductsDim (Product_ID, Product_Name, Description, Standard_Cost, List_Price, Category_ID)  
SELECT 
  Product_ID, Product_Name, Description, Standard_Cost, List_Price, Category_ID
FROM 
  CompAccInc_OLTPMPA.dbo.Products

select * from ProductsDim


-------------- InventoriesDim (DONE) ----------------
INSERT INTO 
  CompAccInc_DWMPA.dbo.InventoriesDim (Product_ID, Warehouse_ID, Quantity)  
SELECT 
  Product_ID, Warehouse_ID, Quantity
FROM 
  CompAccInc_OLTPMPA.dbo.Inventories

select * from InventoriesDim


-------------- TimeDim (DONE) ----------------
/* set the start and end dates for the date range in TimeDim */
DECLARE @StartDate DATE = '2016-01-01'; -- starting value of Date Range
DECLARE @EndDate DATE = '2017-12-31';   -- end Value of Date Range

/* declare variables */
DECLARE @curDate DATE;
DECLARE @QtrMonthNo INT;
DECLARE @FirstDayQtr DATE;

/* initialize the current date to the start date of the range */
SET @curDate = @StartDate;

/* start a loop to iterate through each date in the range */
WHILE @curDate < @EndDate 
BEGIN
    SET @QtrMonthNo = ((DATEPART(Quarter, @curDate) - 1) * 3) + 1;
    SET @FirstDayQtr = DATEFROMPARTS(YEAR(@curDate), @QtrMonthNo, 1);

    INSERT INTO TimeDim (Date_Value, Year, Quarter, Month, Week, Day)
    SELECT
        @curDate AS Date_Value,
        DATEPART(YEAR, @curDate) AS Year,
        DATEPART(QUARTER, @curDate) AS Quarter,
        DATEPART(MONTH, @curDate) AS Month,
        DATEPART(WEEK, @curDate) AS Week,
        DATEPART(DAY, @curDate) AS Day;

    SET @curDate = DATEADD(DAY, 1, @curDate);
END;

select * from TimeDim


-------------- SalesFacts (DONE) ----------------
INSERT INTO SalesFacts (Order_ID, Cust_ID, Product_ID, Salesman_ID, Time_ID, Quantity, Unit_Price, Status)
SELECT DISTINCT
    o.Order_ID,
    o.Cust_ID,
    oi.Product_ID,
    o.Salesman_ID,
    tv.Time_ID,
    oi.Quantity,
    oi.Unit_Price,
	o.Status
FROM CompAccInc_OLTPMPA.dbo.Orders o
JOIN CompAccInc_OLTPMPA.dbo.Order_items oi ON o.Order_ID = oi.Order_ID
JOIN TimeDim tv ON o.Order_Date = tv.Date_Value;

select * from SalesFacts


/* summary of all dimensions */
select top(5) * from CountriesDim
select top(5) * from CustomersDim
select top(5) * from EmployeesDim
select top(5) * from InventoriesDim
select top(5) * from LocationsDim
select top(5) * from Product_CategoriesDim
select top(5) * from ProductsDim
select top(5) * from RegionsDim
select top(5) * from WarehousesDim
select * from TimeDim