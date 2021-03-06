USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_create_document]    Script Date: 30.12.2020 12:48:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- creates a document if the user is member of the creator group
-- or if he is admin.
CREATE PROCEDURE [dbo].[proc_create_document]
	@userId int,
	@docType int,
	@name nvarchar(max),
	@locked BIT,
	@discard BIT,
	@errorCode int OUTPUT,
	@createdDocuments int OUTPUT,
	@createdId int OUTPUT
AS
BEGIN

	DECLARE @nameValid nvarchar(250);

	SET @errorCode = 0;
	SET @createdDocuments = 0;

	EXEC proc_trim_and_truncate_string @input = @name, @output = @nameValid OUTPUT;

	-- checks the name parameter 
	IF (LEN(@nameValid) = 0 OR @nameValid IS NULL)
	BEGIN
		SET @errorCode = 120;
		RETURN;
	END

	DECLARE @isCreator BIT;
	DECLARE @isAdmin BIT;

	EXEC proc_is_user_creator @userId = @userId, @result = @isCreator OUTPUT;
	EXEC proc_is_user_admin @userId = @userId, @result = @isAdmin OUTPUT;

	IF (@isCreator = 0 AND @isAdmin = 0)
	BEGIN
		SET @errorCode = 14;
		RETURN;
	END

	-- check if docType exists
	IF (SELECT COUNT(id) FROM [Document_Type]
		WHERE id = @docType) = 0
	BEGIN
		SET @errorCode = 110;
		RETURN;
	END

	INSERT INTO [Document]
	VALUES (@userId, @docType, @nameValid, ISNULL(@locked, 0), ISNULL(@discard, 0));

	SET @createdDocuments = @@ROWCOUNT;
	SET @createdId = SCOPE_IDENTITY();
END;

GO
