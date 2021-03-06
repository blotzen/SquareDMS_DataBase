USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_is_doc_locked]    Script Date: 30.12.2020 12:48:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Checks if a document has been locked.
CREATE PROCEDURE [dbo].[proc_is_doc_locked]
	@docId int,
	@result BIT = 0 OUTPUT
AS
BEGIN	
-- invalid document Id
	IF @docId IS NULL
	BEGIN
		SET @result = 0;
		RETURN;
	END

	IF ((SELECT locked FROM Document WHERE Document.id = @docId) = 1)
	BEGIN
		SET @result = 1;
		RETURN;
	END

	SET @result = 0;
	RETURN;
END;

GO
