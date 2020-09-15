USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_is_doc_discarded]    Script Date: 15.09.2020 22:03:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- checks if a document has been marked as discarded
CREATE PROCEDURE [dbo].[proc_is_doc_discarded]
	@docId int,
	@result BIT OUTPUT
AS
BEGIN	

	IF (@docId IS NULL)
	BEGIN
		SET @result = 0;
		RETURN;
	END
	
	IF ((SELECT discard FROM Document WHERE id = @docId) = 1)
	BEGIN
		SET @result = 1;
		RETURN;
	END

	SET @result = 0;
	RETURN;
END

GO
