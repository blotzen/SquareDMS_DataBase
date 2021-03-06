USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_is_user_creator]    Script Date: 30.12.2020 12:48:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[proc_is_user_creator]
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

	-- if the user is in one or more creator groups, he is an creator.
	IF ((SELECT COUNT([creator]) 
		FROM [User]
		JOIN Group_Member ON [User].id = Group_Member.[user_id]
		JOIN [Group] ON Group_Member.group_id = [Group].id
		WHERE [User].id = @userId
		AND [Group].[creator] = 1
		GROUP BY [Group].[creator]) >= 1)
	BEGIN
		SET @result = 1;
		RETURN;
	END

	SET @result = 0;

END;

GO
