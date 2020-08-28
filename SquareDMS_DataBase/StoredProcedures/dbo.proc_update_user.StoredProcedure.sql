USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_update_user]    Script Date: 28.08.2020 21:05:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_update_user]
	@userId int,
	@updateUserId int,
	@lastName nvarchar(250),
	@firstName nvarchar(250),
	@userName nvarchar(250),
	@passwordHash binary(32),
	@active BIT,
	@errorCode int OUTPUT,
	@updatedUsers int OUTPUT
AS
BEGIN

	DECLARE @isAdmin BIT;

	SET @errorCode = 0;
	SET @updatedUsers = 0;
	
	--invalid param check 
	IF @userId IS NULL AND @updateUserId IS NULL
	BEGIN
		RETURN;
	END


	--check if user is admin
	EXEC proc_is_user_admin @userId, @result = @isAdmin OUTPUT;

	IF @isAdmin = 0 AND @userId <> @updateUserId
	BEGIN
		SET @errorCode = 15;
		RETURN;
	END

	SET @lastName = LTRIM(RTRIM(@lastName));
	SET @firstName = LTRIM(RTRIM(@firstName));
	SET @userName = LTRIM(RTRIM(@username));


	-- check user last name
	IF LEN(@lastName) = 0 
	BEGIN
		SET @lastName = NULL;
	END

	-- check firstname
	IF LEN(@firstName) = 0
	BEGIN
		SET @firstName = NULL;
	END

	-- check username blank
	IF LEN(@userName) = 0
	BEGIN
		SET @userName = NULL;
	END

	UPDATE [User]
	SET
	last_name = ISNULL(@lastName, (SELECT last_name FROM [User] WHERE id = @updateUserId)),
	first_name = ISNULL(@firstName, (SELECT first_name FROM [User] WHERE id = @updateUserId)),
	[user_name] = ISNULL(LOWER(@userName), (SELECT [user_name] FROM [User] WHERE id = @updateUserId)),
	password_hash = ISNULL(@passwordHash, (SELECT password_hash FROM [User] WHERE id = @updateUserId)),
	active = ISNULL(@active, (SELECT active FROM [User] WHERE id = @updateUserId))
	WHERE id = @updateUserId;

	SET @updatedUsers = @@ROWCOUNT;

END
GO
