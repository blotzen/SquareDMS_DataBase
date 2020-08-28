USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_update_group]    Script Date: 28.08.2020 21:05:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Updates a group. User has to be admin.
CREATE PROCEDURE [dbo].[proc_update_group]
	@userId int,
	@groupId int,
	@name nvarchar(250),
	@description nvarchar(250),
	@admin BIT,
	@creator BIT,
	@errorCode int OUTPUT,
	@updatedGroups int OUTPUT
AS
BEGIN
	
	SET @errorCode = 0;
	SET @updatedGroups = 0;
	
	DECLARE @isAdmin BIT;

	--invalid param check
	IF @userId IS NULL OR @groupId IS NULL
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

	-- checks the name parameter 
	IF (@name IS NOT NULL) AND (LEN(LTRIM(RTRIM(@name))) = 0)
	BEGIN
		SET @errorCode = 122;
		RETURN;
	END

	SET @name = LTRIM(RTRIM(@name));

	-- check the description parameter
	IF (LEN(LTRIM(RTRIM(@description))) = 0)
	BEGIN
		SET @description = NULL;
	END

	SET @description = LTRIM(RTRIM(@description));

	UPDATE [Group]
	SET
	[name] = ISNULL(@name, (SELECT [name] FROM [Group] WHERE id = @groupId)),
	[description] = ISNULL(@description, (SELECT [description] FROM [Group] WHERE id = @groupId)),
	[admin] = ISNULL(@admin, (SELECT [admin] FROM [Group] WHERE id = @groupId)),
	[creator] = ISNULL(@creator, (SELECT [creator] FROM [Group] WHERE id = @groupId))
	WHERE id = @groupId;

	SET @updatedGroups = @@ROWCOUNT;

END
GO
