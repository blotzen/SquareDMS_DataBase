USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_create_file_format]    Script Date: 28.08.2020 21:05:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- creates a file format 
CREATE PROCEDURE [dbo].[proc_create_file_format]
	@userId int,
	@extension nvarchar(250),
	@description nvarchar(250),
	@errorCode int OUTPUT,
	@createdFileFormats int OUTPUT
AS
BEGIN

	SET @errorCode = 0;
	SET @createdFileFormats = 0;
	
	DECLARE @isAdmin BIT;

	SET @extension = UPPER(LTRIM(RTRIM(@extension)));

	-- extension param check
	IF (@extension IS NULL OR LEN(@extension) = 0)
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

	INSERT INTO [File_Format]
	VALUES (@extension, @description);

	SET @createdFileFormats = @@ROWCOUNT;
END
GO
