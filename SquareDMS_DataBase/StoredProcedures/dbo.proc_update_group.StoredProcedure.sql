USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_update_group]    Script Date: 30.12.2020 12:48:02 ******/
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

	DECLARE @nameValid nvarchar(250);
	DECLARE @descValid nvarchar(250);
	
	SET @errorCode = 0;
	SET @updatedGroups = 0;
	
	DECLARE @isAdmin BIT;

	--invalid param check
	IF @userId IS NULL OR @groupId IS NULL
	BEGIN
		RETURN;
	END

	EXEC proc_trim_and_truncate_string @input = @name, @output = @nameValid OUTPUT;
	EXEC proc_trim_and_truncate_string @input = @description, @output = @descValid OUTPUT;

	--check if user is admin
	EXEC proc_is_user_admin @userId, @result = @isAdmin OUTPUT;

	IF @isAdmin = 0
	BEGIN
		SET @errorCode = 10;
		RETURN;
	END

	-- checks the name parameter 
	IF (@nameValid IS NOT NULL AND LEN(@nameValid) = 0)
	BEGIN
		SET @errorCode = 122;
		RETURN;
	END

	UPDATE [Group]
	SET
	[name] = ISNULL(@nameValid, (SELECT [name] FROM [Group] WHERE id = @groupId)),
	[description] = ISNULL(@descValid, (SELECT [description] FROM [Group] WHERE id = @groupId)),
	[admin] = ISNULL(@admin, (SELECT [admin] FROM [Group] WHERE id = @groupId)),
	[creator] = ISNULL(@creator, (SELECT [creator] FROM [Group] WHERE id = @groupId))
	WHERE id = @groupId;

	SET @updatedGroups = @@ROWCOUNT;

END

GO
