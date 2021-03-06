USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_update_document_type]    Script Date: 30.12.2020 12:48:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- updates a document type. only admin can update
CREATE PROCEDURE [dbo].[proc_update_document_type]
	@userId int,
	@docTypeId int,
	@name nvarchar(max),
	@description nvarchar(max),
	@errorCode int OUTPUT,
	@updatedDocumentTypes int OUTPUT
AS
BEGIN

	DECLARE @nameValid nvarchar(250);
	DECLARE @descValid nvarchar(250);

	SET @errorCode = 0;
	SET @updatedDocumentTypes = 0;

	DECLARE @isAdmin BIT;

	-- id param check
	IF (@docTypeId IS NULL)
	BEGIN
		RETURN;
	END

	EXEC proc_trim_and_truncate_string @input = @name, @output = @nameValid OUTPUT;
	EXEC proc_trim_and_truncate_string @input = @name, @output = @descValid OUTPUT;

	-- check if user is admin
	EXEC proc_is_user_admin @userId = @userId, @result = @isAdmin OUTPUT;

	IF (@isAdmin = 0)
	BEGIN
		SET @errorCode = 10;
		RETURN;
	END

	-- cant set empty name but null would work because then it wont be updated
	IF (@nameValid IS NOT NULL AND LEN(@nameValid) = 0)
	BEGIN
		SET @errorCode = 119;
		RETURN;
	END
	
	-- check if document type exists already by name // maybe transaction? race condition
	IF (SELECT COUNT(*) FROM Document_Type WHERE name = @nameValid) > 0 
	BEGIN
		SET @errorCode = 109;
		RETURN;
	END

	UPDATE Document_Type
	SET 
	[name] = ISNULL(@nameValid, (SELECT [name] FROM Document_Type WHERE id = @docTypeId)),
	[description] = ISNULL(@descValid, (SELECT [description] FROM Document_Type WHERE id = @docTypeId))
	WHERE id = @docTypeId;

	SET @updatedDocumentTypes = @@ROWCOUNT;
END

GO
