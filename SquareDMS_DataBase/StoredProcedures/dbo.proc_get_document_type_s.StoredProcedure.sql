USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_get_document_type_s]    Script Date: 28.08.2020 21:05:20 ******/
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
	@name nvarchar(250),
	@description nvarchar(250),
	@errorCode int OUTPUT
AS
BEGIN

	SET @errorCode = 0;

	IF @docTypeId IS NULL 
	BEGIN
		SELECT id, [name], [description] FROM Document_Type
		WHERE 
		(LOWER([name]) = LOWER(@name) OR @name IS NULL)
		AND
		(LOWER([description]) = LOWER(@description) OR @description IS NULL)

		RETURN;
	END

	IF @docTypeId IS NOT NULL
	BEGIN
		SELECT id, [name], [description] FROM Document_Type
		WHERE id = @docTypeId;
		RETURN;
	END

END;
GO
