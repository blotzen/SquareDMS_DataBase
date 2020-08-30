USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_create_user]    Script Date: 28.08.2020 21:05:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- only admins can create user
CREATE PROCEDURE [dbo].[proc_create_user]
	@userId int,
	@lastName nvarchar(250),
	@firstName nvarchar(250),
	@userName nvarchar(250),
	@email nvarchar(250),
	@passwordHash binary(32),
	@active BIT,
	@errorCode int OUTPUT,
	@createdUsers int OUTPUT
AS
BEGIN

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

	SET @lastName = LTRIM(RTRIM(@lastName));
	SET @firstName = LTRIM(RTRIM(@firstName));
	SET @username = LTRIM(RTRIM(@username));
	SET @email = LTRIM(RTRIM(@email));

	-- check user last name
	IF @lastName IS NULL OR LEN(@lastName) = 0 
	BEGIN
		SET @errorCode = 123;
		RETURN;
	END

	-- check username
	IF @userName IS NULL OR LEN(@userName) = 0
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
		
	-- validate firstname, no empty firstname
	IF LEN(@firstName) = 0
	BEGIN
		SET @firstName = NULL;
	END

	-- validate email
	IF LEN(@email) = 0
	BEGIN
		SET @email = NULL;
	END

	-- validate active param
	IF @active IS NULL 
	BEGIN
		SET @active = 0;
	END

	-- check if username already exists
	IF (SELECT COUNT(*) FROM [User] WHERE [user_name] = @userName) > 0
	BEGIN
		SET @errorCode = 126;
		RETURN;
	END

	-- insert user
	INSERT INTO [User]
	VALUES (@lastName, @firstName, LOWER(@username), LOWER(@email), @passwordHash, @active);

	SET @createdUsers = @@ROWCOUNT;
END
GO
