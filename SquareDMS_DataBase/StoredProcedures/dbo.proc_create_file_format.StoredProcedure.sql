USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_create_file_format]    Script Date: 30.12.2020 12:48:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- creates a file format 
CREATE PROCEDURE [dbo].[proc_create_file_format]
	@userId int,
	@extension nvarchar(max),
	@description nvarchar(max),
	@errorCode int OUTPUT,
	@createdFileFormats int OUTPUT,
	@createdId int OUTPUT
AS
BEGIN

	DECLARE @extValid nvarchar(250);
	DECLARE @descValid nvarchar(250);
	
	SET @errorCode = 0;
	SET @createdFileFormats = 0;
	
	DECLARE @isAdmin BIT;

	EXEC proc_trim_and_truncate_string @input = @extension, @output = @extValid OUTPUT;

	SET @extValid = UPPER(@extValid);

	-- extension param check
	IF (LEN(@extValid) = 0 OR @extValid IS NULL)
	BEGIN
		SET @errorCode = 107;
		RETURN;
	END

	EXEC proc_trim_and_truncate_string @input = @description, @output = @descValid OUTPUT;

	-- check if user is admin
	EXEC proc_is_user_admin @userId = @userId, @result = @isAdmin OUTPUT;

	IF (@isAdmin = 0)
	BEGIN
		SET @errorCode = 10;
		RETURN;
	END

	-- delete Dot (.) from the beginning of the extension if its present.
	IF (LEFT(@extValid, 1) = '.')
	BEGIN
		SET @extValid = REPLACE(@extValid, '.', '')
	END

	INSERT INTO [File_Format]
	VALUES (@extValid, ISNULL(@descValid, ''));

	SET @createdId = SCOPE_IDENTITY();

	SET @createdFileFormats = @@ROWCOUNT;
END

GO
