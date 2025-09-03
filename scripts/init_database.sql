/*
-- This SQL script is designed to set up a basic data warehouse structure. 
- Its main purpose is to create separate schemas (databases within a database) for raw data (bronze), 
- cleaned and processed data (silver), and data ready for analysis (gold). 
- This approach helps organize the data lifecycle and makes it more manageable.
*/

USE master;
CREATE DATABASE DataWarehouse;
USE DataWareHouse;

CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
