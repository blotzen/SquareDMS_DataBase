USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_update_document_type]    Script Date: 28.08.2020 21:05:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- updates a document type. only admin can update
CREATE PROCEDURE [dbo].[proc_update_document_type]
	@userId int,
	@docTypeId int,
	@name nvarchar(250),
	@description nvarchar(250),
	@errorCode int OUTPUT,
	@updatedDocumentTypes int OUTPUT
AS
BEGIN

	SET @errorCode = 0;
	SET @updatedDocumentTypes = 0;

	DECLARE @isAdmin BIT;

	-- id param check
	IF (@docTypeId IS NULL)
	BEGIN
		RETURN;
	END

	SET @name = LTRIM(RTRIM(@name));

	-- validates name param
	IF (LEN(@name) = 0)
	BEGIN
		SET @name = NULL;
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

	UPDATE Document_Type
	SET 
	[name] = ISNULL(@name, (SELECT [name] FROM Document_Type WHERE id = @docTypeId)),
	[description] = ISNULL(@description, (SELECT [description] FROM Document_Type WHERE id = @docTypeId))
	WHERE id = @docTypeId;

	SET @updatedDocumentTypes = @@ROWCOUNT;
END
GO
