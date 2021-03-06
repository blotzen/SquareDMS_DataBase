USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_update_file_format]    Script Date: 30.12.2020 12:48:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- updates a file format, user has to be admin.
CREATE PROCEDURE [dbo].[proc_update_file_format]
	@userId int,
	@fileFormatId int,
	@extension nvarchar(max),
	@description nvarchar(max),
	@errorCode int OUTPUT,
	@updatedFileFormats int OUTPUT
AS
BEGIN

	DECLARE @extValid nvarchar(250);
	DECLARE @descValid nvarchar(250);

	SET @errorCode = 0;
	SET @updatedFileFormats = 0;
	
	DECLARE @isAdmin BIT;

	-- param check
	IF @userId IS NULL OR @fileFormatId IS NULL
	BEGIN
		RETURN;
	END

	EXEC proc_trim_and_truncate_string @input = @extension, @output = @extValid OUTPUT;
	EXEC proc_trim_and_truncate_string @input = @description, @output = @descValid OUTPUT;

	-- if the extension gets changed but to a empty value this cannot be done
	IF (@extension IS NOT NULL AND LEN(@extension) = 0)
	BEGIN
		SET @errorCode = 107;
		RETURN;
	END

	-- check if user is admin
	EXEC proc_is_user_admin @userId = @userId, @result = @isAdmin OUTPUT;

	IF (@isAdmin = 0)
	BEGIN
		SET @errorCode = 10;
		RETURN;
	END

	-- delete Dot (.) from the beginning of the extension if its present.
	IF (LEFT(@extension, 1) = '.')
	BEGIN
		SET @extension = REPLACE(@extension, '.', '')
	END

	UPDATE [File_Format]
	SET 
	extension = ISNULL(@extValid, (SELECT extension FROM [File_Format] WHERE [File_Format].id = @fileFormatId)),
	description = ISNULL(@descValid, (SELECT description FROM [File_Format] WHERE [File_Format].id = @fileFormatId))
	WHERE id = @fileFormatId;

	SET @updatedFileFormats = @@ROWCOUNT;
END

GO
