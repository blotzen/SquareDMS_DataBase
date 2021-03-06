USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_delete_group]    Script Date: 30.12.2020 12:48:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- delete group if user is admin and
-- group has no members. Deletes
-- rights that reference the group.
CREATE PROCEDURE [dbo].[proc_delete_group]
	@userId int,
	@groupId int,
	@deletedRights int OUTPUT,
	@errorCode int OUTPUT,
	@deletedGroups int OUTPUT
AS
BEGIN
	
	DECLARE @isAdmin BIT;

	SET @errorCode = 0;
	SET @deletedRights = 0;
	SET @deletedGroups = 0;

	-- param check
	IF (@userId IS NULL OR @groupId IS NULL)
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

	-- check if group is empty
	IF (SELECT COUNT(*) FROM Group_Member WHERE group_id = @groupId) > 0 
	BEGIN
		SET @errorCode = 105;
		RETURN;
	END

	-- delete an empty group and the depending rights
	BEGIN TRAN
	BEGIN TRY

		DECLARE @innerErrorCode int;
		
		-- deletes all rights for this group
		EXEC proc_delete_right_s @userId = @userId, @groupId = @groupId, @docId = NULL, @errorCode = @innerErrorCode OUTPUT, @deletedRights = @deletedRights OUTPUT;

		DELETE FROM [Group]
		WHERE [Group].id = @groupId;

		SET @deletedGroups = @@ROWCOUNT;

	END TRY
	BEGIN CATCH
		DECLARE @error nvarchar(max);
		SET @error = ERROR_MESSAGE();
		ROLLBACK TRAN; -- error rolls back transaction

		SET @errorCode = 104;
	END CATCH

	IF @@TRANCOUNT > 0 -- running transaction is commited
	BEGIN
		COMMIT TRAN;
	END
END

GO
