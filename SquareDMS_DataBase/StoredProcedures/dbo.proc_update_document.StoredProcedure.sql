USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_update_document]    Script Date: 28.08.2020 21:05:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- 
CREATE PROCEDURE [dbo].[proc_update_document]
	@userId int,
	@docId int,
	@docTypeId int,
	@name nvarchar(250),
	@locked BIT,
	@discard BIT,
	@errorCode int OUTPUT,
	@updatedDocuments int OUTPUT
AS
BEGIN
	
	DECLARE @isDocDiscarded BIT;
	DECLARE @isDocLocked BIT;
	DECLARE @isCreator BIT;
	DECLARE @isAdmin BIT;

	SET @errorCode = 0;
	SET @updatedDocuments = 0;

	SET @name = LTRIM(RTRIM(@name));

	-- invalid parameter check
	IF @userId IS NULL OR @docId IS NULL
	BEGIN
		RETURN;
	END

	-- check if user is admin
	EXEC proc_is_user_admin @userId = @userId, @result = @isAdmin OUTPUT;

	-- check if document is discarded	
	EXEC proc_is_doc_discarded @docId = @docId, @result = @isDocDiscarded OUTPUT;

	-- if the document is discarded and wont get reactivated in this command it cant
	-- be modified until the discard flag has been removed.
	IF (@isDocDiscarded = 1 AND (@discard IS NULL OR @discard = 1))
	BEGIN
		SET @errorCode = 121;
		RETURN;
	END

	-- checks if document is locked
	EXEC proc_is_doc_locked @docId = @docId, @result = @isDocLocked OUTPUT;

	-- if doc is locked and wont get unlocked in this command 
	IF (@isDocLocked = 1 AND @locked IS NULL)
	BEGIN
		SET @errorCode = 11;
		RETURN
	END

	-- check if user is creator of the doc	
	IF ((SELECT creator_id FROM Document WHERE id = @docId) = @userId) 
	BEGIN
		SET @isCreator = 1;
	END
	ELSE
	BEGIN
		SET @isCreator = 0;
	END

	-- permission check if user is not the creator and not admin 
	IF @isCreator = 0 AND @isAdmin = 0
	BEGIN

		-- gets the maximum user right for the user on the document
		DECLARE @maxUserRightOnDocument int;
		EXEC proc_get_max_user_right_on_document @userId = @userId, @docId = @docId, @maxAccessLevel = @maxUserRightOnDocument OUTPUT;

		IF (@maxUserRightOnDocument < 300 AND @discard IS NOT NULL)
		BEGIN
			SET @errorCode = 12;
			RETURN;
		END

		IF (@maxUserRightOnDocument < 200)
		BEGIN
			SET @errorCode = 12;
			RETURN;
		END

	END


	--invalid empty name
	IF (LEN(@name) = 0)
	BEGIN
		SET @errorCode = 120;
		RETURN;
	END

	-- update documents values when they are different than NULL
	UPDATE [Document]
	SET 
	document_type = ISNULL(@docTypeId, (SELECT document_type FROM Document WHERE id = @docId)),
	[name] = ISNULL(@name, (SELECT [name] FROM Document WHERE id = @docId)),
	locked = ISNULL(@locked, (SELECT locked FROM Document WHERE id = @docId)),
	discard = ISNULL(@discard, (SELECT discard FROM Document WHERE id = @docId))
	WHERE id = @docId;

	SET @updatedDocuments = @@ROWCOUNT;
END
GO
