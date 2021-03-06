USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_get_group_member_s]    Script Date: 30.12.2020 12:48:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- gets one or more group members
CREATE PROCEDURE [dbo].[proc_get_group_member_s]
	@userId int,
	@memberId int,
	@groupId int,
	@errorCode int OUTPUT
AS
BEGIN

	DECLARE @isAdmin BIT;

	SET @errorCode = 0;

	-- param check
	IF @userId IS NULL 
	BEGIN
		RETURN;
	END


	SELECT group_id GroupId, [user_id] UserId
	FROM Group_Member
	WHERE
	(group_id = @groupId OR (@groupId IS NULL))
	AND
	([user_id] = @memberId OR (@memberId IS NULL));


END

GO
