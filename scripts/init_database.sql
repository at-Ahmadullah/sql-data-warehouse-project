/*
========================================================
CREATE DATABASE AND SCHEMAS
========================================================

Objective:
To create a database called 'DataWareHouse' after checking if it already exists.
If it already exists, we are dropping the existing database and recreating a new one.
Additionally, the script creates three new schemas within the database namely 'gold', 'silver', 'bronze'.


!!!!  WARNING !!!!
Running this script will the delete the old database with the name 'Datawarehouse' and recrate a new one.
This results in the loss of data which is present in the database and cannot be restored. Proceed with caution and
ensure you have proper backups before executing the script.
*/

USE master;  --This command sets the session to use the sys.master database which is necessary in creating new databases.
GO           --This helps in executing multiple SQL commands one after the other.

-- Drop and recreate the Database 'DataWareHouse'
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = "DataWareHouse")
BEGIN
  ALTER DATABASE DataWareHouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
  DROP DATABASE DataWareHouse;
END;
GO;

-- CREATE A DATABASE "DataWareHouse"
CREATE DATABASE DataWarehouse;
GO

USE DataWareHouse;
GO
  
-- CREATE SCHEMAS gold, silver and bronze
CREATE SCHEMA gold;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA bronze;
GO
