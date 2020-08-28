USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_update_file_format]    Script Date: 28.08.2020 21:05:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- updates a file format, user has to be admin.
CREATE PROCEDURE [dbo].[proc_update_file_format]
	@userId int,
	@fileFormatId int,
	@extension nvarchar(250),
	@description nvarchar(250),
	@errorCode int OUTPUT,
	@updatedFileFormats int OUTPUT
AS
BEGIN

	SET @errorCode = 0;
	SET @updatedFileFormats = 0;
	
	DECLARE @isAdmin BIT;

	-- param check
	IF @userId IS NULL OR @fileFormatId IS NULL
	BEGIN
		RETURN;
	END

	SET @extension = UPPER(LTRIM(RTRIM(@extension)));

	-- extension param check
	IF (LEN(LTRIM(RTRIM(@extension))) = 0)
	BEGIN
		SET @errorCode = 107;
		RETURN;
	END

	SET @description = LTRIM(RTRIM(@description));

	-- edit empty description to NULL
	IF LEN(@description) = 0
	BEGIN
		SET @description = NULL;
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
	extension = ISNULL(@extension, (SELECT extension FROM [File_Format] WHERE [File_Format].id = @fileFormatId)),
	description = ISNULL(@description, (SELECT description FROM [File_Format] WHERE [File_Format].id = @fileFormatId))
	WHERE id = @fileFormatId;

	SET @updatedFileFormats = @@ROWCOUNT;
END
GO
