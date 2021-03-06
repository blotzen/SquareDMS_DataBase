USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_create_right]    Script Date: 30.12.2020 12:48:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- creates a right and checks if group and doc 
-- already have a common right. Also checks 
-- if the access level is valid and the user 
-- is admin.
CREATE PROCEDURE [dbo].[proc_create_right]
	@userId int,
	@groupId int,
	@docId int,
	@accessLevel int,
	@errorCode int OUTPUT,
	@createdRights int OUTPUT,
	@createdGroupId int OUTPUT,
	@createdDocId int OUTPUT
AS
BEGIN
	
	DECLARE @isAdmin BIT;

	SET @errorCode = 0;
	SET @createdRights = 0;

	--invalid param check; groupId and docId get checked further down
	IF @userId IS NULL
	BEGIN
		RETURN;
	END

	--invalid access Level check
	IF @accessLevel NOT IN (100, 200, 300) 
	BEGIN
		SET @errorCode = 112;
		RETURN;
	END

	--check if user is admin
	EXEC proc_is_user_admin @userId, @result = @isAdmin OUTPUT;

	IF @isAdmin = 0
	BEGIN
		SET @errorCode = 10;
		RETURN;
	END

	--check if group exists
	IF (SELECT COUNT(*) FROM [Group] WHERE id = @groupId) = 0
	BEGIN
		SET @errorCode = 113;
		RETURN;
	END

	--check if doc exists
	IF (SELECT COUNT(*) FROM [Document] WHERE id = @docId) = 0
	BEGIN
		SET @errorCode = 114;
		RETURN;
	END

	--check if group and doc already have common right
	IF (SELECT COUNT(*) FROM [Right] WHERE group_id = @groupId AND document_id = @docId) <> 0
	BEGIN
		SET @errorCode = 111;
		RETURN;
	END

	INSERT INTO [Right]
	VALUES (@groupId, @docId, @accessLevel);

	SET @createdGroupId = @groupId;
	SET @createdDocId = @docId;

	SET @createdRights = @@ROWCOUNT;
END

GO
