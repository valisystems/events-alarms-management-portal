USE [LvMonitor]
GO
/****** Object:  StoredProcedure [dbo].[sLvm_RoomCsvImport]    Script Date: 10/18/2018 5:27:45 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Facility Name;Floor Number;Department Name;Room Number;RoomDescription;Beds
-- sLvm_RoomCsvImport 'Demo Facility;1;Nursing Care;102;Room 102;1020,1021'
-- sLvm_RoomCsvImport 'Demo Facility;1;;120;Room 120;'
CREATE PROCEDURE [dbo].[sLvm_ExtensionCsvImport]
@Csv varchar(max),
@Err varchar(max) output,
@ErrCode int output
AS
BEGIN
	SET NOCOUNT ON;

	declare @Extension varchar(10), @Description varchar(1000)
	declare @ExtensionId int

	declare @Msg nvarchar(max) = ''

	declare @Tbl table (Id int NOT NULL identity(1,1), Fld varchar(max))
	insert into @Tbl
	Select  LTRIM(RTRIM(Itm)) Fld FROM dbo.fSplit(@Csv,';')

	select @Extension = Fld from @tbl where Id=1
	select @Description = Fld from @tbl where Id=2

	set @ExtensionId = isnull((select top 1 CdrExtensionId from Lvm_CdrExtension where Extension=@Extension),0)

	if (@ExtensionId>0) set @Msg= @Msg + ' Extension "' + @Extension + '" already exists.'

	set @Msg = LTRIM(@Msg);

	IF (@Msg = '' or @Msg is null)
	begin
		set @ErrCode = 1
		insert into Lvm_CdrExtension(Extension, Description) 
		values(@Extension, isnull(@Description,''))
	end
	else
	begin
		set @ErrCode = -1
		set @Err = @Msg
	end
END
