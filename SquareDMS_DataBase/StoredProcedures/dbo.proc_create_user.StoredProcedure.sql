USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_create_user]    Script Date: 30.12.2020 12:48:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- only admins can create user
CREATE PROCEDURE [dbo].[proc_create_user]
	@userId int,
	@lastName nvarchar(max),
	@firstName nvarchar(max),
	@userName nvarchar(max),
	@email nvarchar(max),
	@passwordHash binary(32),
	@active BIT,
	@errorCode int OUTPUT,
	@createdUsers int OUTPUT,
	@createdId int OUTPUT
AS
BEGIN

	DECLARE @lastNameValid nvarchar(250);
	DECLARE @firstNameValid nvarchar(250);
	DECLARE @userNameValid nvarchar(250);
	DECLARE @emailValid nvarchar(250);

	DECLARE @isAdmin BIT;

	SET @errorCode = 0;
	SET @createdUsers = 0;
	
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

	EXEC proc_trim_and_truncate_string @input = @lastName, @output = @lastNameValid OUTPUT;
	EXEC proc_trim_and_truncate_string @input = @firstName, @output = @firstNameValid OUTPUT;
	EXEC proc_trim_and_truncate_string @input = @username, @output = @userNameValid OUTPUT;
	EXEC proc_trim_and_truncate_string @input = @email, @output = @emailValid OUTPUT;

	-- check user last name
	IF @lastNameValid IS NULL OR LEN(@lastNameValid) = 0
	BEGIN
		SET @errorCode = 123;
		RETURN;
	END

	-- check username
	IF @userNameValid IS NULL OR LEN(@userNameValid) = 0
	BEGIN
		SET @errorCode = 124;
		RETURN;
	END

	-- check password hash
	IF @passwordHash IS NULL 
	BEGIN
		SET @errorCode = 125;
		RETURN;
	END

	-- validate active param
	IF @active IS NULL 
	BEGIN
		SET @active = 0;
	END

	-- check if username already exists
	IF (SELECT COUNT(*) FROM [User] WHERE [user_name] = @userNameValid) > 0
	BEGIN
		SET @errorCode = 126;
		RETURN;
	END

	-- insert user
	INSERT INTO [User]
	VALUES (@lastNameValid, ISNULL(@firstNameValid, ''), LOWER(@userNameValid), ISNULL(LOWER(@emailValid), ''), @passwordHash, @active);

	SET @createdId = SCOPE_IDENTITY();

	SET @createdUsers = @@ROWCOUNT;
END

GO
