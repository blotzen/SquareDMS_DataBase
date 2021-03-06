USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[critical_proc_insert_default_admin_and_groups]    Script Date: 30.12.2020 12:48:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- inserts the default admin user, doesnt if the user or group table isnt empty
CREATE PROCEDURE [dbo].[critical_proc_insert_default_admin_and_groups]
	@errorCode int OUTPUT
AS
BEGIN
	
	BEGIN TRAN
	BEGIN TRY

		IF (SELECT COUNT(*) FROM [User]) <> 0
		BEGIN
			SET @errorCode = 181;
			RETURN;
		END

		IF (SELECT COUNT(*) FROM [Group]) <> 0
		BEGIN
			SET @errorCode = 181;
			RETURN;
		END

		IF (SELECT COUNT(*) FROM [Group_Member]) <> 0
		BEGIN
			SET @errorCode = 181;
			RETURN;
		END

		-- Insert System Admin
		INSERT INTO [User]
		VALUES ('Admin', 'Admin', 'admin', '', 0x4F5F2C70332159747B59A4A1F837458A32802B05F3F947A71DD67BB2EFE01E49, 1);

		-- Insert Default Groups
		INSERT INTO [Group]
		VALUES ('Admins', 'Haben vollständige Rechte.', 1, 0);

		INSERT INTO [Group]
		VALUES ('Benutzer', 'Haben keine Rechte auf Dokumente.', 0, 0);

		INSERT INTO [Group]
		VALUES ('Creators', 'Dürfen Dokumente erstellen.', 0, 1);

		-- Put Admin in Admin-Group
		INSERT INTO Group_Member
		VALUES (1, 1);

	END TRY
	BEGIN CATCH
		
		SET @errorCode = 181;
		ROLLBACK TRAN;
		RETURN;

	END CATCH

	IF @@TRANCOUNT > 0
	BEGIN
		COMMIT TRAN;
		SET @errorCode = 0;
	END
END
GO
