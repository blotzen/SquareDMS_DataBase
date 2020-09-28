USE master;

DROP Database Square_DMS;

-- Creates the Database with the default name
CREATE DATABASE Square_DMS 
ON
PRIMARY ( NAME = Square_DMS_1,
    FILENAME = 'D:\SQL\MSSQL12.MSSQLSERVER\MSSQL\DATA\Square_DMS.mdf'),
FILEGROUP FileStreamGroup1 CONTAINS FILESTREAM( NAME = Square_DMS_FS,
    FILENAME = 'D:\SQL\FileStream\Square_DMS')
LOG ON  ( NAME = Square_DMS_Log_1,
    FILENAME = 'D:\SQL\MSSQL12.MSSQLSERVER\MSSQL\DATA\Square_DMS_log.ldf')
GO

USE Square_DMS;

GO

CREATE TABLE Document_Type (
	id int IDENTITY(1,1),
	name nvarchar(250) NOT NULL UNIQUE,
	description nvarchar(250) NOT NULL,
	CONSTRAINT PK__Document_Type_id PRIMARY KEY (id));

CREATE TABLE [File_Format] (
	id int IDENTITY(1,1),
	extension nvarchar(250) NOT NULL,
	description nvarchar(250) NOT NULL,
	CONSTRAINT PK__File_Format_id PRIMARY KEY (id),
	CONSTRAINT CHK_Extension_Upper CHECK (UPPER(extension) = extension COLLATE Latin1_General_CS_AS));
	
CREATE TABLE [User] (
	id int IDENTITY(1,1),
	last_name nvarchar(250) NOT NULL,
	first_name nvarchar(250) NOT NULL,
	user_name nvarchar(250) NOT NULL UNIQUE,
	email nvarchar(250) NOT NULL,
	password_hash binary(32) NOT NULL,
	active bit NOT NULL,
	CONSTRAINT CHK_User_Name_Lower CHECK (LOWER(user_name) = user_name COLLATE Latin1_General_CS_AS),
	CONSTRAINT CHK_Email_Lower CHECK (LOWER(email) = email COLLATE Latin1_General_CS_AS),
	CONSTRAINT PK__User_id PRIMARY KEY (id));

CREATE TABLE Document (
	id int IDENTITY(1,1),
	creator_id int NOT NULL,
	document_type int NOT NULL,
	name nvarchar(250) NOT NULL,
	locked bit NOT NULL DEFAULT 0,
	discard bit NOT NULL DEFAULT 0,
	CONSTRAINT CHK_Name_No_LeftRight_Spaces CHECK (LTRIM(RTRIM(name)) = name COLLATE Latin1_General_CS_AS),
	CONSTRAINT PK__Document_id PRIMARY KEY (id),
	CONSTRAINT FK__User_id__Document_Creator_id FOREIGN KEY (creator_id) REFERENCES [User](id),
	CONSTRAINT FK__Document_Type_id__Document_document_type FOREIGN KEY (document_type) REFERENCES Document_Type(id));

CREATE TABLE Document_Version (
	id int IDENTITY(1,1),
	document_id int NOT NULL,
	event_datetime datetime2 NOT NULL,
	version_nr int NOT NULL,
	file_format_id int NOT NULL,
	[guid] uniqueidentifier NOT NULL UNIQUE ROWGUIDCOL DEFAULT NEWID(),
	filestream_data varbinary(max) FILESTREAM NOT NULL,
	CONSTRAINT PK__Document_Version_id PRIMARY KEY (id),
	CONSTRAINT FK__Document_id__Document_Version_document_id FOREIGN KEY (document_id) REFERENCES Document(id),
	CONSTRAINT FK__File_Format_id__Document_Version_file_format_id FOREIGN KEY (file_format_id) REFERENCES File_Format(id));

CREATE TABLE [Group] (
	id int IDENTITY(1,1),
	name nvarchar(250) NOT NULL,
	description nvarchar(250) NOT NULL,
	[admin] bit NOT NULL DEFAULT 0,
	creator bit NOT NULL DEFAULT 0,
	CONSTRAINT CHK_Either_Admin_XOR_Creator CHECK ((creator = 0 AND admin = 1) 
	OR (creator = 1 AND admin = 0) OR (creator = 0 AND admin = 0)),
	CONSTRAINT PK__Group_id PRIMARY KEY (id));

CREATE TABLE Group_Member (
	group_id int NOT NULL,
	[user_id] int NOT NULL,
	CONSTRAINT PK__Group_Member PRIMARY KEY (group_id,[user_id]),
	CONSTRAINT FK__Group_Member_Group_id__Group_id FOREIGN KEY (group_id) REFERENCES [Group](id),
	CONSTRAINT FK__Group_Member_User_id__User_id FOREIGN KEY ([user_id]) REFERENCES [User](id));

CREATE TABLE [Right] (
	group_id int NOT NULL,
	document_id int NOT NULL,
	access_level smallint NOT NULL,
	CONSTRAINT CHK_Correct_Access_Level CHECK (access_level IN (100, 200, 300)),
	CONSTRAINT PK__Right PRIMARY KEY (group_id,document_id),
	CONSTRAINT FK__Right_Group_id__Group_id FOREIGN KEY (group_id) REFERENCES [Group](id),
	CONSTRAINT FK__Right_Document_id__Document_id FOREIGN KEY (document_id) REFERENCES Document(id));

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