USE [Square_DMS]
GO
/****** Object:  StoredProcedure [dbo].[proc_trim_and_truncate_string]    Script Date: 01.09.2020 00:52:27 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- trims and truncates string to fit in database
CREATE PROCEDURE [dbo].[proc_trim_and_truncate_string]
	@input nvarchar(max) = 0,
	@output nvarchar(250) OUTPUT
AS
BEGIN	

	SET @input = LTRIM(RTRIM(@input));

	SET @output = CAST(@input AS nvarchar(250));

END
GO
