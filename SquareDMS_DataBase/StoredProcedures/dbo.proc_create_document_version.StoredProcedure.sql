USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_create_document_version]    Script Date: 30.12.2020 12:48:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- creates a document version, if the user is a admin 
-- or has at least the edit right on the given document.
-- Also the referencing document and file format have to exist.
CREATE PROCEDURE [dbo].[proc_create_document_version]
	@userId int,
	@docId int,
	@fileFormatId int,
	@errorCode int OUTPUT,
	@createdDocumentVersions int OUTPUT,
	@transactionContext varbinary(max) OUTPUT,
	@filePath nvarchar(max) OUTPUT,
	@createdId int OUTPUT
AS
BEGIN

	DECLARE @isAdmin BIT;
	DECLARE @maxAccessLevel int;
	DECLARE @isCreatorOfDoc BIT;

	SET @errorCode = 0;
	SET @createdDocumentVersions = 0;
	SET @createdId = NULL;
	SET @isCreatorOfDoc = 0;

	-- check params
	IF @userId IS NULL OR @docId IS NULL OR @fileFormatId IS NULL
	BEGIN
		SET @errorCode = 1;
		RETURN;
	END
	
	--check if user is admin
	EXEC proc_is_user_admin @userId, @result = @isAdmin OUTPUT;

	-- if user is creator of document he can add a new version
	IF (SELECT creator_id FROM Document WHERE id = @docId) = @userId
	BEGIN
		SET @isCreatorOfDoc = 1;
	END



	-- if user is no admin, we need to check the rights
	IF @isAdmin = 0
	BEGIN
		EXEC proc_get_max_user_right_on_document @userId = @userId, @docId = @docId, @maxAccessLevel = @maxAccessLevel OUTPUT;
	END

	-- return with error if permissions dont fit
	IF @isAdmin = 0 AND @maxAccessLevel < 200 AND @isCreatorOfDoc = 0
	BEGIN
		SET @errorCode = 12;
		RETURN;
	END
	
	-- check if related document exists
	IF (SELECT COUNT(*) FROM Document WHERE id = @docId) = 0
	BEGIN
		SET @errorCode = 114;
		RETURN;
	END

	-- check if related fileFormat exists
	IF (SELECT COUNT(*) FROM [File_Format] WHERE id = @fileFormatId) = 0
	BEGIN
		SET @errorCode = 118;
		RETURN;
	END

	
	DECLARE @uid uniqueidentifier;
	SET @uid = NEWID();

	-- insert metadata
	INSERT INTO Document_Version
	VALUES (@docId, GETDATE(),
	ISNULL((SELECT MAX(version_nr) FROM Document_Version WHERE document_id = @docId), 0) + 1,
	@fileFormatId,
	@uid,
	CAST ('' as varbinary(max)));

	SET @createdDocumentVersions = @@ROWCOUNT;
	SET @createdId = SCOPE_IDENTITY();

	-- get context and path
	SET @transactionContext = GET_FILESTREAM_TRANSACTION_CONTEXT();
	SELECT @filePath = filestream_data.PathName() FROM Document_Version WHERE [guid] = @uid;

END
GO
