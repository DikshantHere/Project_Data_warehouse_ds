/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'warehouse_project' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
    within the database: 'bronze', 'silver', and 'gold'.
	
WARNING:
    Running this script will drop the entire 'warehouse_project' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/
USE master ;
GO 

if EXISTS (SELECT 1 FROM sys.databases WHERE name = 'warehouse_project')
	BEGIN
		ALTER DATABASE warehouse_project
		SET SINGLE_USER 
		WITH ROLLBACK IMMEDIATE;
	
		DROP DATABASE warehouse_project;
END;
GO

CREATE DATABASE warehouse_project ;
GO

USE warehouse_project ;
GO

CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
