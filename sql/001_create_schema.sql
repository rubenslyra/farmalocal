USE [farmalocal];
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'farmalocal')
BEGIN
    EXEC('CREATE SCHEMA farmalocal');
END
GO
