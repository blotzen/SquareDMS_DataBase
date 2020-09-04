USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_get_max_user_right_on_document]    Script Date: 04.09.2020 15:48:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
	
-- Get the highest access Level a user has for the given document.
CREATE PROC [dbo].[proc_get_max_user_right_on_document] (
	@userId int,
	@docId int,
	@maxAccessLevel int OUTPUT
) AS
BEGIN
	SET NOCOUNT ON;

	SELECT @maxAccessLevel = ISNULL(MAX([Right].access_level), 0)
	FROM Document
	JOIN [Right] ON Document.id = [Right].document_id
	JOIN [Group] ON [Right].group_id = [Group].id
	JOIN Group_Member ON [Group].id = Group_Member.group_id
	WHERE Group_Member.[user_id] = @userId
	AND Document.id = @docId;

END;	



GO
