USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_get_document_version_s]    Script Date: 30.12.2020 12:48:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- gets all the metadata for the given docVersion. Also
-- checks the permissions of the given user.
CREATE PROCEDURE [dbo].[proc_get_document_version_s]
	@userId int,
	@docVerId int = NULL,
	@docId int = NULL,
	@errorCode int OUTPUT
AS
BEGIN


	DECLARE @isAdmin BIT;
	DECLARE @maxAccessLevel int;

	SET @errorCode = 0;

	-- check params
	IF @userId IS NULL
	BEGIN
		SET @errorCode = 1;
		RETURN;
	END

	-- both cant be null
	IF @docVerId IS NULL AND @docId IS NULL
	BEGIN
		SET @errorCode = 1;
		RETURN;
	END
	
	--check if user is admin
	EXEC proc_is_user_admin @userId, @result = @isAdmin OUTPUT;

	-- if the user is admin no further checks are needed.
	IF (@isAdmin = 1)
	BEGIN
		
		SELECT id,
		document_id DocumentId,
		event_datetime EventDateTime,
		version_nr VersionNr,
		file_format_id FileFormatId,
		GET_FILESTREAM_TRANSACTION_CONTEXT() as TransactionId,
		filestream_data.PathName() as FilePath
		FROM Document_Version
		WHERE (id = @docVerId OR @docVerId IS NULL)
		AND 
		(document_id = @docId OR @docId IS NULL);

		RETURN;
	END

	-- if docId is not supplied we get it from the documentVersionId
	IF @docId IS NULL
	BEGIN
		SELECT @docId = document_id FROM Document_Version WHERE id = @docVerId;
	END

	-- check if user is the creator of the document, if he is we select
	IF (SELECT creator_id FROM Document WHERE id = @docId) = @userId
	BEGIN
		
		SELECT id,
		document_id DocumentId,
		event_datetime EventDateTime,
		version_nr VersionNr,
		file_format_id FileFormatId,
		GET_FILESTREAM_TRANSACTION_CONTEXT() as TransactionId,
		filestream_data.PathName() as FilePath
		FROM Document_Version
		WHERE (id = @docVerId OR @docVerId IS NULL)
		AND 
		(document_id = @docId OR @docId IS NULL);

		RETURN;
	END

	-- if user is no admin and no creator of the document, we need to check the rights
	IF @isAdmin = 0
	BEGIN
		EXEC proc_get_max_user_right_on_document @userId = @userId, @docId = @docId, @maxAccessLevel = @maxAccessLevel OUTPUT;
	END

	-- return with error if permissions dont fit
	IF @isAdmin = 0 AND @maxAccessLevel < 100
	BEGIN
		SET @errorCode = 12;
		RETURN;
	END

	-- if permissions fit we select
	SELECT id,
	document_id DocumentId,
	event_datetime EventDateTime,
	version_nr VersionNr,
	file_format_id FileFormatId,
	GET_FILESTREAM_TRANSACTION_CONTEXT() as TransactionId,
	filestream_data.PathName() as FilePath
	FROM Document_Version
	WHERE (id = @docVerId OR @docVerId IS NULL)
	AND 
	(document_id = @docId OR @docId IS NULL);

	RETURN;
END
GO
