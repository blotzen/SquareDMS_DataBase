USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_get_user_s]    Script Date: 28.08.2020 21:05:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- gets one or more uses depending
-- on the paramters.
CREATE PROCEDURE [dbo].[proc_get_user_s]
	@userId int,
	@retrieveUserId int,
	@lastName nvarchar(250) = NULL,
	@firstName nvarchar(250) = NULL,
	@userName nvarchar(250) = NULL,
	@active BIT = NULL,
	@errorCode int OUTPUT
AS
BEGIN

	DECLARE @isAdmin BIT;

	SET @errorCode = 0;
	
	--invalid param check 
	IF @userId IS NULL
	BEGIN
		RETURN;
	END


	--check if user is admin
	EXEC proc_is_user_admin @userId, @result = @isAdmin OUTPUT;

	IF @isAdmin = 0 AND @userId <> @retrieveUserId
	BEGIN
		SET @errorCode = 15;
		RETURN;
	END


	SELECT id Id, 
	last_name LastName, 
	first_name FirstName, 
	[user_name] UserName, 
	password_hash PasswordHash, 
	active, Active
	FROM [User]
	WHERE 
	(id = @retrieveUserId OR @retrieveUserId IS NULL)
	AND
	(last_name = @lastName OR @lastName IS NULL)
	AND 
	(first_name = @firstName OR @firstName IS NULL)
	AND
	([user_name] = @userName OR @userName IS NULL)
	AND
	(active = @active OR @active IS NULL)

END
GO
