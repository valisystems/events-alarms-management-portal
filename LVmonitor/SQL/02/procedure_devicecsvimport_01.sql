USE [LvMonitor]
GO
/****** Object:  StoredProcedure [dbo].[sLvm_DeviceCsvImport]    Script Date: 9/20/2018 2:26:06 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Facility Name;Floor Number;Room Number;Bed;Device Type;Device Code;Device Name;Device Description
-- sLvm_DeviceCsvImport 'Demo Facility;1;120;1200;Patient Station;000-111-222-333;Demo Device;Demo Description'
-- sLvm_DeviceCsvImport 'Demo Facility;2;;;Patient Station;111-222-333-444;Demo Device 2;Desciption of Device'
ALTER PROCEDURE [dbo].[sLvm_DeviceCsvImport]
@Csv varchar(max),
@Err varchar(max) output,
@ErrCode int output
AS
BEGIN
	SET NOCOUNT ON;

	declare @FacilityName varchar(100), @FloorNumber varchar(50), @RoomNumber  varchar(50), @Bed varchar(50), @DeviceType varchar(100), @DeviceCode  varchar(100), @DeviceName  varchar(100), @DeviceDescription  varchar(2000), @ImageFile  varchar(1000)
	declare @FacilityId int, @FloorId int, @RoomId int, @BedId int, @DeviceTypeId int, @DeviceId int

	set @DeviceId = 0

	declare @Msg nvarchar(max) = ''

	declare @NextDevNum int
	declare @Tbl table (Id int NOT NULL identity(1,1), Fld varchar(max))
	insert into @Tbl
	Select  LTRIM(RTRIM(Itm)) Fld FROM dbo.fSplit(@Csv,';')

	select @FacilityName = Fld from @tbl where Id=1
	select @FloorNumber = Fld from @tbl where Id=2
	select @RoomNumber = Fld from @tbl where Id=3
	select @Bed = Fld from @tbl where Id=4
	select @DeviceType = Fld from @tbl where Id=5
	select @DeviceCode = Fld from @tbl where Id=6
	select @DeviceName = Fld from @tbl where Id=7
	select @DeviceDescription = Fld from @tbl where Id=8

	set @ImageFile = 'device1.png';
	select @ImageFile = case Fld when '' then 'device1.png' else Fld end from @tbl where Id=9;

	set @FacilityId = isnull((select top 1 FacilityId from Lvm_Facility where FacilityName=@FacilityName),0)
	set @FloorId = isnull((select top 1 FloorId from Lvm_Floor where FacilityId=@FacilityId and Number=@FloorNumber),0)
	set @RoomId = isnull((select top 1 RoomId from Lvm_Room where FacilityId=@FacilityId and FloorId=@FloorId and RoomNumber=@RoomNumber),null)
	set @BedId = isnull((select top 1 BedId from Lvm_Bed where FacilityId=@FacilityId and FloorId=@FloorId and RoomId=@RoomId and Number=@Bed),null)
	set @DeviceTypeId =	isnull((select top 1 DeviceTypeId from Lvm_DeviceType where DeviceTypeName=@DeviceType),0) 

	declare @DeviceExists int
	set @DeviceExists = isnull((select top 1 DeviceId from Lvm_Device where DeviceCode=@DeviceCode), 0)

	select @NextDevNum =  isnull(max(DeviceNumber),0) + 1  from Lvm_Device where FacilityId=@FacilityId

	--select @DeviceTypeId, @FacilityId, @DepartmentId, @RoomId, @NextDevNum, @DeviceCode, isnull(@DeviceName,@DeviceCode), isnull(@DeviceDescription,''), 1, @ImageFile; return
	
	if (@FacilityId=0) set @Msg= @Msg + ' Facility "' + @FacilityName + '" is not found.'
	if (@FloorId=0) set @Msg= @Msg + ' Floor "' + @FloorNumber + '" is not found.'
	if (@DeviceTypeId=0) set @Msg= @Msg + ' Device Type "' + @DeviceType + '" is not found.'
	if (@DeviceExists>0) set @Msg = @Msg + ' Device "' + @DeviceCode + '" already exists.'

	if (@DeviceName='')
	begin
		set @DeviceName=null
	end

	set @Msg = LTRIM(@Msg);
	
	IF ((@FacilityId > 0 and @FloorId > 0 and @DeviceTypeId > 0 and @DeviceCode<>'' and (@Msg = '' or @Msg is null)) and 
		(NOT EXISTS (SELECT * FROM Lvm_Device WHERE FacilityId = @FacilityId AND DeviceCode = @DeviceCode)))
	begin
		set @ErrCode = 1
		insert into Lvm_Device(FacilityId, FloorId, RoomId, DeviceNumber, DeviceTypeId, DeviceCode, DeviceName, DeviceDescription, MediaTypeId, ImageFile) 
		values(@FacilityId, @FloorId, @RoomId, @NextDevNum, @DeviceTypeId, @DeviceCode, isnull(@DeviceName,@DeviceCode), isnull(@DeviceDescription,''), 1, @ImageFile)
		select @DeviceId = SCOPE_IDENTITY()
		if (@BedId > 0 and @DeviceId > 0)
		begin
			insert into Lvm_BedLvm_Device(Lvm_Bed_BedId, Lvm_Device_DeviceId)
			values(@BedId, @DeviceId)
		end
	end
	else
	begin
		set @ErrCode = -1
		set @Err = @Msg
	end
END
