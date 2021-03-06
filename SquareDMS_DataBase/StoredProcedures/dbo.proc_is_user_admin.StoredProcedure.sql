USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_is_user_admin]    Script Date: 30.12.2020 12:48:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Checks if a user is admin.
CREATE PROCEDURE [dbo].[proc_is_user_admin]
	@userId int NULL,
	@result BIT = 0 OUTPUT
AS
BEGIN
	-- invalid userId
	IF @userId IS NULL
	BEGIN
		SET @result = 0;
		RETURN;
	END

	-- if the user is in one or more admin groups, he is an admin.
	IF ((SELECT COUNT([admin]) 
		FROM [User]
		JOIN Group_Member ON [User].id = Group_Member.[user_id]
		JOIN [Group] ON Group_Member.group_id = [Group].id
		WHERE [User].id = @userId
		AND [Group].[admin] = 1
		GROUP BY [Group].[admin]) >= 1)
	BEGIN
		SET @result = 1;
		RETURN;
	END

	SET @result = 0;

END;



GO
