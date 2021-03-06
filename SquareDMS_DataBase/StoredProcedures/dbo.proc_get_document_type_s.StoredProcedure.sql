USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_get_document_type_s]    Script Date: 30.12.2020 12:48:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- gets the document type for the given id, if id is 
-- null, all document types will be returned or
-- matched with the other paramters.
CREATE PROCEDURE [dbo].[proc_get_document_type_s]
	@userId int,
	@docTypeId int,
	@name nvarchar(max),
	@description nvarchar(max),
	@errorCode int OUTPUT
AS
BEGIN

	SET @errorCode = 0;

	EXEC proc_trim_and_truncate_string @input = @name, @output = @name OUTPUT;
	EXEC proc_trim_and_truncate_string @input = @description, @output = @description OUTPUT;


	SELECT id, [name], [description] FROM Document_Type
	WHERE 
	(id = @docTypeId OR @docTypeId IS NULL)
	AND
	([name] = @name OR @name IS NULL)
	AND
	([description] = @description OR @description IS NULL)

	RETURN;

END;

GO
