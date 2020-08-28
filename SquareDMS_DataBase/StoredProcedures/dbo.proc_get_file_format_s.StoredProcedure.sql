USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_get_file_format_s]    Script Date: 28.08.2020 21:05:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- gets file formats depending on the paramters
CREATE PROCEDURE [dbo].[proc_get_file_format_s]
	@userId int,
	@fileFormatId int,
	@extension nvarchar(250),
	@description nvarchar(250),
	@errorCode int OUTPUT
AS
BEGIN

	SET @errorCode = 0;

	-- param check // useless though user does not need special permissions
	IF @userId IS NULL 
	BEGIN
		RETURN;
	END
	
	SELECT id, extension, [description]
	FROM [File_Format]
	WHERE 
	(id = @fileFormatId OR @fileFormatId IS NULL)
	AND
	(extension = @extension OR @extension IS NULL)
	AND
	([description] = @description OR @extension IS NULL)

END
GO
