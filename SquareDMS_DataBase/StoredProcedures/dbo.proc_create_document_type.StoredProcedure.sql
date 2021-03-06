USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_create_document_type]    Script Date: 30.12.2020 12:48:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Creates a Document Type and validates the input
CREATE PROCEDURE [dbo].[proc_create_document_type]
	@userId int,
	@name nvarchar(max),
	@description nvarchar(max),
	@errorCode int OUTPUT,
	@createdDocumentTypes int OUTPUT,
	@createdId int OUTPUT
AS
BEGIN
	
	DECLARE @nameValid nvarchar(250);
	DECLARE @descValid nvarchar(250);

	SET @errorCode = 0;
	SET @createdDocumentTypes = 0;

	DECLARE @isAdmin BIT;

	EXEC proc_trim_and_truncate_string @input = @name, @output = @nameValid OUTPUT;

	-- validates name param
	IF (LEN(@nameValid) = 0 OR @nameValid IS NULL)
	BEGIN
		SET @errorCode = 119;
		RETURN;
	END

	-- check if user is admin
	EXEC proc_is_user_admin @userId = @userId, @result = @isAdmin OUTPUT;

	IF (@isAdmin = 0)
	BEGIN
		SET @errorCode = 10;
		RETURN;
	END

	EXEC proc_trim_and_truncate_string @input = @description, @output = @descValid OUTPUT;

	-- check if document type exists already by name // maybe transaction? race condition
	IF (SELECT COUNT(*) FROM Document_Type WHERE name = @nameValid) > 0 
	BEGIN
		SET @errorCode = 109;
		RETURN;
	END

	INSERT INTO Document_Type
	VALUES (@nameValid, ISNULL(@descValid, ''));

	SET @createdId = SCOPE_IDENTITY();

	SET @createdDocumentTypes = @@ROWCOUNT;

END

GO
