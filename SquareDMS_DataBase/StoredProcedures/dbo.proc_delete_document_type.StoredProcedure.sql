USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_delete_document_type]    Script Date: 30.12.2020 12:48:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- delete document type. Possible if user is admin
-- and if doc type isnt currently in use by any document.
CREATE PROCEDURE [dbo].[proc_delete_document_type]
	@userId int,
	@docTypeId int,
	@errorCode int OUTPUT,
	@deletedDocumentTypes int OUTPUT
AS
BEGIN

	SET @errorCode = 0;
	SET @deletedDocumentTypes = 0;
	
	DECLARE @isAdmin BIT;

	-- id param check
	IF (@docTypeId IS NULL)
	BEGIN
		RETURN;
	END

	-- check if user is admin
	EXEC proc_is_user_admin @userId = @userId, @result = @isAdmin OUTPUT;

	IF (@isAdmin = 0)
	BEGIN
		SET @errorCode = 10;
		RETURN;
	END

	--check if doctype is currently in use
	IF (SELECT COUNT(*) FROM Document WHERE Document.document_type = @docTypeId) > 0
	BEGIN
		SET @errorCode = 108;
		RETURN;
	END

	DELETE FROM Document_Type WHERE id = @docTypeId;

	SET @deletedDocumentTypes = @@ROWCOUNT;
END

GO
