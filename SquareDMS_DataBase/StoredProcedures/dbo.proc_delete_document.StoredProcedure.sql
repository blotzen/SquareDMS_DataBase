USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_delete_document]    Script Date: 30.12.2020 12:48:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- deletes a document, its right and its versions if the 
-- doc isnt locked and the user is an admin.
CREATE PROCEDURE [dbo].[proc_delete_document]
	@userId int,
	@docId int,
	@deletedRights int OUTPUT,
	@deletedDocVersions int OUTPUT,
	@errorCode int OUTPUT,
	@deletedDocuments int OUTPUT
AS
BEGIN	
	
	SET @deletedRights = 0;
	SET @deletedDocVersions = 0;
	SET @errorCode = 0;	
	SET @deletedDocuments = 0;

	DECLARE @isAdmin BIT;
	DECLARE @isDocLocked BIT;

	-- param check
	IF @userId IS NULL OR @docId IS NULL 
	BEGIN
		RETURN;
	END

	-- check if the user is admin and allowed to delete
	EXEC proc_is_user_admin @userId = @userId, @result = @isAdmin OUTPUT;

	-- if user is no admin, he is not allowed to delete
	IF @isAdmin = 0 
	BEGIN
		SET @errorCode = 10;
		RETURN;
	END

	-- check if the document is locked
	EXEC proc_is_doc_locked @docId = @docId, @result = @isDocLocked OUTPUT;

	-- document is locked and cant be deleted
	IF @isDocLocked = 1 
	BEGIN
		SET @errorCode = 11;
		RETURN;
	END

	-- user is admin and doc is not locked, so we can delete the rights and 
	-- then the document. This happens in a transaction. So no inconsistent
	-- state remains if one operation fails.

	BEGIN TRAN
	BEGIN TRY
		
		DECLARE @innerErrorCode int;

		-- deletes all rights for this document - groupId is not needed.
		EXEC proc_delete_right_s @userId = @userId, @groupId = NULL, @docId = @docId, @errorCode = @innerErrorCode OUTPUT, @deletedRights = @deletedRights OUTPUT;

		-- delete doc versions 
		DELETE FROM Document_Version 
		WHERE Document_Version.document_id = @docId;

		SET @deletedDocVersions = @@ROWCOUNT; -- get amount of deleted doc versions

		-- finally delete the document
		DELETE FROM Document
		WHERE Document.id = @docId;

		SET @deletedDocuments = @@ROWCOUNT;

	END TRY
	BEGIN CATCH
		DECLARE @error nvarchar(max);
		SET @error = ERROR_MESSAGE();
		ROLLBACK TRAN; -- error rolls back transaction

		SET @errorCode = 100;
	END CATCH

	IF @@TRANCOUNT > 0 -- running transaction is commited
	BEGIN
		COMMIT TRAN;
	END
END;

GO
