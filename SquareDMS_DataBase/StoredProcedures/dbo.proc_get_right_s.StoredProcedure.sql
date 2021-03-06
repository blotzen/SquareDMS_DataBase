USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_get_right_s]    Script Date: 30.12.2020 12:48:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- gets rights or a single right
CREATE PROCEDURE [dbo].[proc_get_right_s]
	@userId int,
	@groupId int,
	@docId int,
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

	SELECT group_id GroupId,
	document_id DocumentId,
	access_level AccessLevel
	FROM [Right]
	WHERE 
	(group_id = @groupId OR @groupId IS NULL)
	AND 
	(document_id = @docId OR @docId IS NULL)

END

GO
