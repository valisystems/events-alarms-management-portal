USE [LvMonitor]
GO
/****** Object:  StoredProcedure [dbo].[sLvmBeaconRecordProcess]    Script Date: 8/21/2018 11:42:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Batch submitted through debugger: SQLQuery94.sql|7|0|C:\Users\andre\AppData\Local\Temp\~vsB991.sql
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--	sLvmDeviceRecordProcess 177
ALTER PROCEDURE [dbo].[sLvmBeaconRecordProcess] 
@BeaconRecordId int
AS
BEGIN
SET NOCOUNT ON;

	declare @MS int = ABS(Checksum(NewID()) % 1000)
	declare @waitTime DATETIME = DATEADD(ms, @MS, GETDATE())
	waitfor time @waitTime

DECLARE @FacilityId INT, @FloorId INT, @DepartmentId INT, @PatientId INT, @EquipmentId INT, @BeaconId INT, @ControlId INT, @IsControlOn BIT, @MonitorId INT, @TemplateId INT, @RestrictedZoneId INT, @BeaconData NVARCHAR(MAX), @MonBeaconData NVARCHAR(MAX); set @MonBeaconData=''
declare @MonitorRecordId int, @Control1 bit, @Control2 bit, @Control3 bit, @Control4 bit, @Control5 bit, @Control6 bit, @Control7 bit, @Control8 bit
declare @IsAnyCtlOn bit; set @IsAnyCtlOn=0
set @MonitorRecordId=0
set @Control1=0; set @Control2=0; set @Control3=0; set @Control4=0; set @Control5=0; set @Control6=0; set @Control7=0; set @Control8=0

declare @TemplateName varchar(100); set @TemplateName=''
declare @BeaconRecordImg varchar(1000)
declare @MediaType int
declare @DNow datetime; set @DNow=getdate();

declare @CtlImgName table (ControlNumber int, ControlImage varchar(300), ControlName varchar(100), ControlCode varchar(100))

SELECT @FacilityId=FacilityId, @FloorId=FloorId, @DepartmentId=DepartmentId, @PatientId=PatientId, @EquipmentId=EquipmentId, @BeaconId=BeaconId, @ControlId=ControlId, @IsControlOn=IsControlOn, @MonitorId=MonitorId, @TemplateId=TemplateId, @BeaconData=BeaconData, @RestrictedZoneId=RestrictedZoneId	--, DateCreated, IsProcessed, IsError, ErrorMessage
FROM  Lvm_BeaconRecord
where BeaconRecordId = @BeaconRecordId

select @MonitorRecordId=MonitorRecordId, @MonBeaconData=BeaconData,
@Control1=Control1, @Control2=Control2, @Control3=Control3, @Control4=Control4, @Control5=Control5, @Control6=Control6, @Control7=Control7, @Control8=Control8 
from Lvm_MonitorRecord where BeaconId=@BeaconId

if (@ControlId=1) set @Control1=@IsControlOn; else if (@ControlId=2) set @Control2=@IsControlOn; else if (@ControlId=3) set @Control3=@IsControlOn; else if (@ControlId=4) set @Control4=@IsControlOn; else if (@ControlId=5) set @Control5=@IsControlOn; else if (@ControlId=6) set @Control6=@IsControlOn; else if (@ControlId=7) set @Control7=@IsControlOn; else if (@ControlId=8) set @Control8=@IsControlOn; 

if ((@Control1=1) or (@Control2=1) or (@Control3=1) or (@Control4=1) or (@Control5=1) or (@Control6=1) or (@Control7=1) or (@Control8=1)) set @IsAnyCtlOn=1


if (@MonitorRecordId=0)
-- Add new record if @IsAnyCtlOn
Begin
	if (@IsAnyCtlOn=1) 
		begin
		DELETE FROM @CtlImgName
		insert into @CtlImgName SELECT ControlNumber, ControlImage, ControlName, ControlCode FROM vLvmControlImageByBeacon WHERE BeaconId = @BeaconId order by ControlNumber

		declare @Img1 varchar(300), @Img2 varchar(300), @Img3 varchar(300), @Img4 varchar(300), @Img5 varchar(300), @Img6 varchar(300), @Img7 varchar(300), @Img8 varchar(300)
		SELECT @Img1=isnull([1],''), @Img2=isnull([2],''), @Img3=isnull([3],''), @Img4=isnull([4],''), @Img5=isnull([5],''), @Img6=isnull([6],''), @Img7=isnull([7],''), @Img8=isnull([8],'')
		FROM (SELECT ControlNumber, ControlImage from @CtlImgName) AS SourceTable
		PIVOT (max(ControlImage) FOR ControlNumber IN ([1], [2], [3], [4], [5], [6], [7], [8])) AS PivotTable

		declare @CtlN1 varchar(100), @CtlN2 varchar(100), @CtlN3 varchar(100), @CtlN4 varchar(100), @CtlN5 varchar(100), @CtlN6 varchar(100), @CtlN7 varchar(100), @CtlN8 varchar(100)
		SELECT @CtlN1=isnull([1],''), @CtlN2=isnull([2],''), @CtlN3=isnull([3],''), @CtlN4=isnull([4],''), @CtlN5=isnull([5],''), @CtlN6=isnull([6],''), @CtlN7=isnull([7],''), @CtlN8=isnull([8],'')
		FROM (SELECT ControlNumber, ControlName from @CtlImgName) AS SourceTable
		PIVOT (max(ControlName) FOR ControlNumber IN ([1], [2], [3], [4], [5], [6], [7], [8])) AS PivotTable

		declare @CtlC1 varchar(100), @CtlC2 varchar(100), @CtlC3 varchar(100), @CtlC4 varchar(100), @CtlC5 varchar(100), @CtlC6 varchar(100), @CtlC7 varchar(100), @CtlC8 varchar(100)
		SELECT @CtlC1=isnull([1],''), @CtlC2=isnull([2],''), @CtlC3=isnull([3],''), @CtlC4=isnull([4],''), @CtlC5=isnull([5],''), @CtlC6=isnull([6],''), @CtlC7=isnull([7],''), @CtlC8=isnull([8],'')
		FROM (SELECT ControlNumber, ControlCode from @CtlImgName) AS SourceTable
		PIVOT (max(ControlCode) FOR ControlNumber IN ([1], [2], [3], [4], [5], [6], [7], [8])) AS PivotTable


		--declare @DevRecordImagePath varchar(1000); 
		--set @DevRecordImagePath= replace('~/' + (SELECT TOP 1 ImagePath FROM Lvm_ImageType WHERE ImageTypeId = 2) + '/','//','/');

		--set @DeviceRecordImg=dbo.fLvmDevRecImage(@FacilityId, dbo.fLvmGetStrBetween(@DeviceData, 'i=', '&'))
		set @BeaconRecordImg=dbo.fLvmBeaconImage(@FacilityId, @BeaconId)
		
		set @MediaType=cast(SUBSTRING(@BeaconRecordImg,1,1) as int)
		set @BeaconRecordImg=SUBSTRING(@BeaconRecordImg,2,(len(@BeaconRecordImg)-1))
		--if (CHARINDEX('/', @DeviceRecordImg)=0 ) set @DeviceRecordImg= (replace('~/' + (SELECT TOP 1 ImagePath FROM Lvm_ImageType WHERE ImageTypeId = 2) + '/','//','/')) + cast(@FacilityId as varchar(10)) + '/' + @DeviceRecordImg

		select top 1 @TemplateId=TemplateId, @TemplateName=TemplateName from Lvm_Template where TemplateNumber=@TemplateId

		-- Insert record
		INSERT INTO Lvm_MonitorRecord (FacilityId, FloorId, DepartmentId, PatientId, EquipmentId, MonitorId, BeaconId, TemplateId, RestrictedZoneId,
		Control1, Control2, Control3, Control4, Control5, Control6, Control7, Control8,  
		BeaconData, LastBeaconRecordId, DateCreated,
		DateOn1, DateOn2, DateOn3, DateOn4, DateOn5, DateOn6, DateOn7, DateOn8, 
		ControlImg1, ControlImg2, ControlImg3, ControlImg4, ControlImg5, ControlImg6, ControlImg7, ControlImg8, 
		ControlName1, ControlName2, ControlName3, ControlName4, ControlName5, ControlName6, ControlName7, ControlName8, 
		ControlCode1, ControlCode2, ControlCode3, ControlCode4, ControlCode5, ControlCode6, ControlCode7, ControlCode8, 
		MediaTypeId, BeaconRecordImg, TemplateName)
		values (@FacilityId, @FloorId, @DepartmentId, @PatientId, @EquipmentId, @MonitorId, @BeaconId, @TemplateId, @RestrictedZoneId,
		@Control1, @Control2, @Control3, @Control4, @Control5, @Control6, @Control7, @Control8, 
		@BeaconData, @BeaconRecordId, @DNow,
		@DNow, @DNow, @DNow, @DNow, @DNow, @DNow, @DNow, @DNow,
		@Img1, @Img2, @Img3, @Img4, @Img5, @Img6, @Img7, @Img8, 
		@CtlN1, @CtlN2, @CtlN3, @CtlN4, @CtlN5, @CtlN6, @CtlN7, @CtlN8, 
		@CtlC1, @CtlC2, @CtlC3, @CtlC4, @CtlC5, @CtlC6, @CtlC7, @CtlC8, 
		@MediaType, @BeaconRecordImg,@TemplateName
		)
		end
End
else
-- Update / delete record
Begin

	if (@IsAnyCtlOn=0)
		delete Lvm_MonitorRecord where MonitorRecordId=@MonitorRecordId;
	else
	begin
		
		if (@IsControlOn=0) set @BeaconData=@MonBeaconData -- if a control is turning off we keep Lvm_MonitorRecord DeviceData

		Update Lvm_MonitorRecord set TemplateId=@TemplateId, 
		Control1=@Control1, Control2=@Control2, Control3=@Control3, Control4=@Control4, Control5=@Control5, Control6=@Control6, Control7=@Control7, Control8=@Control8, 
		BeaconData=@BeaconData, LastBeaconRecordId=@BeaconRecordId
		where MonitorRecordId=@MonitorRecordId

		-- Update DateOn#
		if (@ControlId=1) Update Lvm_MonitorRecord set DateOn1=@DNow where MonitorRecordId=@MonitorRecordId; 
		else if (@ControlId=2) Update Lvm_MonitorRecord set DateOn2=@DNow where MonitorRecordId=@MonitorRecordId; 
		else if (@ControlId=3) Update Lvm_MonitorRecord set DateOn3=@DNow where MonitorRecordId=@MonitorRecordId; 
		else if (@ControlId=4) Update Lvm_MonitorRecord set DateOn4=@DNow where MonitorRecordId=@MonitorRecordId; 
		else if (@ControlId=5) Update Lvm_MonitorRecord set DateOn5=@DNow where MonitorRecordId=@MonitorRecordId; 
		else if (@ControlId=6) Update Lvm_MonitorRecord set DateOn6=@DNow where MonitorRecordId=@MonitorRecordId; 
		else if (@ControlId=7) Update Lvm_MonitorRecord set DateOn7=@DNow where MonitorRecordId=@MonitorRecordId; 
		else if (@ControlId=8) Update Lvm_MonitorRecord set DateOn8=@DNow where MonitorRecordId=@MonitorRecordId; 	

	end
End

update Lvm_BeaconRecord set IsProcessed=1 where BeaconRecordId=@BeaconRecordId

--Lvm_MonitorRecordLog
	if (@IsControlOn=1)
	begin
		IF (not EXISTS(SELECT *  FROM  Lvm_MonitorRecordLog  WHERE IsClosed=0 and MonitorId=@MonitorId and FacilityId=@FacilityId and BeaconId=@BeaconId and ControlId=@ControlId and IsControlOn=@IsControlOn))
		INSERT INTO Lvm_MonitorRecordLog (MonitorId, FacilityId, FloorId, DepartmentId, PatientId, EquipmentId, BeaconId, RestrictedZoneId, ControlId, IsControlOn, BeaconRecordIdOn, DateControlOn, IsClosed)
		values (@MonitorId, @FacilityId, @FloorId, @DepartmentId, @PatientId, @EquipmentId, @BeaconId, @RestrictedZoneId, @ControlId, @IsControlOn, @BeaconRecordId, @DNow, 0)
	end
	else
		update Lvm_MonitorRecordLog  set IsControlOn=@IsControlOn, DateControlOff = @DNow, BeaconRecordIdOff = @BeaconRecordId, IsClosed= 1
		where FacilityId=@FacilityId and BeaconId=@BeaconId and ControlId=@ControlId and IsControlOn= 1
END
