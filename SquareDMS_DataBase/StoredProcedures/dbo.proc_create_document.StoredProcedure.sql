USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_create_document]    Script Date: 28.08.2020 21:05:20 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- creates a document if the user is member of the creator group
-- or if he is admin.
CREATE PROCEDURE [dbo].[proc_create_document]
	@userId int,
	@docType int,
	@name nvarchar(250),
	@locked BIT,
	@discard BIT,
	@errorCode int OUTPUT,
	@createdDocuments int OUTPUT
AS
BEGIN

	SET @errorCode = 0;
	SET @createdDocuments = 0;

	SET @name = LTRIM(RTRIM(@name));

	-- checks the name parameter 
	IF (@name IS NULL) OR (LEN(@name) = 0)
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
	VALUES (@userId, @docType, @name, @locked, @discard);

	SET @createdDocuments = @@ROWCOUNT;
END;
GO
