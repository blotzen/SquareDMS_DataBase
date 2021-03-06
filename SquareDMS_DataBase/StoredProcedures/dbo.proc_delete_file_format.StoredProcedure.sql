USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_delete_file_format]    Script Date: 30.12.2020 12:48:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- deletes a file format. Only admins can and file format
-- must not be used by any document formats.
CREATE PROCEDURE [dbo].[proc_delete_file_format]
	@userId int,
	@fileFormatId int,
	@errorCode int OUTPUT,
	@deletedFileFormats int OUTPUT
AS
BEGIN
	
	DECLARE @isAdmin BIT;

	SET @errorCode = 0;
	SET @deletedFileFormats = 0;

	-- check params
	IF @userId IS NULL OR @fileFormatId IS NULL
	BEGIN
		RETURN;
	END

	-- check if user is admin
	EXEC proc_is_user_admin @userID = @userID, @result = @isAdmin OUTPUT;

	IF @isAdmin = 0 
	BEGIN
		SET @errorCode = 10;
		RETURN;
	END

	-- check if file format is currently used by any Document_Versions
	IF (SELECT COUNT(*) FROM Document_Version WHERE Document_Version.file_format_id = @fileFormatId) > 0
	BEGIN
		SET @errorCode = 106;
		RETURN;
	END

	DELETE FROM File_Format
	WHERE File_Format.id = @fileFormatId;

	SET @deletedFileFormats = @@ROWCOUNT;
END

GO
