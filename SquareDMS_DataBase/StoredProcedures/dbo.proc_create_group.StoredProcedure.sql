USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_create_group]    Script Date: 28.08.2020 21:05:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Creates a Group, checks the name and description input
CREATE PROCEDURE [dbo].[proc_create_group]
	@userId int,
	@name nvarchar(250),
	@description nvarchar(250),
	@admin BIT,
	@creator BIT,
	@errorCode int OUTPUT,
	@createdGroups int OUTPUT
AS
BEGIN

	DECLARE @isAdmin BIT;

	SET @errorCode = 0;
	SET @createdGroups = 0;

	--invalid param check
	IF @userId IS NULL
	BEGIN
		RETURN;
	END

	-- checks the name parameter 
	IF (@name IS NULL) OR (LEN(LTRIM(RTRIM(@name))) = 0)
	BEGIN
		SET @errorCode = 122;
		RETURN;
	END

	IF (LEN(LTRIM(RTRIM(@description))) = 0)
	BEGIN
		SET @description = NULL;
	END
	------------------------------------

	--check if user is admin
	EXEC proc_is_user_admin @userId, @result = @isAdmin OUTPUT;

	IF @isAdmin = 0
	BEGIN
		SET @errorCode = 10;
		RETURN;
	END

	INSERT INTO [Group]
	VALUES (@name, @description, @admin, @creator);

	SET @createdGroups = @@ROWCOUNT;

END
GO
