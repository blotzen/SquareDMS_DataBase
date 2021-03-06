USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_delete_right_s]    Script Date: 30.12.2020 12:48:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- deletes a right if user is admin
CREATE PROCEDURE [dbo].[proc_delete_right_s]
	@userId int,
	@groupId int,
	@docId int,
	@errorCode int OUTPUT,
	@deletedRights int OUTPUT
AS
BEGIN
	
	DECLARE @isAdmin BIT;

	SET @errorCode = 0;
	SET @deletedRights = 0;

	-- no valid parameter has been supplied.
	IF @groupId IS NULL AND @docId IS NULL
	BEGIN
		SET @deletedRights = 0;
		RETURN;
	END

	-- check if user is admin
	EXEC proc_is_user_admin @userID = @userID, @result = @isAdmin OUTPUT;

	IF @isAdmin = 0 
	BEGIN
		SET @errorCode = 10;
		RETURN;
	END

	DELETE FROM [Right]
	WHERE (group_id = @groupId OR (@groupId IS NULL))
	AND (document_id = @docId OR (@docId IS NULL));

	SET @deletedRights = @@ROWCOUNT;
END

GO
