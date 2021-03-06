USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_create_group]    Script Date: 30.12.2020 12:48:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Creates a Group, checks the name and description input
CREATE PROCEDURE [dbo].[proc_create_group]
	@userId int,
	@name nvarchar(max),
	@description nvarchar(max),
	@admin BIT,
	@creator BIT,
	@errorCode int OUTPUT,
	@createdGroups int OUTPUT,
	@createdId int OUTPUT
AS
BEGIN

	DECLARE @nameValid nvarchar(250);
	DECLARE @descValid nvarchar(250);

	DECLARE @isAdmin BIT;

	SET @errorCode = 0;
	SET @createdGroups = 0;

	--invalid param check
	IF @userId IS NULL
	BEGIN
		RETURN;
	END

	EXEC proc_trim_and_truncate_string @input = @name, @output = @nameValid OUTPUT;

	-- checks the name parameter 
	IF (LEN(@nameValid) = 0 OR @nameValid IS NULL)
	BEGIN
		SET @errorCode = 122;
		RETURN;
	END


	EXEC proc_trim_and_truncate_string @input = @description, @output = @descValid OUTPUT;
	

	--check if user is admin
	EXEC proc_is_user_admin @userId, @result = @isAdmin OUTPUT;

	IF @isAdmin = 0
	BEGIN
		SET @errorCode = 10;
		RETURN;
	END

	INSERT INTO [Group]
	VALUES (@nameValid, ISNULL(@descValid, ''), ISNULL(@admin, 0), ISNULL(@creator, 0));

	SET @createdId = SCOPE_IDENTITY();

	SET @createdGroups = @@ROWCOUNT;

END

GO
