USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_update_right]    Script Date: 30.12.2020 12:48:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- updates a right if the user is admin
-- and the groupId and docId are valid
-- and the right exists already.
CREATE PROCEDURE [dbo].[proc_update_right]
	@userId int,
	@groupId int,
	@docId int,
	@accessLevel int,
	@errorCode int OUTPUT,
	@updatedRights int OUTPUT
AS
BEGIN
	
	DECLARE @isAdmin BIT;

	SET @errorCode = 0;
	SET @updatedRights = 0;

	-- param check
	IF @userId IS NULL OR @groupId IS NULL OR @docId IS NULL
	BEGIN
		RETURN;
	END

	-- check if user is admin
	EXEC proc_is_user_admin @userID = @userID, @result = @isAdmin OUTPUT;
	
	IF @isAdmin = 0 
	BEGIN
		SET @errorCode = 10;
		RETURN;
	END

	IF @accessLevel NOT IN (100, 200, 300)
	BEGIN
		SET @errorCode = 112;
		RETURN;
	END

	-- check if right exists // maybe with lock and transaction? right has
	-- to exists until update is done!
	IF (SELECT COUNT(*) FROM [Right] WHERE group_id = @groupId AND document_id = @docId) = 0
	BEGIN
		SET @errorCode = 115;
		RETURN;
	END

	UPDATE [Right]
	SET access_level = @accessLevel
	WHERE group_id = @groupId AND document_id = @docId;

	SET @updatedRights = @@ROWCOUNT;

END

GO
