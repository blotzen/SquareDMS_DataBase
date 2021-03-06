USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_get_group_s]    Script Date: 30.12.2020 12:48:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- gets the group or groups. User has to be admin.
CREATE PROCEDURE [dbo].[proc_get_group_s]
	@userId int,
	@groupId int,
	@name nvarchar(250),
	@description nvarchar(250),
	@admin BIT,
	@creator BIT,
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

	EXEC proc_trim_and_truncate_string @input = @name, @output = @name OUTPUT;
	EXEC proc_trim_and_truncate_string @input = @description, @output = @description OUTPUT;

	--check if user is admin
	EXEC proc_is_user_admin @userId, @result = @isAdmin OUTPUT;

	-- get the groups
	SELECT id, [name], [description], [admin], creator
	FROM [Group]
	WHERE
	(id = @groupId OR @groupId IS NULL)
	AND
	([name] = @name OR @name IS NULL)
	AND
	([description] = @description OR @description IS NULL)
	AND
	([admin] = @admin OR @admin IS NULL)
	AND 
	([creator] = @creator OR @creator IS NULL)

END

GO
