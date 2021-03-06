USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_delete_group_member_s]    Script Date: 30.12.2020 12:48:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- deletes one or more group members
CREATE PROCEDURE [dbo].[proc_delete_group_member_s]
	@userId int,
	@groupId int,
	@memberId int,
	@errorCode int OUTPUT,
	@deletedGroupMembers int OUTPUT
AS
BEGIN

	DECLARE @isAdmin BIT;

	SET @errorCode = 0;
	SET @deletedGroupMembers = 0;


	-- no valid parameter has been supplied.
	IF @groupId IS NULL AND @memberId IS NULL
	BEGIN
		SET @deletedGroupMembers = 0;
		RETURN;
	END

	-- check if user is admin
	EXEC proc_is_user_admin @userID = @userID, @result = @isAdmin OUTPUT;

	IF @isAdmin = 0 
	BEGIN
		SET @errorCode = 10;
		RETURN;
	END


	DELETE FROM [Group_Member]
	WHERE 
	([user_id] = @memberId OR @memberId IS NULL)
	AND 
	(group_id = @groupId OR @groupId IS NULL);

	SET @deletedGroupMembers = @@ROWCOUNT;
END

GO
