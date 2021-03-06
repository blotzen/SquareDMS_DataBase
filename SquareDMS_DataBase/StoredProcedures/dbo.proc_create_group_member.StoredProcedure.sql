USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_create_group_member]    Script Date: 30.12.2020 12:48:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- creats a group member, if user is admin
-- and group member does not exist already.
CREATE PROCEDURE [dbo].[proc_create_group_member]
	@userId int,
	@memberId int,
	@groupId int,
	@errorCode int OUTPUT,
	@createdGroupMembers int OUTPUT,
	@createdGroupId int OUTPUT,
	@createdMemberId int OUTPUT
AS
BEGIN

	DECLARE @isAdmin BIT;

	SET @errorCode = 0;
	SET @createdGroupMembers = 0;

	--invalid param check; groupId and docId get checked further down
	IF @userId IS NULL
	BEGIN
		RETURN;
	END


	--check if user is admin
	EXEC proc_is_user_admin @userId, @result = @isAdmin OUTPUT;

	IF @isAdmin = 0
	BEGIN
		SET @errorCode = 10;
		RETURN;
	END

	-- check if grop exists
	IF (SELECT COUNT(*) FROM [Group] WHERE [Group].id = @groupId) = 0
	BEGIN
		SET @errorCode = 113;
		RETURN;
	END

	-- check if user as member exists
	IF (SELECT COUNT(*) FROM [User] WHERE [User].id = @memberId) = 0
	BEGIN
		SET @errorCode = 116;
		RETURN;
	END

	-- check if group member already exists
	IF (SELECT COUNT(*) FROM [Group_Member] WHERE group_id = @groupId AND user_id = @memberId) <> 0
	BEGIN 
		SET @errorCode = 117;
		RETURN;
	END

	INSERT INTO [Group_Member]
	VALUES (@groupId, @memberId);

	SET @createdGroupMembers = @@ROWCOUNT;

	SET @createdGroupId = @groupId;
	SET @createdMemberId = @memberId;
END

GO
