USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_update_user]    Script Date: 30.12.2020 12:48:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_update_user]
	@userId int,
	@updateUserId int,
	@lastName nvarchar(250),
	@firstName nvarchar(250),
	@email nvarchar(250),
	@passwordHash binary(32),
	@active BIT,
	@errorCode int OUTPUT,
	@updatedUsers int OUTPUT
AS
BEGIN

	DECLARE @lastNameValid nvarchar(250);
	DECLARE @firstNameValid nvarchar(250);
	DECLARE @emailValid nvarchar(250);

	DECLARE @isAdmin BIT;

	SET @errorCode = 0;
	SET @updatedUsers = 0;
	
	--invalid param check 
	IF @userId IS NULL OR @updateUserId IS NULL
	BEGIN
		RETURN;
	END

	EXEC proc_trim_and_truncate_string @input = @lastName, @output = @lastNameValid OUTPUT;
	EXEC proc_trim_and_truncate_string @input = @firstName, @output = @firstNameValid OUTPUT;
	EXEC proc_trim_and_truncate_string @input = @email, @output = @emailValid OUTPUT;

	--check if user is admin
	EXEC proc_is_user_admin @userId, @result = @isAdmin OUTPUT;

	IF @isAdmin = 0 AND @userId <> @updateUserId
	BEGIN
		SET @errorCode = 15;
		RETURN;
	END


	-- check user last name
	IF (LEN(@lastNameValid) = 0 AND @lastNameValid IS NOT NULL)
	BEGIN
		SET @errorCode = 123;
		RETURN;
	END

	UPDATE [User]
	SET
	last_name = ISNULL(@lastNameValid, (SELECT last_name FROM [User] WHERE id = @updateUserId)),
	first_name = ISNULL(@firstNameValid, (SELECT first_name FROM [User] WHERE id = @updateUserId)),
	email = ISNULL(LOWER(@emailValid), (SELECT email FROM [User] WHERE id = @updateUserId)),
	password_hash = ISNULL(@passwordHash, (SELECT password_hash FROM [User] WHERE id = @updateUserId)),
	active = ISNULL(@active, (SELECT active FROM [User] WHERE id = @updateUserId))
	WHERE id = @updateUserId;

	SET @updatedUsers = @@ROWCOUNT;

END

GO
