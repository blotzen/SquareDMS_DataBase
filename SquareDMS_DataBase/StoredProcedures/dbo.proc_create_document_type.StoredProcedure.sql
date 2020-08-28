USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_create_document_type]    Script Date: 28.08.2020 21:05:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Creates a Document Type and validates the input
CREATE PROCEDURE [dbo].[proc_create_document_type]
	@userId int,
	@name nvarchar(250),
	@description nvarchar(250),
	@errorCode int OUTPUT,
	@createdDocumentTypes int OUTPUT
AS
BEGIN
	
	SET @errorCode = 0;
	SET @createdDocumentTypes = 0;

	DECLARE @isAdmin BIT;

	SET @name = LTRIM(RTRIM(@name));

	-- validates name param
	IF (@name IS NULL OR LEN(@name) = 0)
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

	-- prepare param description
	IF (@description IS NOT NULL)
	BEGIN
		SET @description = LTRIM(RTRIM(@description));

		IF (LEN(@description) = 0)
		BEGIN
			SET @description = NULL;
		END
	END

	-- check if document type exists already by name // maybe transaction? race condition
	IF (SELECT COUNT(*) FROM Document_Type WHERE name = @name) > 0 
	BEGIN
		SET @errorCode = 109;
		RETURN;
	END

	INSERT INTO Document_Type
	VALUES (@name, @description);

	SET @createdDocumentTypes = @@ROWCOUNT;

END
GO
