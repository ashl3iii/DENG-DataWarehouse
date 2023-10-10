/* create data warehouse (OLAP) for analysing sales of products */
CREATE DATABASE CompAccInc_DWMPA

/* use database OLAP */
USE CompaccInc_DWMPA

/* create dimensions of snowflake schema: Regions, Countries, Customers, Product_Categories, Products, Locations, Warehouses, Inventories, Employees, Time */

/* parent tables: Customer, Employee, Product_Category, Region */
/* merged Customers Dimension with Contacts Dimension */
CREATE TABLE CustomersDim (
	Cust_ID int not null identity(1,1),
	Cust_Name nvarchar(255) not null,
	Cust_Address nvarchar(255) not null,
	Website nvarchar(255) not null,
	Credit_Limit int not null,
	Contact_ID int not null,
	First_Name nvarchar(255) not null,
	Last_Name nvarchar(255) not null,
	Email nvarchar(255) not null,
	Phone nvarchar(255) not null,
	PRIMARY KEY (Cust_ID)
)

CREATE TABLE EmployeesDim (
	Employee_ID int not null,
	First_Name nvarchar(255) not null,
	Last_Name nvarchar(255) not null,
	Email nvarchar(255) not null,
	Phone nvarchar(255) not null,
	Hire_Date date not null,
	Manager_ID int null,
	Job_Title nvarchar(255) not null,
	PRIMARY KEY (Employee_ID)
)

CREATE TABLE Product_CategoriesDim (
	Category_ID int not null,
	Category_Name nvarchar(255) not null,
	PRIMARY KEY (Category_ID)
)

CREATE TABLE RegionsDim (
	Region_ID int not null,
	Region_Name nvarchar(255) not null,
	PRIMARY KEY (Region_ID)
)

/* child tables */
CREATE TABLE CountriesDim (
  Country_ID nvarchar(3) not null,
  Country_Name nvarchar(255) not null,
  Region_ID int not null,
  PRIMARY KEY (Country_ID),
  FOREIGN KEY (Region_ID) REFERENCES RegionsDim(Region_ID)
)

/* without product and warehouse (child tables), no inventory */
CREATE TABLE LocationsDim (
	Location_ID int not null,
	Address nvarchar(255) not null,
	Postal_Code nvarchar(255) null,
	City nvarchar(255) not null,
	State nvarchar(255) null,
	Country_ID nvarchar(3) not null,
	PRIMARY KEY (Location_ID),
	FOREIGN KEY (Country_ID) REFERENCES CountriesDim(Country_ID)
)

CREATE TABLE WarehousesDim (
	Warehouse_ID int not null,
	Warehouse_Name nvarchar(255) not null,
	Location_ID int not null,
	PRIMARY KEY (Warehouse_ID),
	FOREIGN KEY (Location_ID) REFERENCES LocationsDim(Location_ID)
)

CREATE TABLE ProductsDim (
	Product_ID int not null,
	Product_Name nvarchar(255) not null,
	Description nvarchar(255) not null,
	Standard_Cost int not null,
	List_Price int not null,
	Category_ID int not null,
	PRIMARY KEY (Product_ID),
	FOREIGN KEY (Category_ID) REFERENCES Product_CategoriesDim(Category_ID)
)

CREATE TABLE InventoriesDim (
	Product_ID int not null,
	Warehouse_ID int not null, 
	Quantity int not null,
	FOREIGN KEY (Product_ID) REFERENCES ProductsDim(Product_ID),
	FOREIGN KEY (Warehouse_ID) REFERENCES WarehousesDim(Warehouse_ID)
)

CREATE TABLE TimeDim (
	Time_ID int not null identity(1,1),
    Date_Value date,
    Year int,
    Quarter int,
    Month int,
    Week int,
    Day int,
	PRIMARY KEY (Time_ID)
)

/* create facts table: a fact table is a table that stores the measurements, metrics, or facts related to a business operation. */
/* Order_items table in OLTP became the fact table (merged with Orders table) */
CREATE TABLE SalesFacts (
    Sales_ID int not null identity(1,1),
    Order_ID int not null,
    Cust_ID int not null,
    Product_ID int not null,
    Salesman_ID int not null,
    Time_ID int not null,
    Quantity int not null,
    Unit_Price int not null,
	Status nvarchar(255) not null, 
	PRIMARY KEY (Sales_ID),
    FOREIGN KEY (Cust_ID) REFERENCES CustomersDim(Cust_ID),
    FOREIGN KEY (Product_ID) REFERENCES ProductsDim(Product_ID),
    FOREIGN KEY (Salesman_ID) REFERENCES EmployeesDim(Employee_ID),
    FOREIGN KEY (Time_ID) REFERENCES TimeDim(Time_ID)
)

