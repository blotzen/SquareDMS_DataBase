USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[critical_proc_setup_test_data]    Script Date: 30.12.2020 12:48:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- inserts test data into the database
CREATE PROCEDURE [dbo].[critical_proc_setup_test_data]
	@errorCode int OUTPUT
AS
BEGIN

	BEGIN TRAN
	BEGIN TRY	

insert into [file_format]
		values ('PDF', 'Portable Document Format');

		insert into [file_format]
		values ('JSON', 'Java Script Object Notation');
----------------------------------------------------------------------------------------------
		insert into document_type
		values ('E-Book', '');

		insert into document_type
		values ('Skript', '');

		insert into document_type
		values ('Dokumentation', 'Dokumentation dienen der Nachvollziehbarkeit.');
----------------------------------------------------------------------------------------------
		--id 1
		insert into [User]
		values ('brandl', 'franz', 'admin', '', 0x4F5F2C70332159747B59A4A1F837458A32802B05F3F947A71DD67BB2EFE01E49, 1);

		insert into [User]
		values ('quentin', 'tarantino', 'grindhouser', '', CAST(123455 AS Binary(32)), 1);

		insert into [User]
		values ('keine', 'rechte', 'norights', 'noright@lol.com', CAST(1234551 AS Binary(32)), 1);

		insert into [User]
		values ('Mita', 'Beiter', 'ma_mita', '', CAST(12345512 AS Binary(32)), 1);

		--id 5
		insert into [User]
		values ('Anna', 'Nass', 'pineapple', '', CAST(12345111 AS Binary(32)), 1);

		insert into [User]
		values ('Maier', 'Sepp', 'supersickmaier', '', 0x80351C5B9359DB0930A21FB30C419B20CF4285FA3F2CF7A16DAA5EA3FCCEE80F, 1);
----------------------------------------------------------------------------------------------
		-- doc 1
		insert into Document
		values (1, 1, '2015_Book_ExpertSQLServerIn-MemoryOLTP', 0, 0);

		insert into Document
		values (1, 1, 'Lern dich glücklich II - Skript', 1, 0);

		insert into Document
		values (2, 1, 'Ars Mathetica - Skript', 0, 1);

		insert into Document
		values (2, 2, 'Die Bibel', 1, 0);

		-- doc 5
		insert into Document
		values (1, 1, 'Inferno - Dan Brown', 0, 0);

		insert into Document
		values (1, 1, 'White Line Fever - Lemmy', 0, 0);

		insert into Document
		values (1, 1, 'Der Herr der Ringe - Die Gefährten', 0, 0);

		-- doc 8
		insert into Document
		values (1, 1, 'Der Herr der Ringe - Die zwei Türme', 1, 0);

		-- doc 9
		insert into Document
		values (1, 1, 'Der Herr der Ringe - Die Rückkehr des Königs', 1, 0);
		
		-- doc 10
		insert into Document
		values (1, 1, 'Das Schweigen der Lämmer', 0, 0);	
		
		-- doc 11
		insert into Document
		values (1, 1, 'Oliver Twist', 0, 0);
		
		-- doc 12
		insert into Document
		values (6, 1, 'The Number of the Beast', 0, 0);
----------------------------------------------------------------------------------------------
		-- id 1
		insert into [Group]
		values ('Admins', 'Haben vollständige Rechte.', 1, 0);

		insert into [Group]
		values ('Benutzer', 'Haben keine Rechte auf Dokumente.', 0, 0);

		insert into [Group]
		values ('Creators', 'Dürfen Dokumente erstellen.', 0, 1);

		--id 4
		insert into [Group]
		values ('Filmliebhaber', 'Mögen Filme', 0, 0);
----------------------------------------------------------------------------------------------
		-- User Franz in Gruppe Admins
		insert into Group_Member
		values (1, 1);

		-- User Franz auch in Gruppe Benutzer
		insert into Group_Member
		values (2, 1);

		-- User Tarantino in Gruppe Benutzer
		insert into Group_Member
		values (2, 2);

		-- User Tarantino in Gruppe Creators
		insert into Group_Member
		values (3, 2);

		-- User Mita Beiter in Benutzer
		insert into Group_Member
		values (2, 4);
----------------------------------------------------------------------------------------------
		insert into [Right]
		values (2, 5, 200);

		insert into [Right]
		values (2, 6, 100);

		insert into [Right]
		values (4, 10, 100);

		insert into [Right]
		values (4, 11, 200);

		insert into [Right]
		values (3, 11, 200);

		-- document versions
		insert into document_version
		values (6, GETDATE(), 1, 1, NEWID(), CAST(123468546 AS Binary(128)));

		-- document versions
		insert into document_version
		values (6, GETDATE(), 1, 1, NEWID(), CAST(12346121246 AS Binary(128)));

		-- document versions
		insert into document_version
		values (12, GETDATE(), 1, 1, NEWID(), CAST(12346121246 AS Binary(128)));

	END TRY
	BEGIN CATCH

		SET @errorCode = 190;
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
