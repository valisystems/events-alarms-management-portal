USE [LvMonitor]
GO
/****** Object:  StoredProcedure [dbo].[sLvm_BeaconCsvImport]    Script Date: 10/18/2018 5:26:13 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Facility Name;Floor Number;Department Name;Patient Name;Equipment Name;Beacon Code;Beacon Name;Beacon Description
-- sLvm_BeaconCsvImport 'Demo Facility;1;Nurse Care;John Smith;;000-111-222-333;Demo Beacon Patient;Demo Description'
-- sLvm_BeaconCsvImport 'Demo Facility;1;;;Intravenous;000-222-aaa-111;Demo Beacon Equipment;Demo Description'
ALTER PROCEDURE [dbo].[sLvm_BeaconCsvImport]
@Csv varchar(max),
@Err varchar(max) output,
@ErrCode int output
AS
BEGIN
	SET NOCOUNT ON;

	declare @FacilityName varchar(100), @FloorNumber varchar(50), @DepartmentName varchar(100), @PatientName varchar(200), @EquipmentName varchar(200), @BeaconName varchar(100), @BeaconCode varchar(100), @BeaconDescription varchar(2000), @Extension varchar(10), @ImageFile varchar(1000)
	declare @FacilityId int, @FloorId int, @DepartmentId int, @PatientId int, @EquipmentId int, @ExtensionId int

	declare @Msg nvarchar(max) = ''

	declare @Tbl table (Id int NOT NULL identity(1,1), Fld varchar(max))
	insert into @Tbl
	Select  LTRIM(RTRIM(Itm)) Fld FROM dbo.fSplit(@Csv,';')

	select @FacilityName = Fld from @tbl where Id=1
	select @FloorNumber = Fld from @tbl where Id=2
	select @DepartmentName = Fld from @tbl where Id=3
	select @PatientName = Fld from @tbl where Id=4
	select @EquipmentName = Fld from @tbl where Id=5
	select @BeaconCode = Fld from @tbl where Id=6
	select @BeaconName = Fld from @tbl where Id=7
	select @Extension = Fld from @tbl where Id=8
	select @BeaconDescription = Fld from @tbl where Id=9

	set @ImageFile = 'beacon1.png';
	select @ImageFile = case Fld when '' then 'beacon1.png' else Fld end from @tbl where Id=9;

	set @FacilityId = isnull((select top 1 FacilityId from Lvm_Facility where FacilityName=@FacilityName),0)
	set @FloorId = isnull((select top 1 FloorId from Lvm_Floor where FacilityId=@FacilityId and Number=@FloorNumber),0)
	set @DepartmentId = isnull((select top 1 DepartmentId from Lvm_Department where FacilityId=@FacilityId and FloorId=@FloorId and DepartmentName=@DepartmentName),null)
	set @PatientId = isnull((select top 1 PatientId from Lvm_Patient where FacilityId=@FacilityId and FloorId=@FloorId and FullName=@PatientName),null)
	set @EquipmentId =	isnull((select top 1 EquipmentId from Lvm_Equipment where FacilityId=@FacilityId and FloorId=@FloorId and DepartmentId=@DepartmentId and EquipmentName=@EquipmentName),null) 
	set @ExtensionId = isnull((select top 1 CdrExtensionId from Lvm_CdrExtension where Extension=@Extension),null)
	
	if (@ExtensionId is not null) begin
		declare @ExtensionAssignedBeacon int
		set @ExtensionAssignedBeacon = isnull((select top 1 CdrExtensionId from Lvm_Beacon where CdrExtensionId=@ExtensionId), 0)

		declare @ExtensionAssignedDevice int
		set @ExtensionAssignedDevice = isnull((select top 1 CdrExtensionId from Lvm_Device where CdrExtensionId=@ExtensionId), 0)
				
		if (@ExtensionAssignedBeacon>0 or @ExtensionAssignedDevice>0) set @Msg = @Msg + ' Extension "' + @Extension + '" already exists.'
	end

	if (@FacilityId=0) set @Msg= @Msg + ' Facility "' + @FacilityName + '" is not found.'
	if (@FloorId=0) set @Msg= @Msg + ' Floor "' + @FloorNumber + '" is not found.'
	if (@PatientId is null and @EquipmentId is null) set @Msg= @Msg + 'Equipment "' + @EquipmentName + '" and Patient "' + @PatientName + '" are not found.'

	set @Msg = LTRIM(@Msg);

	if (@BeaconName='')
	begin
		set @BeaconName=null
	end
	
	if (@BeaconDescription='')
	begin
		set @BeaconDescription=null
	end

	IF ((@FacilityId > 0 and @FloorId > 0 and (@Equipmentid > 0 or @PatientId > 0) and @BeaconCode<>'' and (@Msg = '' or @Msg is null)) and 
		(NOT EXISTS (SELECT * FROM Lvm_Beacon WHERE FacilityId = @FacilityId AND BeaconCode = @BeaconCode)))
	begin
		set @ErrCode = 1
		
		insert into Lvm_Beacon(FacilityId, FloorId, DepartmentId, EquipmentId, PatientId, BeaconCode, BeaconName, BeaconDescription, CdrExtensionId) 
		values(@FacilityId, @FloorId, @DepartmentId, @EquipmentId, @PatientId, @BeaconCode, isnull(@BeaconName,@BeaconCode), isnull(@BeaconDescription,'Added by import'), @ExtensionId)
	end
	else
	begin
		set @ErrCode = -1
		set @Err = @Msg
	end
end