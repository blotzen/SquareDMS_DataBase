USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_delete_user]    Script Date: 30.12.2020 12:48:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- deletes a user if the user
-- is not the creator of any documents
-- and the requesting user is admin.
CREATE PROCEDURE [dbo].[proc_delete_user]
	@userId int,
	@deleteUserId int,
	@errorCode int OUTPUT,
	@deletedGroupMembers int OUTPUT,
	@deletedUsers int OUTPUT
AS
BEGIN

	DECLARE @isAdmin BIT;

	SET @errorCode = 0;
	SET @deletedUsers = 0;
	SET @deletedGroupMembers = 0;
	
	--invalid param check 
	IF @userId IS NULL AND @deleteUserId IS NULL
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


	-- check if user created documents // transaction?
	IF (SELECT COUNT(*) FROM Document WHERE creator_id = @deleteUserId) > 0
	BEGIN
		SET @errorCode = 127;
		RETURN;
	END


	BEGIN TRAN
	BEGIN TRY
		
		DECLARE @innerErrorCode int;

		-- deletes all rights for this document - groupId is not needed.
		EXEC proc_delete_group_member_s @userId = @userId, @groupId = NULL, @memberId = @deleteUserId, @errorCode = @innerErrorCode OUTPUT, @deletedGroupMembers = @deletedGroupMembers OUTPUT;

		DELETE FROM [User]
		WHERE 
		id = @deleteUserId

		SET @deletedUsers = @@ROWCOUNT;

	END TRY
	BEGIN CATCH
		DECLARE @error nvarchar(max);
		SET @error = ERROR_MESSAGE();
		ROLLBACK TRAN; -- error rolls back transaction

		SET @errorCode = 103;
	END CATCH

	IF @@TRANCOUNT > 0 -- running transaction is commited
	BEGIN
		COMMIT TRAN;
	END

END

GO
