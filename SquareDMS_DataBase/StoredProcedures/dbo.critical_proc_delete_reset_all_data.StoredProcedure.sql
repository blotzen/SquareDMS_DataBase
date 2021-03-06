USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[critical_proc_delete_reset_all_data]    Script Date: 30.12.2020 12:48:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- delets all data and resets the identity counters
CREATE PROCEDURE [dbo].[critical_proc_delete_reset_all_data]
	@errorCode int OUTPUT
AS
BEGIN

	BEGIN TRAN
	BEGIN TRY

		DELETE FROM Document_Version;
		DBCC CHECKIDENT ('[Document_Version]', RESEED, 0);

		DELETE FROM Group_Member;

		DELETE FROM [Right];

		DELETE FROM [Document]
		DBCC CHECKIDENT ('[Document]', RESEED, 0);

		DELETE FROM Document_Type;
		DBCC CHECKIDENT ('[Document_Type]', RESEED, 0);

		DELETE FROM [File_Format];
		DBCC CHECKIDENT ('[File_Format]', RESEED, 0);

		DELETE FROM [User];
		DBCC CHECKIDENT ('[User]', RESEED, 0);

		DELETE FROM [Group];
		DBCC CHECKIDENT ('[Group]', RESEED, 0);

	END TRY
	BEGIN CATCH

		SET @errorCode = 180;
		ROLLBACK TRAN;
		RETURN;

	END CATCH

	IF @@TRANCOUNT > 0
	BEGIN
		COMMIT TRAN
		SET @errorCode = 0;
	END
END

GO
