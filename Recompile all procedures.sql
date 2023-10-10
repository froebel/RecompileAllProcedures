--Forces the creation of execution-plans for all sps.
--To achieve this, on temporary SP is created that calls all existing SPs.
--It seems like no simulation of the parameters is necessary. That makes things a lot easier.
DECLARE @stmt NVARCHAR(MAX) = 'CREATE PROCEDURE pTempCompileTest AS ' + CHAR(13) + CHAR(10)
SELECT @stmt = @stmt + 'EXEC [' + schemas.name + '].[' + procedures.name + '];'
	FROM sys.procedures
		INNER JOIN sys.schemas ON schemas.schema_id = procedures.schema_id
	WHERE schemas.name = 'dbo'
	ORDER BY procedures.name

EXEC sp_executesql @stmt
GO

--Here, the real magic happens.
--In order to display as many errors as possible, XACT_ABORT is turned off.
--Unfortunately, this stops the execution anyway.
SET XACT_ABORT OFF
GO
--Showplan disables the actual execution, but forces t-sql to create execution-plans for every statement.
--This is the core of the whole thing!
SET SHOWPLAN_ALL ON
GO
--You cannot use dynamic SQL in here, since sp_executesql will not be executed.
EXEC pTempCompileTest
GO
SET SHOWPLAN_ALL OFF
GO
SET XACT_ABORT ON
GO
--drop temp sp again
DROP PROCEDURE pTempCompileTest
--If you have any errors in the messages-window now, you should fix these...
