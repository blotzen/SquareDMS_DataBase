USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_get_user_by_username]    Script Date: 30.12.2020 12:48:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- gets a user by his username
CREATE PROCEDURE [dbo].[proc_get_user_by_username]
	@userName nvarchar(250),
	@errorCode int OUTPUT
AS
BEGIN
	
	SET @errorCode = 0;

	-- param check
	IF @userName IS NULL
	BEGIN
		SET @errorCode = 1;
		RETURN;
	END

	SELECT id Id, 
	last_name LastName, 
	first_name FirstName, 
	[user_name] UserName,
	email Email, 
	password_hash PasswordHash, 
	active Active
	FROM [User]
	WHERE [user_name] = @userName;

END
GO
