USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_get_document_s]    Script Date: 30.12.2020 12:48:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- 
CREATE PROCEDURE [dbo].[proc_get_document_s]
	@userId int,
	@maxAccessLevel int = NULL,
	@docId int = NULL,
	@creatorId int = NULL,
	@docTypeId int = NULL,
	@name nvarchar(max) = NULL,
	@locked BIT = NULL,
	@discard BIT = NULL,
	@errorCode int OUTPUT
AS
BEGIN

	DECLARE @preparedName nvarchar(max);
	EXEC proc_trim_and_truncate_string @input = @name, @output = @preparedName OUTPUT;

	SET @errorCode = 0;

	-- if invalid user is supplied just return
	IF @userId IS NULL 
	BEGIN		
		RETURN;
	END

	-- invalid access Level supplied
	IF (@maxAccessLevel NOT IN (100, 200, 300))
	BEGIN
		SET @errorCode = 112;
		RETURN;
	END

	-- check if given user is admin
	DECLARE @isAdmin BIT;
	EXEC proc_is_user_admin @userId = @userId, @result = @isAdmin OUTPUT;

		
	-- admins can also query by creator id
	IF @isAdmin = 1
	BEGIN
		SELECT DISTINCT
		doc.id Id,
		doc.creator_id Creator,
		doc.document_type DocumentType,
		doc.[name] Name,
		doc.locked Locked,
		doc.discard Discard
		FROM Document doc
		LEFT JOIN [Right] ON doc.id = [Right].document_id
		LEFT JOIN [Group] ON [Right].group_id = [Group].id
		LEFT JOIN Group_Member ON [Group].id = Group_Member.group_id
		LEFT JOIN [User] ON Group_Member.[user_id] = [User].id
		WHERE 
		(doc.creator_id = @creatorId OR @creatorId IS NULL)
		AND
		([Right].access_level <= @maxAccessLevel OR @maxAccessLevel IS NULL)
		AND
		(doc.document_type = @docTypeId OR @docTypeId IS NULL)
		AND
		(doc.[Name] = @preparedName OR @name IS NULL)
		AND 
		(doc.locked = @locked OR @locked IS NULL)
		AND
		(doc.discard = @discard OR @discard IS NULL)
		AND 
		(doc.id = @docId OR @docId IS NULL)

		RETURN;
	END
	-- users must have rights on the document
	-- or must be the creator of the document
	ELSE
	BEGIN

		SELECT DISTINCT
		doc.id Id,
		doc.creator_id Creator,
		doc.document_type DocumentType,
		doc.[name] Name,
		doc.locked Locked,
		doc.discard Discard
		FROM Document doc
		LEFT JOIN [Right] ON doc.id = [Right].document_id
		LEFT JOIN [Group] ON [Right].group_id = [Group].id
		LEFT JOIN Group_Member ON [Group].id = Group_Member.group_id
		LEFT JOIN [User] ON Group_Member.[user_id] = [User].id
		WHERE 
		(([User].id = @userId) OR (doc.creator_id = @userId))
		AND
		([Right].access_level <= @maxAccessLevel OR @maxAccessLevel IS NULL)
		AND
		(doc.document_type = @docTypeId OR @docTypeId IS NULL)
		AND
		(doc.[Name] = @preparedName OR @name IS NULL)
		AND 
		(doc.locked = @locked OR @locked IS NULL)
		AND
		(doc.discard = @discard OR @discard IS NULL)
		AND
		(doc.creator_id = @creatorId OR @creatorId IS NULL)
		AND
		(doc.id = @docId OR @docId IS NULL)

		RETURN;
	END

END

GO
