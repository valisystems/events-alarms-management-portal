USE [LvMonitor]
GO
/****** Object:  UserDefinedFunction [dbo].[fConvertTimeToHHMMSS]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
ALTER FUNCTION [dbo].[fConvertTimeToHHMMSS]
(
    @time decimal(28,3), 
    @unit varchar(20)
)
returns varchar(20)
as
begin

    declare @seconds decimal(18,3), @minutes int, @hours int;

    if(@unit = 'hour' or @unit = 'hh' )
        set @seconds = @time * 60 * 60;
    else if(@unit = 'minute' or @unit = 'mi' or @unit = 'n')
        set @seconds = @time * 60;
    else if(@unit = 'second' or @unit = 'ss' or @unit = 's')
        set @seconds = @time;
    else set @seconds = 0; -- unknown time units

    set @hours = convert(int, @seconds /60 / 60);
    set @minutes = convert(int, (@seconds / 60) - (@hours * 60 ));
    set @seconds = @seconds % 60;

    return 
        right('00' + convert(varchar(9), convert(int, @hours)), 2) + 'h:' +
        right('00' + convert(varchar(2), convert(int, @minutes)), 2) + 'm:' +
        right('00' + convert(varchar(2), convert(int, @seconds)), 2) + 's'

end
GO
/****** Object:  UserDefinedFunction [dbo].[fLvmBeaconImage]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- select dbo.fLvmDevImage(1,1)
ALTER FUNCTION [dbo].[fLvmBeaconImage]
(
@FacilityId int,
@BeaconId int
)
RETURNS varchar(300)
AS
BEGIN

declare @Img as varchar(300); set @Img='';
declare @MediaTypeId as char(1);

SELECT @Img = ImageFile, @MediaTypeId = cast(MediaTypeId as char(1)) FROM  Lvm_Beacon WHERE (BeaconId = @BeaconId)

declare @path as varchar(300); set @path ='';


if ((@MediaTypeId = 1) and (CHARINDEX('/', @Img) = 0))
begin
set @path = (SELECT TOP 1 ImagePath FROM Lvm_ImageType WHERE ImageTypeId = 7);
if (dbo.IsValidURL(@path)=0)
begin
set @path = '~/' + @path;
end
-- + cast(@FacilityId as varchar(10)) + '/'; 
set @path = replace(@path, '//','/');
end

set @Img = @MediaTypeId + @path + @Img

RETURN @Img;
end
GO
/****** Object:  UserDefinedFunction [dbo].[fLvmCtrlSystem]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fLvmCtrlSystem]
(
)
RETURNS varchar(300)
AS
BEGIN

declare @DeviceTypeId as int set @DeviceTypeId=0;

SELECT @DeviceTypeId = DeviceTypeId FROM  Lvm_DeviceType WHERE (DeviceTypeName = 'System')
RETURN @DeviceTypeId
END
GO
/****** Object:  UserDefinedFunction [dbo].[fLvmCtrlVal]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[fLvmCtrlVal]
(
	@CtrlFldNum int,
	@CtrlNum int,
	@IsOn bit
)
RETURNS bit
AS
BEGIN
	RETURN case when @CtrlFldNum=@CtrlNum and @IsOn=1 then 1 else 0 end
END
GO
/****** Object:  UserDefinedFunction [dbo].[fLvmDevImage]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- select dbo.fLvmDevImage(1,1)
ALTER FUNCTION [dbo].[fLvmDevImage]
(
@FacilityId int,
@DeviceId int
)
RETURNS varchar(300)
AS
BEGIN

declare @Img as varchar(300); set @Img='';
declare @MediaTypeId as char(1);

SELECT @Img = ImageFile, @MediaTypeId = cast(MediaTypeId as char(1)) FROM  Lvm_Device WHERE (DeviceId = @DeviceId)

declare @path as varchar(300); set @path ='';


if ((@MediaTypeId = 1) and (CHARINDEX('/', @Img) = 0))
begin
set @path = (SELECT TOP 1 ImagePath FROM Lvm_ImageType WHERE ImageTypeId = 4);
if (dbo.IsValidURL(@path)=0)
begin
set @path = '~/' + @path;
end
-- + cast(@FacilityId as varchar(10)) + '/'; 
set @path = replace(@path, '//','/');
end

set @Img = @MediaTypeId + @path + @Img

RETURN @Img;
end
GO
/****** Object:  UserDefinedFunction [dbo].[fLvmDevRecImage]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- select dbo.fLvmDevRecImage(1,'1')
ALTER FUNCTION [dbo].[fLvmDevRecImage]
(
	@FacilityId int,
	@ImageNumName varchar(100)
)
RETURNS varchar(300)
AS
BEGIN

declare @Img as varchar(300); set @Img='';

if (CHARINDEX('/', @ImageNumName)>0 )
	set @Img = @ImageNumName;
else
	begin
		declare @path as varchar(300); set @path = '~/' + cast(@FacilityId as varchar(10)) + '/' + (SELECT TOP 1 ImagePath FROM Lvm_ImageType WHERE ImageTypeId = 2); set @path = replace(@path, '~//','~/');
		if (ISNUMERIC(@ImageNumName)=1 )
			set @Img= (SELECT cast(MediaTypeId as char(1)) + ImageFile FROM  Lvm_DeviceRecordImage WHERE (FacilityId = @FacilityId) AND (ImageNumber = (cast(@ImageNumName as int))))
		else
			set @Img= (SELECT cast(MediaTypeId as char(1)) + ImageFile FROM  Lvm_DeviceRecordImage WHERE (FacilityId = @FacilityId) AND (ImageName = @ImageNumName))
	end

RETURN @Img;
end
GO
/****** Object:  UserDefinedFunction [dbo].[fLvmGetStrBetween]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- select dbo.fLvmGetStrBetween('i=32&r=1&t1=Test', 'i=', '&')
-- select dbo.fLvmGetStrBetween('i=321', 'i=', '&')
ALTER FUNCTION [dbo].[fLvmGetStrBetween]
(
	@Str varchar(3000),
	@SFrom varchar(200),
	@STo varchar(200)
)
RETURNS varchar(3000)
AS
BEGIN
	declare @iFrom int, @iTo int, @iLen int

	set @iFrom=CHARINDEX(@SFrom, @Str);
	set @iLen=LEN(@SFrom);
	set @iTo=CHARINDEX(@STo, @Str);

	--return cast(@iTo as varchar(10))

	if (@iTo=0) set @iTo=len(@Str)+1

	RETURN (select SUBSTRING(@Str, (@iFrom + @iLen), (@iTo - @iFrom - @iLen)))
END
GO
/****** Object:  UserDefinedFunction [dbo].[fSplit]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- SELECT i.Itm FROM dbo.fSplit('1|2|3','|') AS i

ALTER FUNCTION [dbo].[fSplit](@String varchar(8000), @Delimiter char(1))       
returns @Tbl TABLE (Itm varchar(8000))       
as       
begin       
    declare @idx int       
    declare @slice varchar(8000)       

    select @idx = 1       
        if len(@String)<1 or @String is null  return       

    while @idx!= 0       
    begin       
        set @idx = charindex(@Delimiter,@String)       
        if @idx!=0       
            set @slice = left(@String,@idx - 1)       
        else       
            set @slice = @String       

		-- insert empty values
        --if(len(@slice)>0)  
            insert into @Tbl(Itm) values(@slice)       

        set @String = right(@String,len(@String) - @idx)       
        if len(@String) = 0 break       
    end   
return      

end
GO
/****** Object:  UserDefinedFunction [dbo].[IsValidURL]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dbo].[IsValidURL] (@Url VARCHAR(200))
RETURNS INT
AS
BEGIN
    IF CHARINDEX('https://', @url) <> 1 AND CHARINDEX('http://', @url) <> 1
    BEGIN
        RETURN 0;   -- Not a valid 
    END

    -- Get rid of the http:// stuff
    SET @Url = REPLACE(@URL, 'https://', '');

	-- Get rid of slashes
    SET @Url = REPLACE(@URL, '/', '');

    -- Now we need to check that we only have digits or numbers
    IF (@Url LIKE '%[^a-z0-9]%.%[^a-z0-9]%.%[^a-z0-9]%')
    BEGIN
        RETURN 0;
    END

    -- It is a valid URL
    RETURN 1;
END
GO
/****** Object:  StoredProcedure [dbo].[sLvm_BeaconActionReplaceTags]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- sLvm_DeviceActionReplaceTags 1
ALTER PROCEDURE [dbo].[sLvm_BeaconActionReplaceTags]
@BeaconId int
AS
BEGIN
	SET NOCOUNT ON;

SELECT b.BeaconCode, STRING_AGG(ISNULL((bd.Number + ISNULL(' (' + p.FullName + ')', '')), ''), ',') AS PatientName, 
f.Number as FloorNumber, ISNULL(dp.DepartmentName, '') AS DepartmentName, ISNULL(e.EquipmentName, '') AS EquipmentName
FROM  Lvm_Beacon AS b INNER JOIN
         Lvm_Floor AS f ON b.FloorId = f.FloorId LEFT OUTER JOIN
		 Lvm_Department AS dp ON b.DepartmentId = dp.DepartmentId LEFT OUTER JOIN
		 Lvm_Equipment as e ON b.EquipmentId = e.EquipmentId LEFT OUTER JOIN
		 Lvm_Patient AS p ON b.PatientId = p.PatientId and p.PatientStatusId = 1 LEFT OUTER JOIN
		 Lvm_Bed as bd ON p.BedId = bd.BedId
WHERE (b.BeaconId = @BeaconId)
GROUP BY b.BeaconCode, f.Number, dp.DepartmentName, e.EquipmentName

END
GO
/****** Object:  StoredProcedure [dbo].[sLvm_BeaconCsvImport]    Script Date: 4/25/2018 11:54:47 AM ******/
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

	declare @FacilityName varchar(100), @FloorNumber varchar(50), @DepartmentName varchar(100), @PatientName varchar(200), @EquipmentName varchar(200), @BeaconName varchar(100), @BeaconCode varchar(100), @BeaconDescription varchar(2000), @ImageFile varchar(1000)
	declare @FacilityId int, @FloorId int, @DepartmentId int, @PatientId int, @EquipmentId int

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
	select @BeaconDescription = Fld from @tbl where Id=8

	set @ImageFile = 'beacon-default.png';
	select @ImageFile = case Fld when '' then 'beacon-default.png' else Fld end from @tbl where Id=9;

	set @FacilityId = isnull((select top 1 FacilityId from Lvm_Facility where FacilityName=@FacilityName),0)
	set @FloorId = isnull((select top 1 FloorId from Lvm_Floor where FacilityId=@FacilityId and Number=@FloorNumber),0)
	set @DepartmentId = isnull((select top 1 DepartmentId from Lvm_Department where FacilityId=@FacilityId and FloorId=@FloorId and DepartmentName=@DepartmentName),null)
	set @PatientId = isnull((select top 1 PatientId from Lvm_Patient where FacilityId=@FacilityId and FloorId=@FloorId and FullName=@PatientName),null)
	set @EquipmentId =	isnull((select top 1 EquipmentId from Lvm_Equipment where FacilityId=@FacilityId and FloorId=@FloorId and DepartmentId=@DepartmentId and EquipmentName=@EquipmentName),null) 

	if (@FacilityId=0) set @Msg= @Msg + ' Facility "' + @FacilityName + '" is not found.'
	if (@FloorId=0) set @Msg= @Msg + ' Floor "' + @FloorNumber + '" is not found.'
	if (@PatientId is null and @EquipmentId is null) set @Msg= @Msg + 'Equipment "' + @EquipmentName + '" and Patient "' + @PatientName + '" are not found.'

	set @Msg = LTRIM(@Msg);

	if (@BeaconName='')
	begin
		set @BeaconName=null
	end

	IF ((@FacilityId > 0 and @FloorId > 0 and (@Equipmentid > 0 or @PatientId > 0) and @BeaconCode<>'' and (@Msg = '' or @Msg is null)) and 
		(NOT EXISTS (SELECT * FROM Lvm_Beacon WHERE FacilityId = @FacilityId AND BeaconCode = @BeaconCode)))
	begin
		set @ErrCode = 1
		insert into Lvm_Beacon(FacilityId, FloorId, DepartmentId, EquipmentId, PatientId, BeaconCode, BeaconName, BeaconDescription) 
		values(@FacilityId, @FloorId, @DepartmentId, @EquipmentId, @PatientId, @BeaconCode, isnull(@BeaconName,@BeaconCode), isnull(@BeaconDescription,''))
	end
	else
	begin
		set @ErrCode = -1
		set @Err = @Msg
	end
end
GO
/****** Object:  StoredProcedure [dbo].[sLvm_DeviceActionReplaceTags]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- sLvm_DeviceActionReplaceTags 1
ALTER PROCEDURE [dbo].[sLvm_DeviceActionReplaceTags]
@DeviceId int
AS
BEGIN
	SET NOCOUNT ON;

SELECT d.DeviceCode, r.RoomNumber, STRING_AGG(ISNULL((bd.Number + ISNULL(' (' + p.FullName + ')', '')), ''), ',') AS BedNumber, f.Number as FloorNumber, dp.DepartmentId
FROM  Lvm_Device AS d INNER JOIN
         Lvm_Floor AS f ON d.FloorId = f.FloorId LEFT OUTER JOIN
         Lvm_Room AS r ON d.RoomId = r.RoomId LEFT OUTER JOIN
		 Lvm_Department AS dp ON r.DepartmentId = dp.DepartmentId LEFT OUTER JOIN
		 Lvm_BedLvm_Device as ldb ON d.DeviceId = ldb.Lvm_Device_DeviceId LEFT OUTER JOIN
		 Lvm_Bed as bd ON ldb.Lvm_Bed_BedId = bd.BedId LEFT OUTER JOIN
		 Lvm_Patient AS p ON ldb.Lvm_Bed_BedId = p.BedId and p.PatientStatusId = 1
WHERE (d.DeviceId = @DeviceId)
GROUP BY d.DeviceCode, f.Number, r.RoomNumber, dp.DepartmentId

END
GO
/****** Object:  StoredProcedure [dbo].[sLvm_DeviceCsvImport]    Script Date: 4/25/2018 11:54:47 AM ******/
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

	set @ImageFile = 'device-default.png';
	select @ImageFile = case Fld when '' then 'device-default.png' else Fld end from @tbl where Id=9;

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
GO
/****** Object:  StoredProcedure [dbo].[sLvm_FilterBeacons]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[sLvm_FilterBeacons]
	-- Add the parameters for the stored procedure here
	@FacilityId int,
	@DepartmentId int,
	@FloorId int,
	@PatientId int,
	@EquipmentId int,
	@BeaconId int,
	@Txt varchar(50) = N''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
	[BeaconId] AS [BeaconId],
	[EquipmentId] AS [EquipmentId],
	[FacilityId] AS [FacilityId],
	[FloorId] AS [FloorId],
	[DepartmentId] AS [DepartmentId],
	[PatientId] AS [PatientId],
	[DeviceTypeId] AS [DeviceTypeId],
	[BeaconName] AS [BeaconName],
	[BeaconDescription] AS [BeaconDescription],
	[BeaconCode] AS [BeaconCode],
	[ImageFile] AS [ImageFile],
	[ImageId] AS [ImageId],
	[MediaTypeId] AS [MediaTypeId]

	FROM ( SELECT
		[Extent1].[BeaconId] AS [BeaconId],
		[Extent1].[EquipmentId] AS [EquipmentId],
		[Extent1].[FacilityId] AS [FacilityId],
		[Extent1].[FloorId] AS [FloorId],
		[Extent1].[DepartmentId] AS [DepartmentId],
		[Extent1].[PatientId] AS [PatientId],
		[Extent1].[DeviceTypeId] AS [DeviceTypeId],
		[Extent1].[BeaconName] AS [BeaconName],
		[Extent1].[BeaconDescription] AS [BeaconDescription],
		[Extent1].[BeaconCode] AS [BeaconCode],
		[Extent1].[MediaTypeId] AS [MediaTypeId],
		[Extent1].[ImageId] AS [ImageId],
		[Extent1].[ImageFile] AS [ImageFile],
		[Extent2].[FacilityName] AS [FacilityName],
		[Extent3].[Number] AS [FloorNumber],
		[Extent4].[DepartmentName] AS [DepartmentName]
	
		FROM  [dbo].[Lvm_Beacon] AS [Extent1]
		INNER JOIN [dbo].[Lvm_Facility] AS [Extent2] ON [Extent1].[FacilityId] = [Extent2].[FacilityId]
		LEFT OUTER JOIN [dbo].[Lvm_Floor] AS [Extent3] ON [Extent1].[FloorId] = [Extent3].[FloorId]
		LEFT OUTER JOIN [dbo].[Lvm_Department] AS [Extent4] ON [Extent1].[DepartmentId] = [Extent4].[DepartmentId]
		LEFT OUTER JOIN [dbo].[Lvm_Patient] AS [Extent5] ON [Extent1].[PatientId] = [Extent5].[PatientId]
		LEFT OUTER JOIN [dbo].[Lvm_Equipment] AS [Extent6] ON [Extent1].[EquipmentId] = [Extent6].[EquipmentId]
			WHERE 
			((([Extent1].[FacilityId] = @FacilityId) AND ([Extent1].[FacilityId] IN (
				SELECT [temp].[FacilityId] as [FacilityId]
					FROM [dbo].[Lvm_Facility] as [temp]
			))) OR (([Extent1].[FacilityId] IS NULL) AND (@FacilityId IS NULL)))

			AND (((0 = @DepartmentId) AND ([Extent4].[DepartmentId] IN (
				SELECT [temp1].[DepartmentId] as [DepartmentId]
					FROM [dbo].[Lvm_Department] as [temp1]
			))) OR ([Extent4].[DepartmentId] = @DepartmentId) OR ([Extent4].[DepartmentId] is NULL AND (@DepartmentId = 0 OR @DepartmentId IS NULL)))
			
			AND (((0 = @FloorId) AND ([Extent3].[FloorId] IN (
				SELECT [temp2].[FloorId] as [FloorId]
					FROM [dbo].[Lvm_Floor] as [temp2]
			))) OR ([Extent3].[FloorId] = @FloorId) OR (([Extent3].[FloorId] is NULL) AND (@FloorId = 0 OR @FloorId IS NULL)))
			
			AND (((0 = @PatientId) AND ([Extent5].[PatientId] IN (
				SELECT [temp3].[PatientId] as [PatientId]
					FROM [dbo].[Lvm_Patient] as [temp3]
			))) OR ([Extent5].[PatientId] = @PatientId) OR (([Extent5].[PatientId] is NULL) AND (@PatientId = 0 OR @PatientId IS NULL)))
			
			AND (((0 = @EquipmentId) AND ([Extent6].[EquipmentId] IN (
				SELECT [temp4].[EquipmentId] as [EquipmentId]
					FROM [dbo].[Lvm_Equipment] as [temp4]
			))) OR ([Extent6].[EquipmentId] = @EquipmentId) OR (([Extent6].[EquipmentId] is NULL) AND (@EquipmentId = 0 OR @EquipmentId IS NULL)))

			AND (([Extent1].[BeaconId] = @BeaconId) OR @BeaconId = 0)
			AND ((N'' = @Txt) OR (CHARINDEX(@Txt, [Extent1].[BeaconName]) > 0))
			)  AS [Lvm_Beacon]
		ORDER BY [Lvm_Beacon].[FacilityName], [Lvm_Beacon].[FloorNumber], [Lvm_Beacon].[DepartmentName], [Lvm_Beacon].[BeaconName] ASC
END
GO
/****** Object:  StoredProcedure [dbo].[sLvm_FilterDevices]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[sLvm_FilterDevices]
	-- Add the parameters for the stored procedure here
	@FacilityId int,
	@DepartmentId int,
	@FloorId int,
	@RoomId int,
	--@BedId int,
	@DeviceId int,
	@Txt varchar(50) = N''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
	[DeviceId] AS [DeviceId],
	[DeviceCode] AS [DeviceCode],
	[RoomId] AS [RoomId], 
	[DeviceName] AS [DeviceName],
	[FacilityId] AS [FacilityId], 
	[DepartmentId] AS [DepartmentId], 
	[FloorId] AS [FloorId],
	[ImageId] AS [ImageId],
	[MediaTypeId] AS [MediaTypeId],
	[DeviceDescription] AS [DeviceDescription],
	[DeviceNumber] AS [DeviceNumber],
	[DeviceTypeId] AS [DeviceTypeId],
	[ImageFile] AS [ImageFile],
	[FacilityName] AS [FacilityName],
	[DepartmentName] AS [DepartmentName],
	[FloorNumber] AS [Number],
	[RoomNumber] AS [RoomNumber], 
	[RoomDescription] AS [RoomDescription],
	[CoordX] AS [CoordX],
	[CoordY] AS [CoordY]

	FROM ( SELECT
		[Extent1].[DeviceId] AS [DeviceId],
		[Extent1].[RoomId] AS [RoomId],
		[Extent1].[FacilityId] AS [FacilityId],
		[Extent1].[ImageId] AS [ImageId],
		[Extent1].[MediaTypeId] AS [MediaTypeId],
		[Extent1].[CoordX] AS [CoordX],
		[Extent1].[CoordY] AS [CoordY],
		[Extent1].[DeviceName] AS [DeviceName],
		[Extent1].[DeviceCode] AS [DeviceCode],
		[Extent1].[DeviceDescription] AS [DeviceDescription],
		[Extent1].[DeviceNumber] AS [DeviceNumber],
		[Extent1].[DeviceTypeId] AS [DeviceTypeId],
		[Extent1].[ImageFile] AS [ImageFile],
		[Extent2].[FacilityName] AS [FacilityName],
		[Extent3].[RoomNumber] AS [RoomNumber],
		[Extent3].[RoomDescription] AS [RoomDescription],
		[Extent4].[Number] AS [FloorNumber],
		[Extent4].[FloorId] AS [FloorId],
		[Extent5].[DepartmentId] AS [DepartmentId],
		[Extent5].[DepartmentName] AS [DepartmentName]
	
		FROM  [dbo].[Lvm_Device] AS [Extent1]
		INNER JOIN [dbo].[Lvm_Facility] AS [Extent2] ON [Extent1].[FacilityId] = [Extent2].[FacilityId]
		LEFT OUTER JOIN [dbo].[Lvm_Room] AS [Extent3] ON [Extent1].[RoomId] = [Extent3].[RoomId]
		INNER JOIN [dbo].[Lvm_Floor] AS [Extent4] ON [Extent1].[FloorId] = [Extent4].[FloorId]
		LEFT OUTER JOIN [dbo].[Lvm_Department] AS [Extent5] ON [Extent3].[DepartmentId] = [Extent5].[DepartmentId]
		INNER JOIN [dbo].[Lvm_DeviceType] AS [Extent6] ON [Extent1].[DeviceTypeId] = [Extent6].[DeviceTypeId]
			WHERE 
			((([Extent1].[FacilityId] = @FacilityId) AND ([Extent1].[FacilityId] IN (
				SELECT [temp].[FacilityId] as [FacilityId]
					FROM [dbo].[Lvm_Facility] as [temp]
			))) OR (([Extent1].[FacilityId] IS NULL) AND (@FacilityId IS NULL)))
			
			AND (((0 = @DepartmentId) AND ([Extent5].[DepartmentId] IN (
				SELECT [temp1].[DepartmentId] as [DepartmentId]
					FROM [dbo].[Lvm_Department] as [temp1]
			))) OR ([Extent5].[DepartmentId] = @DepartmentId) OR ([Extent5].[DepartmentId] is NULL AND (@DepartmentId = 0 OR @DepartmentId IS NULL)))
			
			AND (((0 = @FloorId) AND ([Extent4].[FloorId] IN (
				SELECT [temp2].[FloorId] as [FloorId]
					FROM [dbo].[Lvm_Floor] as [temp2]
			))) OR ([Extent4].[FloorId] = @FloorId) OR (([Extent4].[FloorId] is NULL) AND (@FloorId IS NULL)))

			AND (((0 = @RoomId) AND ([Extent1].[RoomId] IN (
				SELECT [temp3].[RoomId] as [RoomId]
					FROM [dbo].[Lvm_Room] as [temp3]
					WHERE (((0 = @FloorId) AND ([Extent4].[FloorId] IN (
							SELECT [temp2].[FloorId] as [FloorId]
								FROM [dbo].[Lvm_Floor] as [temp2]
						))) OR ([Extent4].[FloorId] = @FloorId) OR (([Extent4].[FloorId] is NULL) AND (@FloorId IS NULL)))
			))) OR ([Extent1].[RoomId] = @RoomId) OR (([Extent1].[RoomId] is NULL) AND (@RoomId = 0 OR @RoomId IS NULL)))

/*
			AND (((0 = @BedId) AND ([Extent1].[BedId] IN (
				SELECT [temp4].[BedId] as [BedId]
					FROM [dbo].[Lvm_Bed] as [temp4]
					WHERE (((0 = @RoomId) AND ([Extent1].[RoomId] IN (
							SELECT [temp3].[RoomId] as [RoomId]
								FROM [dbo].[Lvm_Room] as [temp3]
								WHERE (((0 = @FloorId) AND ([Extent4].[FloorId] IN (
										SELECT [temp2].[FloorId] as [FloorId]
											FROM [dbo].[Lvm_Floor] as [temp2]
									))) OR ([Extent4].[FloorId] = @FloorId) OR ([Extent4].[FloorId] is NULL) OR (@FloorId IS NULL))
						))) OR ([Extent1].[RoomId] = @RoomId) OR ([Extent1].[RoomId] is NULL) OR (@RoomId IS NULL))
			))) OR ([Extent1].[BedId] = @BedId) OR ([Extent1].[BedId] is NULL) OR (@BedId IS NULL))
*/

			AND (([Extent1].[DeviceId] = @DeviceId) OR @DeviceId = 0)
			AND ((N'' = @Txt) OR (CHARINDEX(@Txt, [Extent1].[DeviceName]) > 0) OR (CHARINDEX(@Txt, [Extent1].[DeviceCode]) > 0) OR (CHARINDEX(@Txt, [Extent1].[DeviceNumber]) > 0))
			)  AS [Lvm_Device]
		ORDER BY [Lvm_Device].[FacilityName], [Lvm_Device].[FloorNumber], [Lvm_Device].[DepartmentName], [Lvm_Device].[RoomNumber], [Lvm_Device].[DeviceName] ASC
END
GO
/****** Object:  StoredProcedure [dbo].[sLvm_FilterEquipment]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[sLvm_FilterEquipment]
	-- Add the parameters for the stored procedure here
	@FacilityId int,
	@DepartmentId int,
	@FloorId int,
	@EquipmentId int,
	@Txt varchar(50) = N''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
	[EquipmentId] AS [EquipmentId],
	[FacilityId] AS [FacilityId],
	[FloorId] AS [FloorId],
	[DepartmentId] AS [DepartmentId],
	[EquipmentName] AS [EquipmentName],
	[EquipmentDescription] AS [EquipmentDescription],
	[IsActive] AS [IsActive]

	FROM ( SELECT
		[Extent1].[EquipmentId] AS [EquipmentId],
		[Extent1].[FacilityId] AS [FacilityId],
		[Extent1].[FloorId] AS [FloorId],
		[Extent1].[DepartmentId] AS [DepartmentId],
		[Extent1].[EquipmentName] AS [EquipmentName],
		[Extent1].[EquipmentDescription] AS [EquipmentDescription],
		[Extent2].[FacilityName] AS [FacilityName],
		[Extent3].[Number] AS [FloorNumber],
		[Extent4].[DepartmentName] AS [DepartmentName],
		[Extent1].[IsActive] AS [IsActive]
	
		FROM  [dbo].[Lvm_Equipment] AS [Extent1]
		INNER JOIN [dbo].[Lvm_Facility] AS [Extent2] ON [Extent1].[FacilityId] = [Extent2].[FacilityId]
		LEFT OUTER JOIN [dbo].[Lvm_Floor] AS [Extent3] ON [Extent1].[FloorId] = [Extent3].[FloorId]
		LEFT OUTER JOIN [dbo].[Lvm_Department] AS [Extent4] ON [Extent1].[DepartmentId] = [Extent4].[DepartmentId]
			WHERE 
			((([Extent1].[FacilityId] = @FacilityId) AND ([Extent1].[FacilityId] IN (
				SELECT [temp].[FacilityId] as [FacilityId]
					FROM [dbo].[Lvm_Facility] as [temp]
			))) OR (([Extent1].[FacilityId] IS NULL) AND (@FacilityId IS NULL)))

			AND (((0 = @DepartmentId) AND ([Extent4].[DepartmentId] IN (
				SELECT [temp1].[DepartmentId] as [DepartmentId]
					FROM [dbo].[Lvm_Department] as [temp1]
			))) OR ([Extent4].[DepartmentId] = @DepartmentId) OR ([Extent4].[DepartmentId] is NULL AND (@DepartmentId = 0 OR @DepartmentId IS NULL)))
			
			AND (((0 = @FloorId) AND ([Extent3].[FloorId] IN (
				SELECT [temp2].[FloorId] as [FloorId]
					FROM [dbo].[Lvm_Floor] as [temp2]
			))) OR ([Extent3].[FloorId] = @FloorId) OR (([Extent3].[FloorId] is NULL) AND (@FloorId = 0 OR @FloorId IS NULL)))

			AND (([Extent1].[EquipmentId] = @EquipmentId) OR @EquipmentId = 0)
			--AND ([Extent1].[IsActive] = 1)
			AND ((N'' = @Txt) OR (CHARINDEX(@Txt, [Extent1].[EquipmentName]) > 0))
			)  AS [Lvm_Equipment]
		ORDER BY [Lvm_Equipment].[FacilityName], [Lvm_Equipment].[FloorNumber], [Lvm_Equipment].[DepartmentName], [Lvm_Equipment].[EquipmentName] ASC
END
GO
/****** Object:  StoredProcedure [dbo].[sLvm_FilterFloors]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[sLvm_FilterFloors]
	-- Add the parameters for the stored procedure here
	@FacilityId int,
	@FloorId int,
	@Txt varchar(50) = N''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
	[FloorId] AS [FloorId],
	[Number] AS [Number],
	[PlanPath] AS [PlanPath],
	[FacilityId] AS [FacilityId], 
	[Description] AS [Description],
	[CalibrationLineCoordinates] AS [CalibrationLineCoordinates],
	[FacilityName] AS [FacilityName],
	[CalibrationLineMeasurement] AS [CalibrationLineMeasurement],
	[CalibrationRatioCoefficient] AS [CalibrationRatioCoefficient],
	[HeightPx] AS [HeightPx],
	[WidthPx] AS [WidthPx],
	[Created] AS [Created],
	[Updated] AS [Updated]

	FROM ( SELECT
		[Extent1].[FloorId] AS [FloorId],
		[Extent1].[FacilityId] AS [FacilityId],
		[Extent1].[Number] AS [Number],
		[Extent1].[PlanPath] AS [PlanPath],
		[Extent1].[HeightPx] AS [HeightPx],
		[Extent1].[WidthPx] AS [WidthPx],
		[Extent1].[Created] AS [Created],
		[Extent1].[Updated] AS [Updated],
		[Extent1].[Description] AS [Description],
		[Extent1].[CalibrationLineCoordinates] AS [CalibrationLineCoordinates],
		[Extent1].[CalibrationLineMeasurement] AS [CalibrationLineMeasurement],
		[Extent1].[CalibrationRatioCoefficient] AS [CalibrationRatioCoefficient],
		[Extent2].[FacilityName] AS [FacilityName]
	
		FROM  [dbo].[Lvm_Floor] AS [Extent1]
		INNER JOIN [dbo].[Lvm_Facility] AS [Extent2] ON [Extent1].[FacilityId] = [Extent2].[FacilityId]
			WHERE 
			((([Extent1].[FacilityId] = @FacilityId) AND ([Extent1].[FacilityId] IN (
				SELECT [temp].[FacilityId] as [FacilityId]
					FROM [dbo].[Lvm_Facility] as [temp]
			))) OR (([Extent1].[FacilityId] IS NULL) AND (@FacilityId IS NULL)))

			AND (([Extent1].[FloorId] = @FloorId) OR @FloorId = 0)
			AND ((N'' = @Txt) OR (CHARINDEX(@Txt, [Extent1].[Number]) > 0) OR (CHARINDEX(@Txt, [Extent1].[Description]) > 0))
			)  AS [Lvm_Floor]
		ORDER BY [Lvm_Floor].[FacilityName], [Lvm_Floor].[Number] ASC
END
GO
/****** Object:  StoredProcedure [dbo].[sLvm_FilterPatients]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[sLvm_FilterPatients]
	-- Add the parameters for the stored procedure here
	@FacilityId int,
	@DepartmentId int,
	@FloorId int,
	@RoomId int,
	@BedId int,
	@PatientId int,
	@PatientStatusId int = 0,
	@Txt varchar(50) = N''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
	[PatientId] AS [PatientId],
	[PatientSexId] AS [PatientSexId],
	[PatientStatusId] AS [PatientStatusId],
	[NamePrefixId] AS [NamePrefixId],
	[ImageId] AS [ImageId],
	[RoomId] AS [RoomId], 
	[BedId] AS [BedId],
	[FacilityId] AS [FacilityId], 
	[DepartmentId] AS [DepartmentId], 
	[FloorId] AS [FloorId],
	[FullName] AS [FullName],
	[BirthDate] AS [BirthDate],
	[Age] AS [Age],
	[ContactNumberHome] AS [ContactNumberHome],
	[ContactNumberCell] AS [ContactNumberCell],
	[ContactNumberWork] AS [ContactNumberWork],
	[EmergencyContactName] AS [EmergencyContactName],
	[EmergencyContactNumber] AS [EmergencyContactNumber],
	[EmergencyContactRelation] AS [EmergencyContactRelation],
	[HealthCardNumber] AS [HealthCardNumber],
	[InsuranceNumber] AS [InsuranceNumber],
	[Doctor] AS [Doctor],
	[Description] AS [Description],
	[ImageFile] AS [ImageFile],
	[FacilityName] AS [FacilityName],
	[DepartmentName] AS [DepartmentName],
	[FloorNumber] AS [Number],
	[RoomNumber] AS [RoomNumber], 
	[RoomDescription] AS [RoomDescription]

	FROM ( SELECT
		[Extent1].[PatientId] AS [PatientId],
		[Extent1].[FullName] AS [FullName],
		[Extent1].[PatientSexId] AS [PatientSexId],
		[Extent1].[PatientStatusId] AS [PatientStatusId],
		[Extent1].[RoomId] AS [RoomId],
		[Extent1].[FacilityId] AS [FacilityId],
		[Extent1].[BedId] AS [BedId],
		[Extent1].[NamePrefixId] AS [NamePrefixId],
		[Extent1].[ImageId] AS [ImageId],
		[Extent1].[BirthDate] AS [BirthDate],
		[Extent1].[Age] AS [Age],
		[Extent1].[ContactNumberHome] AS [ContactNumberHome],
		[Extent1].[ContactNumberCell] AS [ContactNumberCell],
		[Extent1].[ContactNumberWork] AS [ContactNumberWork],
		[Extent1].[EmergencyContactName] AS [EmergencyContactName],
		[Extent1].[EmergencyContactNumber] AS [EmergencyContactNumber],
		[Extent1].[EmergencyContactRelation] AS [EmergencyContactRelation],
		[Extent1].[HealthCardNumber] AS [HealthCardNumber],
		[Extent1].[InsuranceNumber] AS [InsuranceNumber],
		[Extent1].[Doctor] AS [Doctor],
		[Extent1].[Description] AS [Description],
		[Extent1].[ImageFile] AS [ImageFile],
		[Extent2].[FacilityName] AS [FacilityName],
		[Extent3].[RoomNumber] AS [RoomNumber],
		[Extent3].[RoomDescription] AS [RoomDescription],
		[Extent4].[Number] AS [FloorNumber],
		[Extent4].[FloorId] AS [FloorId],
		[Extent5].[DepartmentId] AS [DepartmentId],
		[Extent5].[DepartmentName] AS [DepartmentName]
	
		FROM  [dbo].[Lvm_Patient] AS [Extent1]
		INNER JOIN [dbo].[Lvm_Facility] AS [Extent2] ON [Extent1].[FacilityId] = [Extent2].[FacilityId]
		INNER JOIN [dbo].[Lvm_Room] AS [Extent3] ON [Extent1].[RoomId] = [Extent3].[RoomId]
		INNER JOIN [dbo].[Lvm_Floor] AS [Extent4] ON [Extent3].[FloorId] = [Extent4].[FloorId]
		LEFT OUTER JOIN [dbo].[Lvm_Department] AS [Extent5] ON [Extent3].[DepartmentId] = [Extent5].[DepartmentId]
			WHERE 
			((([Extent1].[FacilityId] = @FacilityId) AND ([Extent1].[FacilityId] IN (
				SELECT [temp].[FacilityId] as [FacilityId]
					FROM [dbo].[Lvm_Facility] as [temp]
			))) OR (([Extent1].[FacilityId] IS NULL) AND (@FacilityId IS NULL)))
			
			AND (((0 = @DepartmentId) AND ([Extent5].[DepartmentId] IN (
				SELECT [temp1].[DepartmentId] as [DepartmentId]
					FROM [dbo].[Lvm_Department] as [temp1]
			))) OR ([Extent5].[DepartmentId] = @DepartmentId) OR ([Extent5].[DepartmentId] is NULL AND (@DepartmentId = 0 OR @DepartmentId IS NULL)))
			
			AND (((0 = @FloorId) AND ([Extent4].[FloorId] IN (
				SELECT [temp2].[FloorId] as [FloorId]
					FROM [dbo].[Lvm_Floor] as [temp2]
			))) OR ([Extent4].[FloorId] = @FloorId) OR (([Extent4].[FloorId] is NULL) AND (@FloorId IS NULL)))

			AND (((0 = @RoomId) AND ([Extent1].[RoomId] IN (
				SELECT [temp3].[RoomId] as [RoomId]
					FROM [dbo].[Lvm_Room] as [temp3]
					WHERE (((0 = @FloorId) AND ([Extent4].[FloorId] IN (
							SELECT [temp2].[FloorId] as [FloorId]
								FROM [dbo].[Lvm_Floor] as [temp2]
						))) OR ([Extent4].[FloorId] = @FloorId) OR (([Extent4].[FloorId] is NULL) AND (@FloorId IS NULL)))
			))) OR ([Extent1].[RoomId] = @RoomId) OR (([Extent1].[RoomId] is NULL) AND (@RoomId = 0 OR @RoomId IS NULL)))

			AND (((0 = @BedId) AND ([Extent1].[BedId] IN (
				SELECT [temp4].[BedId] as [BedId]
					FROM [dbo].[Lvm_Bed] as [temp4]
					WHERE (((0 = @RoomId) AND ([Extent1].[RoomId] IN (
							SELECT [temp3].[RoomId] as [RoomId]
								FROM [dbo].[Lvm_Room] as [temp3]
								WHERE (((0 = @FloorId) AND ([Extent4].[FloorId] IN (
										SELECT [temp2].[FloorId] as [FloorId]
											FROM [dbo].[Lvm_Floor] as [temp2]
									))) OR ([Extent4].[FloorId] = @FloorId) OR (([Extent4].[FloorId] is NULL) AND (@FloorId IS NULL)))
						))) OR ([Extent1].[RoomId] = @RoomId) OR (([Extent1].[RoomId] is NULL) AND (@RoomId = 0 OR @RoomId IS NULL)))
			))) OR ([Extent1].[BedId] = @BedId) OR ([Extent1].[BedId] is NULL) OR (@BedId IS NULL))

			AND (([Extent1].[PatientId] = @PatientId) OR @PatientId = 0)
			AND ((@PatientStatusId > 0 AND [Extent1].[PatientStatusId] = @PatientStatusId) OR @PatientStatusId = 0)
			AND ((N'' = @Txt) OR (CHARINDEX(@Txt, [Extent1].[FullName]) > 0))
			)  AS [Lvm_Patient]
		ORDER BY [Lvm_Patient].[FacilityName], [Lvm_Patient].[FloorNumber], [Lvm_Patient].[DepartmentName], [Lvm_Patient].[RoomNumber], [Lvm_Patient].[FullName] ASC
END
GO
/****** Object:  StoredProcedure [dbo].[sLvm_FilterRooms]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
ALTER PROCEDURE [dbo].[sLvm_FilterRooms]
	-- Add the parameters for the stored procedure here
	@FacilityId int,
	@DepartmentId int,
	@FloorId int,
	@RoomId int,
	@Txt varchar(50) = N''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
	[RoomId] AS [RoomId], 
	[FacilityId] AS [FacilityId], 
	[DepartmentId] AS [DepartmentId], 
	[FloorId] AS [FloorId],
	[FacilityName] AS [FacilityName],
	[DepartmentName] AS [DepartmentName],
	[FloorNumber] AS [Number],
	[RoomNumber] AS [RoomNumber],
	[RoomDescription] AS [RoomDescription]

	FROM ( SELECT
		[Extent1].[RoomId] AS [RoomId],
		[Extent1].[FacilityId] AS [FacilityId],
		[Extent1].[DepartmentId] AS [DepartmentId],
		[Extent1].[FloorId] AS [FloorId],
		[Extent1].[RoomNumber] AS [RoomNumber],
		[Extent1].[RoomDescription] AS [RoomDescription],
		[Extent2].[FacilityName] AS [FacilityName],
		[Extent3].[Number] AS [FloorNumber],
		[Extent4].[DepartmentName] AS [DepartmentName]
	
		FROM  [dbo].[Lvm_Room] AS [Extent1]
		INNER JOIN [dbo].[Lvm_Facility] AS [Extent2] ON [Extent1].[FacilityId] = [Extent2].[FacilityId]
		INNER JOIN [dbo].[Lvm_Floor] AS [Extent3] ON [Extent1].[FloorId] = [Extent3].[FloorId]
		LEFT OUTER JOIN [dbo].[Lvm_Department] AS [Extent4] ON [Extent1].[DepartmentId] = [Extent4].[DepartmentId]
			WHERE 
			((([Extent1].[FacilityId] = @FacilityId) AND ([Extent1].[FacilityId] IN (
				SELECT [temp].[FacilityId] as [FacilityId]
					FROM [dbo].[Lvm_Facility] as [temp]
			))) OR (([Extent1].[FacilityId] IS NULL) AND (@FacilityId IS NULL)))
			
			AND (((0 = @DepartmentId) AND ([Extent1].[DepartmentId] IN (
				SELECT [temp1].[DepartmentId] as [DepartmentId]
					FROM [dbo].[Lvm_Department] as [temp1]
			))) OR ([Extent1].[DepartmentId] = @DepartmentId) OR (([Extent1].[DepartmentId] is NULL) AND (@DepartmentId = 0 OR @DepartmentId IS NULL)))
			
			AND (((0 = @FloorId) AND ([Extent1].[FloorId] IN (
				SELECT [temp2].[FloorId] as [FloorId]
					FROM [dbo].[Lvm_Floor] as [temp2]
			))) OR ([Extent1].[FloorId] = @FloorId) OR (([Extent1].[FloorId] is NULL) AND (@FloorId IS NULL)))
			AND (([Extent1].[RoomId] = @RoomId) OR @RoomId = 0)
			AND ((N'' = @Txt) OR (CHARINDEX(@Txt, [Extent1].[RoomNumber]) > 0))
			)  AS [Lvm_Room]
		ORDER BY [Lvm_Room].[FacilityName], [Lvm_Room].[FloorNumber], [Lvm_Room].[DepartmentName], [Lvm_Room].[RoomNumber] ASC
END
GO
/****** Object:  StoredProcedure [dbo].[sLvm_GetLinkedTables]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- sLvm_GetLinkedTables 'Lvm_Facility', 'FacilityId', '', '1' -- 'Lvm_SecurityIp,Lvm_Room', '1'
ALTER PROCEDURE [dbo].[sLvm_GetLinkedTables]
@Tbl varchar(300),
@Id varchar(300),
@TblNot varchar(3000),
@IdVal  nvarchar(36) -- to hold uniqueidentifier
AS
SET FMTONLY OFF

DECLARE @TblName VARCHAR(300), @LinkTbl varchar(max); set @LinkTbl=''
DECLARE @Cur as CURSOR;
SET @Cur = CURSOR FOR
SELECT t.name AS TblName
FROM sys.tables AS t INNER JOIN sys.columns c ON t.OBJECT_ID = c.OBJECT_ID
WHERE c.name LIKE @Id  and  t.name <> @Tbl and left(t.name, 4) = 'Lvm_' and t.name not in (select Itm from dbo.fSplit(@TblNot,','))
ORDER BY TblName;

declare @LtblName varchar(max); CREATE TABLE #LTbl (LtblName varchar(max))

OPEN @Cur;
FETCH NEXT FROM @Cur INTO @TblName;

WHILE @@FETCH_STATUS = 0
BEGIN

EXEC ('insert into #LTbl select substring(''' + @TblName + ''',5, len(''' + @TblName + ''')-4) c from ' + @TblName + ' where ' + @Id + ' = ' + @IdVal + ' having count(*)>0')

FETCH NEXT FROM @Cur INTO @TblName;
END

CLOSE @Cur;
DEALLOCATE @Cur;

select * from #LTbl

drop table #LTbl 
GO
/****** Object:  StoredProcedure [dbo].[sLvm_IsBeaconControlOn]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- sLvm_IsDevControlOn 15
ALTER PROCEDURE [dbo].[sLvm_IsBeaconControlOn]
@BeaconActionId int,
@ControlOn int OUTPUT
AS
BEGIN
SET NOCOUNT ON;

declare @BeaconId int, @ControlNum int


SELECT @ControlNum = c.ControlNumber, @BeaconId = a.BeaconId
FROM Lvm_DeviceTypeControl AS c INNER JOIN 
Lvm_BeaconAction AS a ON c.DeviceTypeControlId = a.DeviceTypeControlId
WHERE a.BeaconActionId = @BeaconActionId

SELECT  @ControlOn = cast(COUNT(*) as bit)
FROM Lvm_MonitorRecord
where BeaconId=@BeaconId
and 
(
((@ControlNum=1) and Control1=1) or
((@ControlNum=2) and Control2=1) or
((@ControlNum=3) and Control3=1) or
((@ControlNum=4) and Control4=1) or
((@ControlNum=5) and Control5=1) or
((@ControlNum=6) and Control6=1) or
((@ControlNum=7) and Control7=1) or
((@ControlNum=8) and Control8=1)
)


END
GO
/****** Object:  StoredProcedure [dbo].[sLvm_IsDevControlOn]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- sLvm_IsDevControlOn 15
ALTER PROCEDURE [dbo].[sLvm_IsDevControlOn]
@DeviceActionId int,
@ControlOn int OUTPUT
AS
BEGIN
SET NOCOUNT ON;

declare @DevId int, @ControlNum int


SELECT @ControlNum = c.ControlNumber, @DevId = a.DeviceId
FROM Lvm_DeviceTypeControl AS c INNER JOIN Lvm_DeviceAction AS a ON c.DeviceTypeControlId = a.DeviceTypeControlId
WHERE a.DeviceActionId = @DeviceActionId

SELECT  @ControlOn = cast(COUNT(*) as bit)
FROM Lvm_MonitorRecord
where DeviceId=@DevId
and 
(
((@ControlNum=1) and Control1=1) or
((@ControlNum=2) and Control2=1) or
((@ControlNum=3) and Control3=1) or
((@ControlNum=4) and Control4=1) or
((@ControlNum=5) and Control5=1) or
((@ControlNum=6) and Control6=1) or
((@ControlNum=7) and Control7=1) or
((@ControlNum=8) and Control8=1)
)


END
GO
/****** Object:  StoredProcedure [dbo].[sLvm_RepCdrRec]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- sLvm_RepCdrRec 1, 1, '2017-01-01', '2018-03-22', 0, 0, '', '',  '103,104', -1 '', 1, 100
-- sLvm_RepCdrRec 1, 0, '2017-01-01', '2018-03-22', 0, 0, '', '',  '', -1 '', 1, 100
-- sLvm_RepCdrRec 2, 0, '2017-01-01', '2018-03-22', 0, 0, '', '',  '', -1 '', 1, 100
ALTER PROCEDURE [dbo].[sLvm_RepCdrRec]
@FacilityId int,
@DepartmentId int,
@DateFrom datetime,
@DateTo datetime,
@RingDurationMin int,
@CallDurationMin int,

@From varchar(100),
@To varchar(100),

@RoomList varchar(4000),
@BedList varchar(8000),

@Direction int, -- =-1

@Sort varchar(50)=''
,
@PageNumber int = 0, -- strart with 1
@PageSize int = 0
AS
BEGIN
	SET NOCOUNT ON;

if (@Sort='') set @Sort='CallStart DESC'

if (@DateTo = (CONVERT(date, @DateTo))) set @DateTo=DATEADD(d, 1, @DateTo)

declare @Tbl table (RecId int, CallStart datetime, CallEnd datetime, Department varchar(100), Room varchar(100), Bed varchar(500), Direction varchar(50), [From] varchar(50), [To] varchar(50), CallStatus varchar(50), RingDuration int, TalkTime int )

declare @CdrTypeId int;
SELECT @CdrTypeId = CdrTypeId FROM  Lvm_Facility WHERE (FacilityId = @FacilityId)
--select @CdrTypeId
if (@CdrTypeId=1) -- PortSip
	insert into @Tbl (RecId, CallStart, CallEnd, Department, Room, Bed, Direction, [From], [To], CallStatus, RingDuration, TalkTime)
	SELECT c.CdrPortSipId, c.CallStartTime, c.CallEndedTime, dp.DepartmentName, c.RoomNumber, STRING_AGG(ISNULL((bd.Number + ISNULL(' (' + p.FullName + ')', '')), ''), ',')
	, c.CallDirection, c.Caller, c.Callee, c.CallStatus, c.CallRingDuration, c.CallTalkTime
	FROM  Lvm_Device AS dv RIGHT OUTER JOIN
	Lvm_CdrPortSip AS c LEFT OUTER JOIN
	Lvm_Department AS dp ON c.DepartmentId = dp.DepartmentId ON dv.DeviceId = c.DeviceId LEFT OUTER JOIN
	Lvm_BedLvm_Device as ldb ON dv.DeviceId = ldb.Lvm_Device_DeviceId LEFT OUTER JOIN
	Lvm_Bed as bd ON ldb.Lvm_Bed_BedId = bd.BedId LEFT OUTER JOIN
	Lvm_PatientRecordLog AS pr ON bd.BedId = pr.BedId and pr.DatePatientAdmitted >= c.CallStartTime and pr.DatePatientAdmitted <= c.CallEndedTime LEFT OUTER JOIN
	Lvm_Patient AS p ON pr.PatientId = p.PatientId
	WHERE (c.FacilityId = @FacilityId) 
	and ((@Direction = -1) or ((@Direction = 0) and (c.CallDirection = 'Outbound')) or ((@Direction = 1) and (c.CallDirection = 'Inbound')))
	AND ((@DepartmentId = 0) or (c.DepartmentId = @DepartmentId)) 
	--AND (c.CallStartTime BETWEEN @DateFrom AND @DateTo) 
	AND ((@RingDurationMin = 0) or (c.CallRingDuration >= @RingDurationMin))
	AND ((@CallDurationMin = 0) or (c.CallTalkTime >= @CallDurationMin))
	AND ((@From = '') or (c.[Caller] = @From))
	AND ((@To = '') or (c.Callee = @To))
	AND (bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) OR c.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i))
	--and ((@RoomList='') or c.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i)) 
	--and ((@BedList='') or bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) or bd.Number is NULL or bd.Number = '')
	GROUP BY c.CdrPortSipId, c.CallStartTime, c.CallEndedTime, dp.DepartmentName, c.RoomNumber, c.CallDirection, c.Caller, c.Callee, c.CallStatus, c.CallRingDuration, c.CallTalkTime
else if (@CdrTypeId=2) -- Vodia
	insert into @Tbl (RecId, CallStart, CallEnd, Department, Room, Bed, Direction, [From], [To], CallStatus, RingDuration, TalkTime)
	SELECT c.CdrVodiaId, c.TimeStart, c.TimeEnd, dp.DepartmentName, c.RoomNumber, STRING_AGG(ISNULL((bd.Number + ISNULL(' (' + p.FullName + ')', '')), ''), ',')
	, case c.Direction when 1 then 'Inbound' else 'Outbound' end Direction, c.[From], c.[To], '', -- c.Quality -- Status ???
	c.RingDuration, c.Duration
	FROM  Lvm_CdrVodia AS c LEFT OUTER JOIN
	Lvm_Department AS dp ON c.DepartmentId = dp.DepartmentId LEFT OUTER JOIN
	Lvm_Device AS dv ON c.DeviceId = dv.DeviceId LEFT OUTER JOIN
	Lvm_BedLvm_Device as ldb ON dv.DeviceId = ldb.Lvm_Device_DeviceId LEFT OUTER JOIN
	Lvm_Bed as bd ON ldb.Lvm_Bed_BedId = bd.BedId LEFT OUTER JOIN
	Lvm_PatientRecordLog AS pr ON bd.BedId = pr.BedId and pr.DatePatientAdmitted >= c.TimeStart and pr.DatePatientAdmitted <= c.TimeEnd LEFT OUTER JOIN
	Lvm_Patient AS p ON pr.PatientId = p.PatientId
	WHERE (c.FacilityId = @FacilityId) 
	and ((@Direction = -1) or (c.Direction = @Direction))
	AND ((@DepartmentId = 0) or (c.DepartmentId = @DepartmentId)) 
	AND (c.TimeStart BETWEEN @DateFrom AND @DateTo) 
	AND ((@RingDurationMin = 0) or (c.RingDuration >= @RingDurationMin))
	AND ((@CallDurationMin = 0) or (c.Duration >= @CallDurationMin))
	AND ((@From = '') or (c.[From] = @From))
	AND ((@To = '') or (c.[To] = @To))
	AND (bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) OR c.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i))
	--and ((@RoomList='') or c.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i)) 
	--and ((@BedList='') or bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) or bd.Number is NULL or bd.Number = '')
	GROUP BY c.CdrVodiaId, c.TimeStart, c.TimeEnd, dp.DepartmentName, c.RoomNumber, c.RingDuration, c.Duration, c.Direction, c.[From], c.[To]
select *
from
(
select ROW_NUMBER() OVER (ORDER BY 
	CASE WHEN @Sort = 'CallStart desc' THEN CallStart END desc, 
	CASE WHEN @Sort = 'CallStart' THEN CallStart END, 
	CASE WHEN @Sort = 'CallEnd desc' THEN CallEnd END desc, 
	CASE WHEN @Sort = 'CallEnd' THEN CallEnd END, 
	CASE WHEN @Sort = 'Department desc' THEN Department END desc, 
	CASE WHEN @Sort = 'Department' THEN Department END, 
	CASE WHEN @Sort = 'Direction desc' THEN Direction END desc, 
	CASE WHEN @Sort = 'Direction' THEN Direction END, 
	CASE WHEN @Sort = 'Room desc' THEN Room END desc, 
	CASE WHEN @Sort = 'Room' THEN Room END, 
	CASE WHEN @Sort = 'Bed desc' THEN Bed END desc, 
	CASE WHEN @Sort = 'Bed' THEN Bed END, 
	CASE WHEN @Sort = '[From] desc' THEN [From] END desc, 
	CASE WHEN @Sort = '[From]' THEN [From] END, 
	CASE WHEN @Sort = '[To] desc' THEN [To] END desc, 
	CASE WHEN @Sort = '[To]' THEN [To] END,
	CASE WHEN @Sort = 'CallStatus desc' THEN CallStatus END desc, 
	CASE WHEN @Sort = 'CallStatus' THEN CallStatus END, 
	CASE WHEN @Sort = 'RingDuration desc' THEN RingDuration END desc, 
	CASE WHEN @Sort = 'RingDuration' THEN RingDuration END, 
	CASE WHEN @Sort = 'TalkTime desc' THEN TalkTime END desc, 
	CASE WHEN @Sort = 'TalkTime' THEN TalkTime END
)  AS Id, *
from
(
SELECT * FROM  @Tbl
) as t
) as t2
where ((@PageNumber = 0) or Id BETWEEN (@PageNumber - 1) * @PageSize + 1 And (@PageNumber * @PageSize))

END
GO
/****** Object:  StoredProcedure [dbo].[sLvm_RepCdrRecChart]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- sLvm_RepCdrRecChart 1, 1, '2017-01-01', '2018-03-22', 0, 0, '', '',  '103,104', -1
-- sLvm_RepCdrRecChart 1, 0, '2017-01-01', '2018-03-22', 0, 0, '', '',  '', -1
-- sLvm_RepCdrRecChart 2, 0, '2017-06-08', '2017-06-13', 0, 0, '', '',  '', -1
ALTER PROCEDURE [dbo].[sLvm_RepCdrRecChart]
@FacilityId int,
@DepartmentId int,
@DateFrom datetime,
@DateTo datetime,
@RingDurationMin int,
@CallDurationMin int,

@From varchar(100),
@To varchar(100),

@RoomList varchar(4000),
@BedList varchar(8000),
@Direction int -- =-1
AS
BEGIN
	SET NOCOUNT ON;

if (@DateTo = (CONVERT(date, @DateTo))) set @DateTo=DATEADD(d, 1, @DateTo)

declare @Tbl table (Id int, DateCall datetime, Calls int, CallStatus varchar(100))

declare @CdrTypeId int;
SELECT @CdrTypeId = CdrTypeId FROM  Lvm_Facility WHERE (FacilityId = @FacilityId)
--select @CdrTypeId
if (@CdrTypeId=1) -- PortSip
	insert into  @Tbl
	SELECT ROW_NUMBER() OVER (ORDER BY c.CallStartTime, c.CallStatus)  AS Id, c.CallStartTime DateCall,  1 Calls, c.CallStatus
	FROM  Lvm_Device AS dv RIGHT OUTER JOIN
	Lvm_CdrPortSip AS c LEFT OUTER JOIN
	Lvm_Department AS dp ON c.DepartmentId = dp.DepartmentId ON dv.DeviceId = c.DeviceId LEFT OUTER JOIN
	Lvm_BedLvm_Device as ldb ON dv.DeviceId = ldb.Lvm_Device_DeviceId LEFT OUTER JOIN
	Lvm_Bed as bd ON ldb.Lvm_Bed_BedId = bd.BedId
	WHERE (c.FacilityId = @FacilityId) 
	and ((@Direction = -1) or ((@Direction = 0) and (c.CallDirection = 'Outbound')) or ((@Direction = 1) and (c.CallDirection = 'Inbound')))
	AND ((@DepartmentId = 0) or (c.DepartmentId = @DepartmentId)) 
	--AND (c.CallStartTime BETWEEN @DateFrom AND @DateTo) 
	AND ((@RingDurationMin = 0) or (c.CallRingDuration >= @RingDurationMin))
	AND ((@CallDurationMin = 0) or (c.CallTalkTime >= @CallDurationMin))
	AND ((@From = '') or (c.[Caller] = @From))
	AND ((@To = '') or (c.Callee = @To))
	AND (bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) OR c.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i))
	--and ((@RoomList='') or c.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i)) 
	--and ((@BedList='') or bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) or bd.Number is NULL or bd.Number = '') 
else if (@CdrTypeId=2) -- Vodia
	insert into  @Tbl
	SELECT ROW_NUMBER() OVER (ORDER BY c.TimeStart /*, c.CallStatus*/)  AS Id, c.TimeStart DateCall,  1 Calls, '' CallStatus
	FROM  Lvm_CdrVodia AS c LEFT OUTER JOIN
	Lvm_Department AS dp ON c.DepartmentId = dp.DepartmentId LEFT OUTER JOIN
	Lvm_Device AS dv ON c.DeviceId = dv.DeviceId LEFT OUTER JOIN
	Lvm_BedLvm_Device as ldb ON dv.DeviceId = ldb.Lvm_Device_DeviceId LEFT OUTER JOIN
	Lvm_Bed as bd ON ldb.Lvm_Bed_BedId = bd.BedId
	WHERE (c.FacilityId = @FacilityId) 
	and ((@Direction = -1) or (c.Direction = @Direction))
	AND ((@DepartmentId = 0) or (c.DepartmentId = @DepartmentId)) 
	AND (c.TimeStart BETWEEN @DateFrom AND @DateTo) 
	AND ((@RingDurationMin = 0) or (c.RingDuration >= @RingDurationMin))
	AND ((@CallDurationMin = 0) or (c.Duration >= @CallDurationMin))
	AND ((@From = '') or (c.[From] = @From))
	AND ((@To = '') or (c.[To] = @To))
	AND (bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) OR c.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i))
	--and ((@RoomList='') or c.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i)) 
	--and ((@BedList='') or bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) or bd.Number is NULL or bd.Number = '') 

declare @DayDiff int; set @DayDiff = DATEDIFF(d, @DateFrom, @DateTo)

--select @DayDiff d, * from @Tbl

if (@DayDiff<3)			-- per hour
	select ROW_NUMBER() OVER (ORDER BY DateCall, CallStatus) AS Id, DateCall, Calls, CallStatus
	from
	(
	select dateadd(hour, datediff(hour, 0, DateCall), 0) as DateCall, 
	count(*) AS Calls, CallStatus
	from @Tbl
	GROUP BY dateadd(hour, datediff(hour, 0, DateCall), 0), CallStatus
	) t
else if (@DayDiff<32)	--per day
	select ROW_NUMBER() OVER (ORDER BY DateCall, CallStatus) AS Id, DateCall, Calls, CallStatus
	from
	(
	select CONVERT(date, DateCall) as DateCall, 
	count(*) AS Calls, CallStatus
	from @Tbl
	GROUP BY CONVERT(date, DateCall), CallStatus
	) t
else if (@DayDiff<92)	-- per week
	select ROW_NUMBER() OVER (ORDER BY DateCall, CallStatus) AS Id, DateCall, Calls, CallStatus
	from
	(
	select CONVERT(date,DATEADD(dd, 7-(DATEPART(dw, DateCall)), DateCall)) as DateCall, 
	count(*) AS Calls, CallStatus
	from @Tbl
	GROUP BY CONVERT(date,DATEADD(dd, 7-(DATEPART(dw, DateCall)), DateCall)), CallStatus
	) t
else					-- per month
	select ROW_NUMBER() OVER (ORDER BY DateCall, CallStatus) AS Id, DateCall, Calls, CallStatus
	from
	(
	select CAST(
			  CAST(year(DateCall) AS VARCHAR(4)) +
			  RIGHT('0' + CAST(MONTH(DateCall) AS VARCHAR(2)), 2) +
			  RIGHT('0' + CAST(1 AS VARCHAR(2)), 2) 
		   AS DATETIME) as DateCall, 
	count(*) AS Calls, CallStatus
	from @Tbl
	GROUP BY year(DateCall) , MONTH(DateCall), CallStatus
	) t
END
GO
/****** Object:  StoredProcedure [dbo].[sLvm_RepCdrRecCount]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- sLvm_RepCdrRecCount 1, 1, '2017-01-01', '2018-03-22', 0, 0, '', '',  '103,104', -1
-- sLvm_RepCdrRecCount 1, 0, '2017-01-01', '2018-03-22', 0, 0, '', '',  '', -1
-- sLvm_RepCdrRecCount 2, 0, '2017-01-01', '2018-03-22', 0, 0, '', '',  '', -1
ALTER PROCEDURE [dbo].[sLvm_RepCdrRecCount]
@FacilityId int,
@DepartmentId int,
@DateFrom datetime,
@DateTo datetime,
@RingDurationMin int,
@CallDurationMin int,

@From varchar(100),
@To varchar(100),

@RoomList varchar(4000),
@BedList varchar(8000),
@Direction int, -- =-1
@RecCount int OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

if (@DateTo = (CONVERT(date, @DateTo))) set @DateTo=DATEADD(d, 1, @DateTo)

set @RecCount=0;

declare @CdrTypeId int;
SELECT @CdrTypeId = CdrTypeId FROM  Lvm_Facility WHERE (FacilityId = @FacilityId)
--select @CdrTypeId
if (@CdrTypeId=1) -- PortSip
	SELECT @RecCount = COUNT(*)
	FROM (
	SELECT c.CdrPortSipId, c.CallStartTime, c.CallEndedTime, dp.DepartmentName, c.RoomNumber, c.CallDirection, c.Caller, c.Callee, c.CallStatus, c.CallRingDuration, c.CallTalkTime
	FROM  Lvm_Device AS dv RIGHT OUTER JOIN
	Lvm_CdrPortSip AS c LEFT OUTER JOIN
	Lvm_Department AS dp ON c.DepartmentId = dp.DepartmentId ON dv.DeviceId = c.DeviceId LEFT OUTER JOIN
	Lvm_Room AS r ON dv.RoomId = r.RoomId LEFT OUTER JOIN
	Lvm_BedLvm_Device as ldb ON dv.DeviceId = ldb.Lvm_Device_DeviceId LEFT OUTER JOIN
	Lvm_Bed as bd ON ldb.Lvm_Bed_BedId = bd.BedId
	WHERE (c.FacilityId = @FacilityId) 
	and ((@Direction = -1) or ((@Direction = 0) and (c.CallDirection = 'Outbound')) or ((@Direction = 1) and (c.CallDirection = 'Inbound')))
	AND ((@DepartmentId = 0) or (c.DepartmentId = @DepartmentId)) 
	--AND (c.CallStartTime BETWEEN @DateFrom AND @DateTo) 
	AND ((@RingDurationMin = 0) or (c.CallRingDuration >= @RingDurationMin))
	AND ((@CallDurationMin = 0) or (c.CallTalkTime >= @CallDurationMin))
	AND ((@From = '') or (c.[Caller] = @From))
	AND ((@To = '') or (c.Callee = @To))
	AND (bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) OR c.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i))
	--and ((@RoomList='') or c.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i)) 
	--and ((@BedList='') or bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) or bd.Number is NULL or bd.Number = '') 
	GROUP BY c.CdrPortSipId, c.CallStartTime, c.CallEndedTime, dp.DepartmentName, c.RoomNumber, c.CallDirection, c.Caller, c.Callee, c.CallStatus, c.CallRingDuration, c.CallTalkTime
	) as t
else if (@CdrTypeId=2) -- Vodia
	SELECT @RecCount = COUNT(*)
	from (
	select c.CdrVodiaId, c.TimeStart, c.TimeEnd, dp.DepartmentName, c.RoomNumber, c.RingDuration, c.Duration, c.Direction, c.[From], c.[To]
	FROM  Lvm_CdrVodia AS c LEFT OUTER JOIN
	Lvm_Department AS dp ON c.DepartmentId = dp.DepartmentId LEFT OUTER JOIN
	Lvm_Device AS dv ON c.DeviceId = dv.DeviceId LEFT OUTER JOIN
	Lvm_Room AS r ON dv.RoomId = r.RoomId LEFT OUTER JOIN
	Lvm_BedLvm_Device as ldb ON dv.DeviceId = ldb.Lvm_Device_DeviceId LEFT OUTER JOIN
	Lvm_Bed as bd ON ldb.Lvm_Bed_BedId = bd.BedId
	WHERE (c.FacilityId = @FacilityId) 
	and ((@Direction = -1) or (c.Direction = @Direction))
	AND ((@DepartmentId = 0) or (c.DepartmentId = @DepartmentId)) 
	AND (c.TimeStart BETWEEN @DateFrom AND @DateTo) 
	AND ((@RingDurationMin = 0) or (c.RingDuration >= @RingDurationMin))
	AND ((@CallDurationMin = 0) or (c.Duration >= @CallDurationMin))
	AND ((@From = '') or (c.[From] = @From))
	AND ((@To = '') or (c.[To] = @To))
	AND (bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) OR c.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i))
	--and ((@RoomList='') or c.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i)) 
	--and ((@BedList='') or bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) or bd.Number is NULL or bd.Number = '') 
	GROUP BY c.CdrVodiaId, c.TimeStart, c.TimeEnd, dp.DepartmentName, c.RoomNumber, c.RingDuration, c.Duration, c.Direction, c.[From], c.[To]
	) as t
select @RecCount RecCount

END
GO
/****** Object:  StoredProcedure [dbo].[sLvm_RepChartCtlNameColor]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- sLvm_RepChartCtlNameColor 0
ALTER PROCEDURE [dbo].[sLvm_RepChartCtlNameColor] 
@FacilityId int -- Future Use
AS
BEGIN
	SET NOCOUNT ON;

SELECT DISTINCT ControlCode, ControlName, replace('#' + ChartColor, '##', '#') ChartColor
FROM  Lvm_DeviceTypeControl AS c

END
GO
/****** Object:  StoredProcedure [dbo].[sLvm_RepDashboardChartNumOfCalls]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- sLvm_RepDashboardChartNumOfCalls 1, '2017-03-01', '2017-03-22' , '', 0
ALTER PROCEDURE [dbo].[sLvm_RepDashboardChartNumOfCalls]
@FacilityId int,
@DateFrom datetime,
@DateTo datetime,
@UserId nvarchar(128),
@IsSuperAdmin bit
AS
BEGIN
	SET NOCOUNT ON;

if (@DateTo = (CONVERT(date, @DateTo))) set @DateTo=DATEADD(d, 1, @DateTo)

declare @DayDiff int; set @DayDiff = DATEDIFF(d, @DateFrom, @DateTo)

if (@DayDiff<3) -- per hour
	SELECT dateadd(hour, datediff(hour, 0, DateControlOn), 0) as DateOn, Count(*) Calls
	FROM Lvm_MonitorRecordLog
	WHERE (IsClosed = 1) and 
	(
	(@IsSuperAdmin=1)
	or ((FacilityId = 0) and (FacilityId in (SELECT f.FacilityId FROM  Lvm_FacilityUser AS u INNER JOIN Lvm_Facility AS f ON u.FacilityId = f.FacilityId WHERE (u.UserId = @UserId))))
	or (FacilityId = @FacilityId)
	)
	AND (DateControlOn between @DateFrom and @DateTo)
	GROUP BY dateadd(hour, datediff(hour, 0, DateControlOn), 0)
	ORDER BY dateadd(hour, datediff(hour, 0, DateControlOn), 0);
else if (@DayDiff<32) --per day
	SELECT CONVERT(date, DateControlOn) DateOn, count(*) Calls
	FROM  Lvm_MonitorRecordLog
	WHERE (IsClosed = 1) and 
	(
	(@IsSuperAdmin=1)
	or ((FacilityId = 0) and (FacilityId in (SELECT f.FacilityId FROM  Lvm_FacilityUser AS u INNER JOIN Lvm_Facility AS f ON u.FacilityId = f.FacilityId WHERE (u.UserId = @UserId))))
	or (FacilityId = @FacilityId)
	)
	AND (DateControlOn between @DateFrom and @DateTo)
	group by  CONVERT(date, DateControlOn)
else if (@DayDiff<92) -- per week
	SELECT CONVERT(date,DATEADD(dd, 7-(DATEPART(dw, DateControlOn)), DateControlOn)) DateOn, count(*) Calls
	FROM  Lvm_MonitorRecordLog
	WHERE (IsClosed = 1) and 
	(
	(@IsSuperAdmin=1)
	or ((FacilityId = 0) and (FacilityId in (SELECT f.FacilityId FROM  Lvm_FacilityUser AS u INNER JOIN Lvm_Facility AS f ON u.FacilityId = f.FacilityId WHERE (u.UserId = @UserId))))
	or (FacilityId = @FacilityId)
	)
	AND (DateControlOn between @DateFrom and @DateTo)
	group by CONVERT(date,DATEADD(dd, 7-(DATEPART(dw, DateControlOn)), DateControlOn)) 
	order by CONVERT(date,DATEADD(dd, 7-(DATEPART(dw, DateControlOn)), DateControlOn)) 
else

SELECT 
--MONTH(DateControlOn) MONTH, year(DateControlOn) year, 
	CAST(
		  CAST(year(DateControlOn) AS VARCHAR(4)) +
		  RIGHT('0' + CAST(MONTH(DateControlOn) AS VARCHAR(2)), 2) +
		  RIGHT('0' + CAST(1 AS VARCHAR(2)), 2) 
	   AS DATETIME) DateOn,
		 COUNT(*) Calls
	FROM Lvm_MonitorRecordLog
	WHERE (IsClosed = 1) and 
	(
	(@IsSuperAdmin=1)
	or ((FacilityId = 0) and (FacilityId in (SELECT f.FacilityId FROM  Lvm_FacilityUser AS u INNER JOIN Lvm_Facility AS f ON u.FacilityId = f.FacilityId WHERE (u.UserId = @UserId))))
	or (FacilityId = @FacilityId)
	)
	AND (DateControlOn between @DateFrom and @DateTo)
	GROUP BY MONTH(DateControlOn), year(DateControlOn) 


END
GO
/****** Object:  StoredProcedure [dbo].[sLvm_RepDashboardChartNumOfCallsByType]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- sLvm_RepDashboardChartNumOfCallsByType 1, '2017-03-01', '2017-03-28' , '', 0
-- sLvm_RepDashboardChartNumOfCallsByType_0 1, '2017-03-01', '2017-03-01' , '', 0
-- sLvm_RepDashboardChartNumOfCallsByType 1, '2017-05-09', '2017-05-10' , '', 0
ALTER PROCEDURE [dbo].[sLvm_RepDashboardChartNumOfCallsByType]
@FacilityId int,
@DateFrom datetime,
@DateTo datetime,
@UserId nvarchar(128),
@IsSuperAdmin bit
AS
BEGIN
	SET NOCOUNT ON;

if (@DateTo = (CONVERT(date, @DateTo))) set @DateTo=DATEADD(d, 1, @DateTo)

declare @DayDiff int; set @DayDiff = DATEDIFF(d, @DateFrom, @DateTo)

if (@DayDiff<3) -- per hour
	SELECT dateadd(hour, datediff(hour, 0, DateControlOn), 0) as DateOn, 
	count(*) Calls,	c.ControlCode
	FROM  Lvm_MonitorRecordLog AS l LEFT OUTER JOIN
	Lvm_Beacon as b on l.BeaconId = b.BeaconId LEFT OUTER JOIN
	Lvm_Device AS d on l.DeviceId = d.DeviceId INNER JOIN
	Lvm_DeviceTypeControl AS c ON (d.DeviceTypeId = c.DeviceTypeId or b.DeviceTypeId = c.DeviceTypeId or (select [dbo].fLvmCtrlSystem()) = c.DeviceTypeId) AND l.ControlId = c.ControlNumber
	WHERE (IsClosed = 1) and 
	(
	(@IsSuperAdmin=1)
	or ((l.FacilityId = 0) and (l.FacilityId in (SELECT f.FacilityId FROM  Lvm_FacilityUser AS u INNER JOIN Lvm_Facility AS f ON u.FacilityId = f.FacilityId WHERE (u.UserId = @UserId))))
	or (l.FacilityId = @FacilityId)
	)
	AND (DateControlOn between @DateFrom and @DateTo)
	GROUP BY c.ControlCode, dateadd(hour, datediff(hour, 0, DateControlOn), 0)
	ORDER BY dateadd(hour, datediff(hour, 0, DateControlOn), 0);
else if (@DayDiff<32) --per day
	SELECT CONVERT(date, DateControlOn) DateOn, 
	count(*) Calls,	c.ControlCode
	FROM  Lvm_MonitorRecordLog AS l LEFT OUTER JOIN
	Lvm_Beacon as b on l.BeaconId = b.BeaconId LEFT OUTER JOIN
	Lvm_Device AS d on l.DeviceId = d.DeviceId INNER JOIN
	Lvm_DeviceTypeControl AS c ON (d.DeviceTypeId = c.DeviceTypeId or b.DeviceTypeId = c.DeviceTypeId or (select [dbo].fLvmCtrlSystem()) = c.DeviceTypeId) AND l.ControlId = c.ControlNumber
	WHERE (IsClosed = 1) and 
	(
	(@IsSuperAdmin=1)
	or ((l.FacilityId = 0) and (l.FacilityId in (SELECT f.FacilityId FROM  Lvm_FacilityUser AS u INNER JOIN Lvm_Facility AS f ON u.FacilityId = f.FacilityId WHERE (u.UserId = @UserId))))
	or (l.FacilityId = @FacilityId)
	)
	AND (DateControlOn between @DateFrom and @DateTo)
	group by c.ControlCode, CONVERT(date, DateControlOn)
	order by  CONVERT(date, DateControlOn)
else if (@DayDiff<92) -- per week
	SELECT CONVERT(date,DATEADD(dd, 7-(DATEPART(dw, DateControlOn)), DateControlOn)) DateOn, 
	count(*) Calls,	c.ControlCode
	FROM  Lvm_MonitorRecordLog AS l LEFT OUTER JOIN
	Lvm_Beacon as b on l.BeaconId = b.BeaconId LEFT OUTER JOIN
	Lvm_Device AS d on l.DeviceId = d.DeviceId INNER JOIN
	Lvm_DeviceTypeControl AS c ON (d.DeviceTypeId = c.DeviceTypeId or b.DeviceTypeId = c.DeviceTypeId or (select [dbo].fLvmCtrlSystem()) = c.DeviceTypeId) AND l.ControlId = c.ControlNumber
	WHERE (IsClosed = 1) and 
	(
	(@IsSuperAdmin=1)
	or ((l.FacilityId = 0) and (l.FacilityId in (SELECT f.FacilityId FROM  Lvm_FacilityUser AS u INNER JOIN Lvm_Facility AS f ON u.FacilityId = f.FacilityId WHERE (u.UserId = @UserId))))
	or (l.FacilityId = @FacilityId)
	)
	AND (DateControlOn between @DateFrom and @DateTo)
	group by c.ControlCode, CONVERT(date,DATEADD(dd, 7-(DATEPART(dw, DateControlOn)), DateControlOn)) 
	order by CONVERT(date,DATEADD(dd, 7-(DATEPART(dw, DateControlOn)), DateControlOn)) 
else
	SELECT 
	--MONTH(DateControlOn) MONTH, year(DateControlOn) year, 
		CAST(
			  CAST(year(DateControlOn) AS VARCHAR(4)) +
			  RIGHT('0' + CAST(MONTH(DateControlOn) AS VARCHAR(2)), 2) +
			  RIGHT('0' + CAST(1 AS VARCHAR(2)), 2) 
		   AS DATETIME) DateOn,
		count(*) Calls,	c.ControlCode
		FROM  Lvm_MonitorRecordLog AS l LEFT OUTER JOIN
		Lvm_Beacon as b on l.BeaconId = b.BeaconId LEFT OUTER JOIN
		Lvm_Device AS d on l.DeviceId = d.DeviceId INNER JOIN
		Lvm_DeviceTypeControl AS c ON (d.DeviceTypeId = c.DeviceTypeId or b.DeviceTypeId = c.DeviceTypeId or (select [dbo].fLvmCtrlSystem()) = c.DeviceTypeId) AND l.ControlId = c.ControlNumber
		WHERE (IsClosed = 1) and 
		(
		(@IsSuperAdmin=1)
		or ((l.FacilityId = 0) and (l.FacilityId in (SELECT f.FacilityId FROM  Lvm_FacilityUser AS u INNER JOIN Lvm_Facility AS f ON u.FacilityId = f.FacilityId WHERE (u.UserId = @UserId))))
		or (l.FacilityId = @FacilityId)
		)
		AND (DateControlOn between @DateFrom and @DateTo)
		GROUP BY c.ControlCode, year(DateControlOn) , MONTH(DateControlOn)
		ORDER BY year(DateControlOn) , MONTH(DateControlOn)
END
GO
/****** Object:  StoredProcedure [dbo].[sLvm_RepDashboardChartNumOfCallsByType_0]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- sLvm_RepDashboardChartNumOfCallsByType_0 1, '2017-03-01', '2017-03-28' , '', 0
-- sLvm_RepDashboardChartNumOfCallsByType_0 1, '2017-03-01', '2017-03-01' , '', 0
ALTER PROCEDURE [dbo].[sLvm_RepDashboardChartNumOfCallsByType_0]
@FacilityId int,
@DateFrom datetime,
@DateTo datetime,
@UserId nvarchar(128),
@IsSuperAdmin bit
AS
BEGIN
	SET NOCOUNT ON;

if (@DateTo = (CONVERT(date, @DateTo))) set @DateTo=DATEADD(d, 1, @DateTo)

declare @DayDiff int; set @DayDiff = DATEDIFF(d, @DateFrom, @DateTo)

if (@DayDiff<3) -- per hour
	SELECT dateadd(hour, datediff(hour, 0, DateControlOn), 0) as DateOn, 
	 sum(case when ControlId = 1 then 1 else 0 end) Calls1,
	 sum(case when ControlId = 2 then 1 else 0 end) Calls2,
	 sum(case when ControlId = 3 then 1 else 0 end) Calls3,
	 sum(case when ControlId = 4 then 1 else 0 end) Calls4
	FROM Lvm_MonitorRecordLog
	WHERE (IsClosed = 1) and 
	(
	(@IsSuperAdmin=1)
	or ((FacilityId = 0) and (FacilityId in (SELECT f.FacilityId FROM  Lvm_FacilityUser AS u INNER JOIN Lvm_Facility AS f ON u.FacilityId = f.FacilityId WHERE (u.UserId = @UserId))))
	or (FacilityId = @FacilityId)
	)
	AND (DateControlOn between @DateFrom and @DateTo)
	GROUP BY dateadd(hour, datediff(hour, 0, DateControlOn), 0)
	ORDER BY dateadd(hour, datediff(hour, 0, DateControlOn), 0);
else if (@DayDiff<32) --per day
	SELECT CONVERT(date, DateControlOn) DateOn, 
	 sum(case when ControlId = 1 then 1 else 0 end) Calls1,
	 sum(case when ControlId = 2 then 1 else 0 end) Calls2,
	 sum(case when ControlId = 3 then 1 else 0 end) Calls3,
	 sum(case when ControlId = 4 then 1 else 0 end) Calls4
	FROM  Lvm_MonitorRecordLog
	WHERE (IsClosed = 1) and 
	(
	(@IsSuperAdmin=1)
	or ((FacilityId = 0) and (FacilityId in (SELECT f.FacilityId FROM  Lvm_FacilityUser AS u INNER JOIN Lvm_Facility AS f ON u.FacilityId = f.FacilityId WHERE (u.UserId = @UserId))))
	or (FacilityId = @FacilityId)
	)
	AND (DateControlOn between @DateFrom and @DateTo)
	group by  CONVERT(date, DateControlOn)
else if (@DayDiff<92) -- per week
	SELECT CONVERT(date,DATEADD(dd, 7-(DATEPART(dw, DateControlOn)), DateControlOn)) DateOn, 
	 sum(case when ControlId = 1 then 1 else 0 end) Calls1,
	 sum(case when ControlId = 2 then 1 else 0 end) Calls2,
	 sum(case when ControlId = 3 then 1 else 0 end) Calls3,
	 sum(case when ControlId = 4 then 1 else 0 end) Calls4
	FROM  Lvm_MonitorRecordLog
	WHERE (IsClosed = 1) and 
	(
	(@IsSuperAdmin=1)
	or ((FacilityId = 0) and (FacilityId in (SELECT f.FacilityId FROM  Lvm_FacilityUser AS u INNER JOIN Lvm_Facility AS f ON u.FacilityId = f.FacilityId WHERE (u.UserId = @UserId))))
	or (FacilityId = @FacilityId)
	)
	AND (DateControlOn between @DateFrom and @DateTo)
	group by CONVERT(date,DATEADD(dd, 7-(DATEPART(dw, DateControlOn)), DateControlOn)) 
	order by CONVERT(date,DATEADD(dd, 7-(DATEPART(dw, DateControlOn)), DateControlOn)) 
else

SELECT 
--MONTH(DateControlOn) MONTH, year(DateControlOn) year, 
	CAST(
		  CAST(year(DateControlOn) AS VARCHAR(4)) +
		  RIGHT('0' + CAST(MONTH(DateControlOn) AS VARCHAR(2)), 2) +
		  RIGHT('0' + CAST(1 AS VARCHAR(2)), 2) 
	   AS DATETIME) DateOn,
	 sum(case when ControlId = 1 then 1 else 0 end) Calls1,
	 sum(case when ControlId = 2 then 1 else 0 end) Calls2,
	 sum(case when ControlId = 3 then 1 else 0 end) Calls3,
	 sum(case when ControlId = 4 then 1 else 0 end) Calls4
	FROM Lvm_MonitorRecordLog
	WHERE (IsClosed = 1) and 
	(
	(@IsSuperAdmin=1)
	or ((FacilityId = 0) and (FacilityId in (SELECT f.FacilityId FROM  Lvm_FacilityUser AS u INNER JOIN Lvm_Facility AS f ON u.FacilityId = f.FacilityId WHERE (u.UserId = @UserId))))
	or (FacilityId = @FacilityId)
	)
	AND (DateControlOn between @DateFrom and @DateTo)
	GROUP BY MONTH(DateControlOn), year(DateControlOn) 


END
GO
/****** Object:  StoredProcedure [dbo].[sLvm_RepDashboardTop]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- sLvm_RepDashboardTop 1, '2017-01-01', '2018-03-22' , '', 0
ALTER PROCEDURE [dbo].[sLvm_RepDashboardTop]
@FacilityId int,
@FloorId int,
@DepartmentId int,
@DateFrom datetime,
@DateTo datetime,
@UserId nvarchar(128),
@IsSuperAdmin bit
AS
BEGIN
	SET NOCOUNT ON;

declare @NumOfCalls int, @AvgRespTime varchar(100), @TotalPat int, @TotalDev int, @TotalAlarms int

SELECT @NumOfCalls = count(*)--, @AvgRespTime = avg(datediff(minute, DateControlOn, DateControlOff)) 
FROM  Lvm_MonitorRecordLog
WHERE (IsClosed = 1) and 
(
--(@IsSuperAdmin=1)
--or
 (((FacilityId = 0) and (FacilityId in (SELECT f.FacilityId FROM  Lvm_FacilityUser AS u INNER JOIN Lvm_Facility AS f ON u.FacilityId = f.FacilityId WHERE (u.UserId = @UserId))))
or (FacilityId = @FacilityId))
and (@FloorId is null or @FloorId = 0 or @FloorId = FloorId)
and (@DepartmentId is null or @DepartmentId = 0 or @DepartmentId = DepartmentId)
)
AND (DateControlOn between @DateFrom and @DateTo)


SELECT @AvgRespTime = (select [dbo].fConvertTimeToHHMMSS(avg(DATEDIFF(s, DateControlOn, DateControlOff)), 's'))
--avg(datediff(s, DateControlOn, DateControlOff)) 
FROM  Lvm_MonitorRecordLog
WHERE (IsClosed = 1) and 
(
--(@IsSuperAdmin=1)
--or
(((FacilityId = 0) and (FacilityId in (SELECT f.FacilityId FROM  Lvm_FacilityUser AS u INNER JOIN Lvm_Facility AS f ON u.FacilityId = f.FacilityId WHERE (u.UserId = @UserId))))
or (FacilityId = @FacilityId))
and (@FloorId is null or @FloorId = 0 or @FloorId = FloorId)
and (@DepartmentId is null or @DepartmentId = 0 or @DepartmentId = DepartmentId)
)
AND (DateControlOn between @DateFrom and @DateTo)

SELECT @TotalDev = COUNT(*)
FROM  Lvm_Device as d
WHERE 
--(@IsSuperAdmin=1)
--or 
(((FacilityId = 0) and (FacilityId in (SELECT f.FacilityId FROM  Lvm_FacilityUser AS u INNER JOIN Lvm_Facility AS f ON u.FacilityId = f.FacilityId WHERE (u.UserId = @UserId))))
or (FacilityId = @FacilityId))
and (@FloorId is null or @FloorId = 0 or @FloorId = FloorId)
and (@DepartmentId is null or @DepartmentId = 0 or @DepartmentId = (select DepartmentId from [dbo].[Lvm_Room] where RoomId = d.RoomId))

SELECT @TotalAlarms = COUNT(*)
FROM  Lvm_MonitorRecordLog
WHERE 
--((@IsSuperAdmin=1)
--or 
(((FacilityId = 0) and (FacilityId in (SELECT f.FacilityId FROM  Lvm_FacilityUser AS u INNER JOIN Lvm_Facility AS f ON u.FacilityId = f.FacilityId WHERE (u.UserId = @UserId))))
or (FacilityId = @FacilityId))
and (@FloorId is null or @FloorId = 0 or @FloorId = FloorId)
and (@DepartmentId is null or @DepartmentId = 0 or @DepartmentId = DepartmentId)
and IsControlOn=1

SELECT @TotalPat = COUNT(*)
FROM  Lvm_Patient as p
WHERE 
--((@IsSuperAdmin=1)
--or
(((FacilityId = 0) and (FacilityId in (SELECT f.FacilityId FROM  Lvm_FacilityUser AS u INNER JOIN Lvm_Facility AS f ON u.FacilityId = f.FacilityId WHERE (u.UserId = @UserId))))
or (FacilityId = @FacilityId))
and (@FloorId is null or @FloorId = 0 or @FloorId = FloorId)
and (@DepartmentId is null or @DepartmentId = 0 or @DepartmentId = (select DepartmentId from Lvm_Room where RoomId = p.RoomId))
and PatientStatusId=1

select @NumOfCalls NumOfCalls, @AvgRespTime AvgRespTime, 5 NursOnDuty, @TotalDev TotalDev, @TotalPat TotalPat, @TotalAlarms TotalAlarms

END
GO
/****** Object:  StoredProcedure [dbo].[sLvm_RepDevResponse]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- sLvm_RepDevResponse 1, 1, '2017-01-01', '2018-03-22', 0, 0, 0, '103,104', '', 1, 100
-- sLvm_RepDevResponse 1, 1, '2017-06-01', '2018-06-01', 0, 0, 0, '', 'RoomNumber',1,10
ALTER PROCEDURE [dbo].[sLvm_RepDevResponse]
@FacilityId int,
@DepartmentId int,
@FloorId int,
@DateFrom datetime,
@DateTo datetime,
@ResponseTimeMin int,
@ShowTop int,

@RoomList varchar(4000),
@BedList varchar(8000),

@Sort varchar(50)='',
@PageNumber int = 0, -- strart with 1
@PageSize int = 0,
@HardwareTypeId int = null
AS
BEGIN
	SET NOCOUNT ON;
if (@Sort='') set @Sort='ResponseTime DESC'

if (@DateTo = (CONVERT(date, @DateTo))) set @DateTo=DATEADD(d, 1, @DateTo)

select *
from
(
select ROW_NUMBER() OVER (ORDER BY 
	CASE WHEN @Sort = 'DepartmentName desc' THEN DepartmentName END desc, 
	CASE WHEN @Sort = 'DepartmentName' THEN DepartmentName END, 
	CASE WHEN @Sort = 'FloorNumber desc' THEN FloorNumber END desc, 
	CASE WHEN @Sort = 'FloorNumber' THEN FloorNumber END, 
	CASE WHEN @Sort = 'RoomNumber desc' THEN RoomNumber END desc, 
	CASE WHEN @Sort = 'RoomNumber' THEN RoomNumber END, 
	CASE WHEN @Sort = 'BedNumber desc' THEN BedNumber END desc, 
	CASE WHEN @Sort = 'BedNumber' THEN BedNumber END, 
	CASE WHEN @Sort = 'DeviceName desc' THEN DeviceName END desc, 
	CASE WHEN @Sort = 'DeviceName' THEN DeviceName END, 
	CASE WHEN @Sort = 'BeaconName desc' THEN BeaconName END desc, 
	CASE WHEN @Sort = 'BeaconName' THEN BeaconName END, 
	CASE WHEN @Sort = 'EquipmentName desc' THEN EquipmentName END desc, 
	CASE WHEN @Sort = 'EquipmentName' THEN EquipmentName END, 
	CASE WHEN @Sort = 'PatientName desc' THEN PatientName END desc, 
	CASE WHEN @Sort = 'PatientName' THEN PatientName END, 
	CASE WHEN @Sort = 'ResponseTime desc' THEN ResponseTime END desc, 
	CASE WHEN @Sort = 'ResponseTime' THEN ResponseTime END, 
	CASE WHEN @Sort = 'DateControlOn desc' THEN DateControlOn END desc, 
	CASE WHEN @Sort = 'DateControlOn' THEN DateControlOn END
)  AS Id, *
from
(
SELECT ISNULL(dp.DepartmentName, '') as DepartmentName, f.Number as FloorNumber, ISNULL(r.RoomNumber, '') as RoomNumber
, STRING_AGG(ISNULL((bd.Number + ISNULL(' (' + p.FullName + ')', '')), ''), ',') AS BedNumber
, ISNULL(d.DeviceName, '') as DeviceName, (select [dbo].fConvertTimeToHHMMSS(DATEDIFF(s, ml.DateControlOn, ml.DateControlOff), 's')) AS ResponseTime, ml.DateControlOn
, ISNULL(p1.FullName, '') as PatientName, ISNULL(bc.BeaconName, '') as BeaconName, ISNULL(e.EquipmentName, '') as EquipmentName
FROM  Lvm_MonitorRecordLog AS ml LEFT OUTER JOIN
	Lvm_Beacon as bc on ml.BeaconId = bc.BeaconId LEFT OUTER JOIN
	Lvm_Patient as p1 on bc.PatientId = p1.PatientId LEFT OUTER JOIN
	Lvm_Equipment as e on bc.EquipmentId = e.EquipmentId LEFT OUTER JOIN
	Lvm_Device AS d ON ml.DeviceId = d.DeviceId INNER JOIN
	Lvm_Floor as f ON ml.FloorId = f.FloorId LEFT OUTER JOIN
	Lvm_Room AS r ON ml.RoomId = r.RoomId LEFT OUTER JOIN
	Lvm_BedLvm_Device as ldb ON d.DeviceId = ldb.Lvm_Device_DeviceId LEFT OUTER JOIN
	Lvm_Bed as bd ON ldb.Lvm_Bed_BedId = bd.BedId LEFT OUTER JOIN
	Lvm_PatientRecordLog AS pr ON bd.BedId = pr.BedId and pr.DatePatientAdmitted >= ml.DateControlOn and pr.DatePatientAdmitted <= ml.DateControlOff LEFT OUTER JOIN
	Lvm_Patient AS p ON pr.PatientId = p.PatientId LEFT OUTER JOIN
	Lvm_Department AS dp ON ml.DepartmentId = dp.DepartmentId
WHERE (ml.IsControlOn = 0) AND (ml.FacilityId = @FacilityId) 
AND (@FloorId = 0 or @FloorId is null or f.FloorId = @FloorId)
and (@HardwareTypeId is null or (@HardwareTypeId = 1 and ml.DeviceId is not null) or (@HardwareTypeId = 2 and ml.BeaconId is not null))
AND (((@DepartmentId = 0 or @DepartmentId is null) OR (@DepartmentId is null AND dp.DepartmentId is null)) or (dp.DepartmentId = @DepartmentId)) 
AND (ml.DateControlOn BETWEEN @DateFrom AND @DateTo) 
AND ((@ResponseTimeMin = 0) or (DATEDIFF(mi, ml.DateControlOn, ml.DateControlOff) > @ResponseTimeMin))
AND (((@BedList = '' and (f.FloorId = @FloorId or @FloorId = 0)) and (@RoomList = '' and (f.FloorId = @FloorId or @FloorId = 0))) or
--AND (((@BedList = '' and (f.FloorId = @FloorId or @FloorId = 0) and bd.Number is null) and (@RoomList = '' and (f.FloorId = @FloorId or @FloorId = 0) and bd.Number is null)) or
	bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) OR 
	r.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i))
--AND ((@RoomList='') or r.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i))
--AND ((@BedList='') or bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i))
--and (p.PatientId is NULL or p.PatientStatusId = 1)

--ORDER BY ResponseTime DESC
GROUP BY dp.DepartmentName, f.Number, r.RoomNumber, d.DeviceName, ml.DateControlOn, ml.DateControlOff, 
	DATEDIFF(mi, ml.DateControlOn, ml.DateControlOff), p1.FullName, e.EquipmentName, bc.BeaconName
) as t
) as t2
where ((@ShowTop = 0) or (Id <= @ShowTop))  
and ((@PageNumber = 0) or Id BETWEEN (@PageNumber - 1) * @PageSize + 1 And (@PageNumber * @PageSize))

END
GO
/****** Object:  StoredProcedure [dbo].[sLvm_RepDevResponseChart]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- sLvm_RepDevResponseChart 1, 1, '2017-01-01', '2018-03-22', 0, 0, 0, '', '', true
ALTER PROCEDURE [dbo].[sLvm_RepDevResponseChart]
@FacilityId int,
@DepartmentId int,
@FloorId int,
@DateFrom datetime,
@DateTo datetime,
@ResponseTimeMin int,
@ShowTop int,
@RoomList varchar(4000),
@BedList varchar(8000),
@UserId nvarchar(128),
@IsSuperAdmin bit,
@HardwareTypeId int = null
AS
BEGIN
	SET NOCOUNT ON;

if (@DateTo = (CONVERT(date, @DateTo))) set @DateTo=DATEADD(d, 1, @DateTo)

declare @DayDiff int; set @DayDiff = DATEDIFF(d, @DateFrom, @DateTo)
if (@DayDiff<3)			-- per hour
	select *
	from
	(
	select ROW_NUMBER() OVER (ORDER BY DateOn, ControlCode)  AS Id, *
	from
	(
	SELECT dateadd(MINUTE, datediff(MINUTE, 0, DateControlOn), 0) as DateOn, 
	avg(DATEDIFF(s, l.DateControlOn, l.DateControlOff)) AS ResponseTime, c.ControlCode, c.ChartColor
	FROM  Lvm_MonitorRecordLog AS l LEFT OUTER JOIN
		Lvm_Beacon as bc on l.BeaconId = bc.BeaconId LEFT OUTER JOIN
		Lvm_Patient as p1 on bc.PatientId = p1.PatientId LEFT OUTER JOIN
		Lvm_Equipment as e on bc.EquipmentId = e.EquipmentId LEFT OUTER JOIN
		Lvm_Device AS d ON l.DeviceId = d.DeviceId INNER JOIN
		Lvm_DeviceTypeControl AS c ON (d.DeviceTypeId = c.DeviceTypeId or bc.DeviceTypeId = c.DeviceTypeId or (select [dbo].fLvmCtrlSystem()) = c.DeviceTypeId) AND l.ControlId = c.ControlNumber INNER JOIN
		Lvm_Floor as f on l.FloorId = f.FloorId LEFT OUTER JOIN
		Lvm_Room AS r ON l.RoomId = r.RoomId LEFT OUTER JOIN
		Lvm_Department as dp on r.DepartmentId = dp.DepartmentId LEFT OUTER JOIN
		Lvm_BedLvm_Device as ldb ON d.DeviceId = ldb.Lvm_Device_DeviceId LEFT OUTER JOIN
		Lvm_Bed as bd ON ldb.Lvm_Bed_BedId = bd.BedId
	WHERE (IsClosed = 1) AND
	(
	(@IsSuperAdmin=1)
	or ((l.FacilityId = 0) and (l.FacilityId in (SELECT f.FacilityId FROM  Lvm_FacilityUser AS u INNER JOIN Lvm_Facility AS f ON u.FacilityId = f.FacilityId WHERE (u.UserId = @UserId))))
	or (l.FacilityId = @FacilityId)
	)
	AND (@FloorId = 0 or @FloorId is null or f.FloorId = @FloorId)
	and (@HardwareTypeId is null or (@HardwareTypeId = 1 and l.DeviceId is not null) or (@HardwareTypeId = 2 and l.BeaconId is not null))
	AND (((@DepartmentId = 0 or @DepartmentId is null) OR (@DepartmentId is null AND dp.DepartmentId is null)) or (dp.DepartmentId = @DepartmentId)) 
	AND (l.DateControlOn BETWEEN @DateFrom AND @DateTo) 
	AND ((@ResponseTimeMin = 0) or (DATEDIFF(mi, l.DateControlOn, l.DateControlOff) > @ResponseTimeMin)) 
	AND (((@BedList = '' and (f.FloorId = @FloorId or @FloorId = 0)) and (@RoomList = '' and (f.FloorId = @FloorId or @FloorId = 0))) or
	--AND (((@BedList = '' and (f.FloorId = @FloorId or @FloorId = 0) and bd.Number is null) and (@RoomList = '' and (f.FloorId = @FloorId or @FloorId = 0) and bd.Number is null)) or
	bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) OR 
	r.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i))
	--and ((@RoomList='') or r.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i)) 
	--and ((@BedList='') or bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) or bd.Number is NULL or bd.Number = '') 
	GROUP BY c.ControlCode, dateadd(MINUTE, datediff(MINUTE, 0, DateControlOn), 0), c.ChartColor
	) as t
	) as t2
	where ((@ShowTop = 0) or (Id <= @ShowTop))  
else if (@DayDiff<32)	--per day
	select *
	from
	(
	select ROW_NUMBER() OVER (ORDER BY DateOn, ControlCode)  AS Id, *
	from
	(
	SELECT CONVERT(date, DateControlOn) DateOn, 
	avg(DATEDIFF(s, l.DateControlOn, l.DateControlOff)) AS ResponseTime, c.ControlCode, c.ChartColor
	FROM  Lvm_MonitorRecordLog AS l LEFT OUTER JOIN
		Lvm_Beacon as bc on l.BeaconId = bc.BeaconId LEFT OUTER JOIN
		Lvm_Patient as p1 on bc.PatientId = p1.PatientId LEFT OUTER JOIN
		Lvm_Equipment as e on bc.EquipmentId = e.EquipmentId LEFT OUTER JOIN
		Lvm_Device AS d ON l.DeviceId = d.DeviceId INNER JOIN
		Lvm_DeviceTypeControl AS c ON (d.DeviceTypeId = c.DeviceTypeId or bc.DeviceTypeId = c.DeviceTypeId or (select [dbo].fLvmCtrlSystem()) = c.DeviceTypeId) AND l.ControlId = c.ControlNumber INNER JOIN
		Lvm_Floor as f on l.FloorId = f.FloorId LEFT OUTER JOIN
		Lvm_Room AS r ON l.RoomId = r.RoomId LEFT OUTER JOIN
		Lvm_Department as dp on r.DepartmentId = dp.DepartmentId LEFT OUTER JOIN
		Lvm_BedLvm_Device as ldb ON d.DeviceId = ldb.Lvm_Device_DeviceId LEFT OUTER JOIN
		Lvm_Bed as bd ON ldb.Lvm_Bed_BedId = bd.BedId
	WHERE (IsClosed = 1) AND
	(
	(@IsSuperAdmin=1)
	or ((l.FacilityId = 0) and (l.FacilityId in (SELECT f.FacilityId FROM  Lvm_FacilityUser AS u INNER JOIN Lvm_Facility AS f ON u.FacilityId = f.FacilityId WHERE (u.UserId = @UserId))))
	or (l.FacilityId = @FacilityId)
	)
	AND (@FloorId = 0 or @FloorId is null or f.FloorId = @FloorId)
	and (@HardwareTypeId is null or (@HardwareTypeId = 1 and l.DeviceId is not null) or (@HardwareTypeId = 2 and l.BeaconId is not null))
	AND (((@DepartmentId = 0 or @DepartmentId is null) OR (@DepartmentId is null AND dp.DepartmentId is null)) or (dp.DepartmentId = @DepartmentId)) 
	AND (l.DateControlOn BETWEEN @DateFrom AND @DateTo) 
	AND ((@ResponseTimeMin = 0) or (DATEDIFF(mi, l.DateControlOn, l.DateControlOff) > @ResponseTimeMin)) 
	AND (((@BedList = '' and (f.FloorId = @FloorId or @FloorId = 0) and bd.Number is null) and (@RoomList = '' and (f.FloorId = @FloorId or @FloorId = 0) and bd.Number is null)) or
	bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) OR 
	r.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i))
	--and ((@RoomList='') or r.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i)) 
	--and ((@BedList='') or bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) or bd.Number is NULL or bd.Number = '') 
	GROUP BY c.ControlCode, CONVERT(date, DateControlOn), c.ChartColor
	) as t
	) as t2
	where ((@ShowTop = 0) or (Id <= @ShowTop))  
else if (@DayDiff<92)	-- per week
	select *
	from
	(
	select ROW_NUMBER() OVER (ORDER BY DateOn, ControlCode)  AS Id, *
	from
	(
	SELECT CONVERT(date,DATEADD(dd, 7-(DATEPART(dw, DateControlOn)), DateControlOn)) DateOn, 
	avg(DATEDIFF(s, l.DateControlOn, l.DateControlOff)) AS ResponseTime, c.ControlCode, c.ChartColor
	FROM  Lvm_MonitorRecordLog AS l LEFT OUTER JOIN
		Lvm_Beacon as bc on l.BeaconId = bc.BeaconId LEFT OUTER JOIN
		Lvm_Patient as p1 on bc.PatientId = p1.PatientId LEFT OUTER JOIN
		Lvm_Equipment as e on bc.EquipmentId = e.EquipmentId LEFT OUTER JOIN
		Lvm_Device AS d ON l.DeviceId = d.DeviceId INNER JOIN
		Lvm_DeviceTypeControl AS c ON (d.DeviceTypeId = c.DeviceTypeId or bc.DeviceTypeId = c.DeviceTypeId or (select [dbo].fLvmCtrlSystem()) = c.DeviceTypeId) AND l.ControlId = c.ControlNumber INNER JOIN
		Lvm_Room as f on l.FloorId = f.FloorId LEFT OUTER JOIN
		Lvm_Room AS r ON l.RoomId = r.RoomId LEFT OUTER JOIN
		Lvm_Department as dp on r.DepartmentId = dp.DepartmentId LEFT OUTER JOIN
		Lvm_BedLvm_Device as ldb ON d.DeviceId = ldb.Lvm_Device_DeviceId LEFT OUTER JOIN
		Lvm_Bed as bd ON ldb.Lvm_Bed_BedId = bd.BedId
	WHERE (IsClosed = 1) AND
	(
	(@IsSuperAdmin=1)
	or ((l.FacilityId = 0) and (l.FacilityId in (SELECT f.FacilityId FROM  Lvm_FacilityUser AS u INNER JOIN Lvm_Facility AS f ON u.FacilityId = f.FacilityId WHERE (u.UserId = @UserId))))
	or (l.FacilityId = @FacilityId)
	)
	AND (@FloorId = 0 or @FloorId is null or f.FloorId = @FloorId)
	and (@HardwareTypeId is null or (@HardwareTypeId = 1 and l.DeviceId is not null) or (@HardwareTypeId = 2 and l.BeaconId is not null))
	AND (((@DepartmentId = 0 or @DepartmentId is null) OR (@DepartmentId is null AND dp.DepartmentId is null)) or (dp.DepartmentId = @DepartmentId)) 
	AND (l.DateControlOn BETWEEN @DateFrom AND @DateTo) 
	AND ((@ResponseTimeMin = 0) or (DATEDIFF(mi, l.DateControlOn, l.DateControlOff) > @ResponseTimeMin)) 
	AND (((@BedList = '' and (f.FloorId = @FloorId or @FloorId = 0) and bd.Number is null) and (@RoomList = '' and (f.FloorId = @FloorId or @FloorId = 0) and bd.Number is null)) or
	bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) OR 
	r.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i))
	--and ((@RoomList='') or r.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i)) 
	--and ((@BedList='') or bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) or bd.Number is NULL or bd.Number = '') 
	GROUP BY c.ControlCode, CONVERT(date,DATEADD(dd, 7-(DATEPART(dw, DateControlOn)), DateControlOn)), c.ChartColor
	--ORDER BY ResponseTime DESC
	) as t
	) as t2
	where ((@ShowTop = 0) or (Id <= @ShowTop))  
else					-- per month
	select *
	from
	(
	select ROW_NUMBER() OVER (ORDER BY DateOn, ControlCode)  AS Id, *
	from
	(
	SELECT 
		CAST(
			  CAST(year(DateControlOn) AS VARCHAR(4)) +
			  RIGHT('0' + CAST(MONTH(DateControlOn) AS VARCHAR(2)), 2) +
			  RIGHT('0' + CAST(1 AS VARCHAR(2)), 2) 
		   AS DATETIME) DateOn,	avg(DATEDIFF(s, l.DateControlOn, l.DateControlOff)) AS ResponseTime, c.ControlCode, c.ChartColor
	FROM  Lvm_MonitorRecordLog AS l LEFT OUTER JOIN
		Lvm_Beacon as bc on l.BeaconId = bc.BeaconId LEFT OUTER JOIN
		Lvm_Patient as p1 on bc.PatientId = p1.PatientId LEFT OUTER JOIN
		Lvm_Equipment as e on bc.EquipmentId = e.EquipmentId LEFT OUTER JOIN
		Lvm_Device AS d ON l.DeviceId = d.DeviceId INNER JOIN
		Lvm_DeviceTypeControl AS c ON (d.DeviceTypeId = c.DeviceTypeId or bc.DeviceTypeId = c.DeviceTypeId or (select [dbo].fLvmCtrlSystem()) = c.DeviceTypeId) AND l.ControlId = c.ControlNumber INNER JOIN
		Lvm_Floor as f on l.FloorId = f.FloorId LEFT OUTER JOIN
		Lvm_Room AS r ON l.RoomId = r.RoomId LEFT OUTER JOIN
		Lvm_Department as dp on r.DepartmentId = dp.DepartmentId LEFT OUTER JOIN
		Lvm_BedLvm_Device as ldb ON d.DeviceId = ldb.Lvm_Device_DeviceId LEFT OUTER JOIN
		Lvm_Bed as bd ON ldb.Lvm_Bed_BedId = bd.BedId
	WHERE (IsClosed = 1) AND
	(
	(@IsSuperAdmin=1)
	or ((l.FacilityId = 0) and (l.FacilityId in (SELECT f.FacilityId FROM  Lvm_FacilityUser AS u INNER JOIN Lvm_Facility AS f ON u.FacilityId = f.FacilityId WHERE (u.UserId = @UserId))))
	or (l.FacilityId = @FacilityId)
	)
	AND (@FloorId = 0 or @FloorId is null or f.FloorId = @FloorId)
	and (@HardwareTypeId is null or (@HardwareTypeId = 1 and l.DeviceId is not null) or (@HardwareTypeId = 2 and l.BeaconId is not null))
	AND (((@DepartmentId = 0 or @DepartmentId is null) OR (@DepartmentId is null AND dp.DepartmentId is null)) or (dp.DepartmentId = @DepartmentId)) 
	AND (l.DateControlOn BETWEEN @DateFrom AND @DateTo) 
	AND ((@ResponseTimeMin = 0) or (DATEDIFF(mi, l.DateControlOn, l.DateControlOff) > @ResponseTimeMin))
	AND (((@BedList = '' and (f.FloorId = @FloorId or @FloorId = 0) and bd.Number is null) and (@RoomList = '' and (f.FloorId = @FloorId or @FloorId = 0) and bd.Number is null)) or
	bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) OR 
	r.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i))
	--and ((@RoomList='') or r.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i))
	--and ((@BedList='') or bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) or bd.Number is NULL or bd.Number = '')  
	GROUP BY c.ControlCode, year(DateControlOn) , MONTH(DateControlOn), c.ChartColor
	--ORDER BY ResponseTime DESC
	) as t
	) as t2
	where ((@ShowTop = 0) or (Id <= @ShowTop))  

END
GO
/****** Object:  StoredProcedure [dbo].[sLvm_RepDevResponseCount]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
sLvm_RepDevResponseCount 1, 1, '2017-01-01', '2018-03-22', 0, 0, 0, '103,104'
*/
ALTER PROCEDURE [dbo].[sLvm_RepDevResponseCount]
@FacilityId int,
@DepartmentId int,
@FloorId int,
@DateFrom datetime,
@DateTo datetime,
@ResponseTimeMin int,
@ShowTop int,
@RoomList varchar(4000),
@BedList varchar(8000),
@HardwareTypeId int = null,
@RecCount int OUTPUT
AS
BEGIN
SET NOCOUNT ON;

if (@DateTo = (CONVERT(date, @DateTo))) set @DateTo=DATEADD(d, 1, @DateTo)

set @RecCount=0;

SELECT @RecCount = COUNT(*) 
from (
SELECT ISNULL(dp.DepartmentName, '') as DepartmentName, ISNULL(r.RoomNumber, '') as RoomNumber, ISNULL(d.DeviceName, '') as DeviceName, ISNULL(p1.FullName, '') as PatientName
, ISNULL(bc.BeaconName, '') as BeaconName, ISNULL(e.EquipmentName, '') as EquipmentName, f.Number as FloorNumber, ml.DateControlOn, ml.DateControlOff
FROM  Lvm_MonitorRecordLog AS ml LEFT OUTER JOIN
	Lvm_Beacon as bc on ml.BeaconId = bc.BeaconId LEFT OUTER JOIN
	Lvm_Patient as p1 on bc.PatientId = p1.PatientId LEFT OUTER JOIN
	Lvm_Equipment as e on bc.EquipmentId = e.EquipmentId LEFT OUTER JOIN
	Lvm_Device AS d ON ml.DeviceId = d.DeviceId INNER JOIN
	Lvm_Floor AS f ON d.FloorId = f.FloorId LEFT OUTER JOIN
	Lvm_Room AS r ON d.RoomId = r.RoomId LEFT OUTER JOIN
	Lvm_Department as dp on r.DepartmentId = dp.DepartmentId LEFT OUTER JOIN
	Lvm_BedLvm_Device as ldb ON d.DeviceId = ldb.Lvm_Device_DeviceId LEFT OUTER JOIN
	Lvm_Bed as bd ON ldb.Lvm_Bed_BedId = bd.BedId
WHERE (ml.IsControlOn = 0) AND (ml.FacilityId = @FacilityId) 
AND (@FloorId = 0 or @FloorId is null or f.FloorId = @FloorId)
and (@HardwareTypeId is null or (@HardwareTypeId = 1 and ml.DeviceId is not null) or (@HardwareTypeId = 2 and ml.BeaconId is not null))
AND (((@DepartmentId = 0 or @DepartmentId is null) OR (@DepartmentId is null AND dp.DepartmentId is null)) or (dp.DepartmentId = @DepartmentId)) 
AND (ml.DateControlOn BETWEEN @DateFrom AND @DateTo) 
AND ((@ResponseTimeMin = 0) or (DATEDIFF(mi, ml.DateControlOn, ml.DateControlOff) > @ResponseTimeMin))
AND (((@BedList = '' and (f.FloorId = @FloorId or @FloorId = 0)) and (@RoomList = '' and (f.FloorId = @FloorId or @FloorId = 0))) or
--AND (((@BedList = '' and (f.FloorId = @FloorId or @FloorId = 0) and bd.Number is null) and (@RoomList = '' and (f.FloorId = @FloorId or @FloorId = 0) and bd.Number is null)) or
	bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) OR 
	r.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i))
--and ((@RoomList='') or r.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i)) 
--and ((@BedList='') or bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) or bd.Number is NULL or bd.Number = '') 
--GROUP BY dp.DepartmentName, r.FloorNumber, r.RoomNumber, d.DeviceName, ml.DateControlOn, ml.DateControlOff, DATEDIFF(mi, ml.DateControlOn, ml.DateControlOff)
GROUP BY dp.DepartmentName, f.Number, r.RoomNumber, d.DeviceName, bc.BeaconName, e.EquipmentName, p1.FullName
, ml.DateControlOn, ml.DateControlOff, DATEDIFF(mi, ml.DateControlOn, ml.DateControlOff)
) as t

if ((@ShowTop > 0) and (@RecCount > @ShowTop)) set @RecCount = @ShowTop

END
GO
/****** Object:  StoredProcedure [dbo].[sLvm_RepDevResponseSum]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- sLvm_RepDevResponseSum 1, 1, '2017-01-01', '2018-03-22', 0, 0, 0, '103,104', '', 1, 100
-- sLvm_RepDevResponseSum 1, 1, '2017-06-01', '2018-06-01', 0, 0, 0, '', 'Room',1,10
ALTER PROCEDURE [dbo].[sLvm_RepDevResponseSum]
@FacilityId int,
@DepartmentId int,
@FloorId int,
@DateFrom datetime,
@DateTo datetime,
@ResponseTimeMin int,
@ShowTop int,
@RoomList varchar(4000),
@BedList varchar(8000),

@Sort varchar(50)='',
@PageNumber int = 0, -- strart with 1
@PageSize int = 0,
@HardwareTypeId int = null
AS
BEGIN
	SET NOCOUNT ON;
	declare @PatientName varchar(20)=''
	if (@Sort='') set @Sort='RespTimeAvg DESC'
	if (@DateTo = (CONVERT(date, @DateTo))) set @DateTo=DATEADD(d, 1, @DateTo)

select *
from
(
select ROW_NUMBER() OVER (ORDER BY 
	CASE WHEN @Sort = 'Department desc' THEN Department END desc, 
	CASE WHEN @Sort = 'Department' THEN Department END, 
	CASE WHEN @Sort = 'Floor desc' THEN [Floor] END desc, 
	CASE WHEN @Sort = 'Floor' THEN [Floor] END, 
	CASE WHEN @Sort = 'Room desc' THEN Room END desc, 
	CASE WHEN @Sort = 'Room' THEN Room END, 
	CASE WHEN @Sort = 'Bed desc' THEN Bed END desc, 
	CASE WHEN @Sort = 'Bed' THEN Bed END, 
	CASE WHEN @Sort = 'Device desc' THEN Device END desc, 
	CASE WHEN @Sort = 'Device' THEN Device END, 
	CASE WHEN @Sort = 'Beacon desc' THEN Beacon END desc, 
	CASE WHEN @Sort = 'Beacon' THEN Beacon END, 
	CASE WHEN @Sort = 'Equipment desc' THEN Equipment END desc, 
	CASE WHEN @Sort = 'Equipment' THEN Equipment END, 
	CASE WHEN @Sort = 'Patient desc' THEN Patient END desc, 
	CASE WHEN @Sort = 'Patient' THEN Patient END, 
	CASE WHEN @Sort = 'CallCount desc' THEN CallCount END desc, 
	CASE WHEN @Sort = 'CallCount' THEN CallCount END, 
	CASE WHEN @Sort = 'RespTimeAvg desc' THEN RespTimeAvg END desc, 
	CASE WHEN @Sort = 'RespTimeAvg' THEN RespTimeAvg END
)  AS Id, *
from
(
SELECT ISNULL(dp.DepartmentName, '') as Department, f.Number [Floor], ISNULL(r.RoomNumber, '') as Room, STRING_AGG(ISNULL((bd.Number + ISNULL(' (' + p.FullName + ')', '')), ''), ',') AS Bed
, ISNULL(d.DeviceName, '') as Device, ISNULL(bc.BeaconName, '') as Beacon, ISNULL(e.EquipmentName, '') as Equipment, ISNULL(p1.FullName, '') as Patient, COUNT(*) AS CallCount
, AVG(DATEDIFF(s, ml.DateControlOn, ml.DateControlOff)) as RespTimeAvg
 --(select [dbo].fConvertTimeToHHMMSS(DATEDIFF(s, ml.DateControlOn, ml.DateControlOff), 's')) AS RespTimeAvg
FROM  Lvm_MonitorRecordLog AS ml LEFT OUTER JOIN
	Lvm_Beacon as bc on ml.BeaconId = bc.BeaconId LEFT OUTER JOIN
	Lvm_Patient as p1 on bc.PatientId = p1.PatientId LEFT OUTER JOIN
	Lvm_Equipment as e on bc.EquipmentId = e.EquipmentId LEFT OUTER JOIN
	Lvm_Device AS d ON ml.DeviceId = d.DeviceId INNER JOIN
	Lvm_Floor as f on ml.FloorId = f.FloorId LEFT OUTER JOIN
	Lvm_Room AS r ON ml.RoomId = r.RoomId LEFT OUTER JOIN
	Lvm_Department AS dp ON ml.DepartmentId = dp.DepartmentId LEFT OUTER JOIN
	Lvm_BedLvm_Device as ldb ON d.DeviceId = ldb.Lvm_Device_DeviceId LEFT OUTER JOIN
	Lvm_Bed as bd ON ldb.Lvm_Bed_BedId = bd.BedId LEFT OUTER JOIN
	Lvm_PatientRecordLog AS pr ON bd.BedId = pr.BedId and pr.DatePatientAdmitted >= ml.DateControlOn and pr.DatePatientAdmitted <= ml.DateControlOff LEFT OUTER JOIN
	Lvm_Patient AS p ON pr.PatientId = p.PatientId
WHERE (ml.IsControlOn = 0) AND (ml.FacilityId = @FacilityId) 
AND (@FloorId = 0 or @FloorId is null or f.FloorId = @FloorId)
and (@HardwareTypeId is null or (@HardwareTypeId = 1 and ml.DeviceId is not null) or (@HardwareTypeId = 2 and ml.BeaconId is not null))
AND (((@DepartmentId = 0 or @DepartmentId is null) OR (@DepartmentId is null AND dp.DepartmentId is null)) or (dp.DepartmentId = @DepartmentId)) 
AND (ml.DateControlOn BETWEEN @DateFrom AND @DateTo)
AND (((@BedList = '' and (f.FloorId = @FloorId or @FloorId = 0)) and (@RoomList = '' and (f.FloorId = @FloorId or @FloorId = 0))) or
--AND (((@BedList = '' and (f.FloorId = @FloorId or @FloorId = 0) and bd.Number is null) and (@RoomList = '' and (f.FloorId = @FloorId or @FloorId = 0) and bd.Number is null)) or
	bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) OR 
	r.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i))
--AND ((@RoomList='') or r.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i))
--AND ((@BedList='') or bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) or bd.Number is NULL or bd.Number = '')
GROUP BY dp.DepartmentName, f.Number, r.RoomNumber, d.DeviceName, bc.BeaconName, e.EquipmentName, p1.FullName
having ((@ResponseTimeMin = 0) or (AVG(DATEDIFF(mi, ml.DateControlOn, ml.DateControlOff)) > @ResponseTimeMin)) 
) as t
) as t2
where ((@ShowTop = 0) or (Id <= @ShowTop))  
and ((@PageNumber = 0) or Id BETWEEN (@PageNumber - 1) * @PageSize + 1 And (@PageNumber * @PageSize))

END
GO
/****** Object:  StoredProcedure [dbo].[sLvm_RepDevResponseSumChart]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- sLvm_RepDevResponseSumChart 1, 1, '2017-01-01', '2018-03-22', 0, 0, 0, '', '',true
-- sLvm_RepDevResponseSumChart 1, 1, '2017-06-01', '2017-06-03', 0, 0, 0, '', '', true
ALTER PROCEDURE [dbo].[sLvm_RepDevResponseSumChart]
@FacilityId int,
@DepartmentId int,
@FloorId int,
@DateFrom datetime,
@DateTo datetime,
@ResponseTimeMin int,
@ShowTop int,

@RoomList varchar(4000),
@BedList varchar(8000),

@UserId nvarchar(128),
@IsSuperAdmin bit,
@HardwareTypeId int = null
AS
BEGIN
	SET NOCOUNT ON;
	if (@DateTo = (CONVERT(date, @DateTo))) set @DateTo=DATEADD(d, 1, @DateTo)

declare @DayDiff int; set @DayDiff = DATEDIFF(d, @DateFrom, @DateTo)
if (@DayDiff<3)			-- per hour
	select *
	from
	(
	select ROW_NUMBER() OVER (ORDER BY DateOn /*, ControlCode*/)  AS Id, *
	from
	(
	SELECT dateadd(MINUTE, datediff(MINUTE, 0, DateControlOn), 0) as DateOn, 
	avg(DATEDIFF(s, l.DateControlOn, l.DateControlOff)) AS ResponseTime, COUNT(*) AS CallCount--, c.ControlCode
	FROM  Lvm_MonitorRecordLog AS l LEFT OUTER JOIN
	Lvm_Beacon as bc on l.BeaconId = bc.BeaconId LEFT OUTER JOIN
	Lvm_Patient as p1 on bc.PatientId = p1.PatientId LEFT OUTER JOIN
	Lvm_Equipment as e on bc.EquipmentId = e.EquipmentId LEFT OUTER JOIN
	Lvm_Device AS d ON l.DeviceId = d.DeviceId INNER JOIN
	Lvm_DeviceTypeControl AS c ON (d.DeviceTypeId = c.DeviceTypeId or bc.DeviceTypeId = c.DeviceTypeId or (select [dbo].fLvmCtrlSystem()) = c.DeviceTypeId) AND l.ControlId = c.ControlNumber INNER JOIN
	Lvm_Floor as f on l.FloorId = f.FloorId LEFT OUTER JOIN
	Lvm_Room AS r ON l.RoomId = r.RoomId LEFT OUTER JOIN
	Lvm_Department as dp on r.DepartmentId = dp.DepartmentId LEFT OUTER JOIN
	Lvm_BedLvm_Device as ldb ON d.DeviceId = ldb.Lvm_Device_DeviceId LEFT OUTER JOIN
	Lvm_Bed as bd ON ldb.Lvm_Bed_BedId = bd.BedId
	WHERE (IsClosed = 1) AND
	(
	(@IsSuperAdmin=1)
	or ((l.FacilityId = 0) and (l.FacilityId in (SELECT f.FacilityId FROM  Lvm_FacilityUser AS u INNER JOIN Lvm_Facility AS f ON u.FacilityId = f.FacilityId WHERE (u.UserId = @UserId))))
	or (l.FacilityId = @FacilityId)
	)
	AND (@FloorId = 0 or @FloorId is null or f.FloorId = @FloorId)
	and (@HardwareTypeId is null or (@HardwareTypeId = 1 and l.DeviceId is not null) or (@HardwareTypeId = 2 and l.BeaconId is not null))
	AND (((@DepartmentId = 0 or @DepartmentId is null) OR (@DepartmentId is null AND dp.DepartmentId is null)) or (dp.DepartmentId = @DepartmentId)) 
	AND (l.DateControlOn BETWEEN @DateFrom AND @DateTo) 
	AND ((@ResponseTimeMin = 0) or (DATEDIFF(mi, l.DateControlOn, l.DateControlOff) > @ResponseTimeMin)) 
	AND (((@BedList = '' and (f.FloorId = @FloorId or @FloorId = 0)) and (@RoomList = '' and (f.FloorId = @FloorId or @FloorId = 0))) or
	--AND (((@BedList = '' and (f.FloorId = @FloorId or @FloorId = 0) and bd.Number is null) and (@RoomList = '' and (f.FloorId = @FloorId or @FloorId = 0) and bd.Number is null)) or
	bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) OR 
	r.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i))
	--and ((@RoomList='') or r.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i)) 
	--and ((@BedList='') or bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) or bd.Number is NULL or bd.Number = '') 
	GROUP BY --c.ControlCode, 
	dateadd(MINUTE, datediff(MINUTE, 0, DateControlOn), 0)
	) as t
	) as t2
	where ((@ShowTop = 0) or (Id <= @ShowTop))  
else if (@DayDiff<32)	--per day
	select *
	from
	(
	select ROW_NUMBER() OVER (ORDER BY DateOn /*, ControlCode*/)  AS Id, *
	from
	(
	SELECT CONVERT(date, DateControlOn) DateOn, 
	avg(DATEDIFF(s, l.DateControlOn, l.DateControlOff)) AS ResponseTime, COUNT(*) AS CallCount--, c.ControlCode
	FROM  Lvm_MonitorRecordLog AS l LEFT OUTER JOIN
	Lvm_Beacon as bc on l.BeaconId = bc.BeaconId LEFT OUTER JOIN
	Lvm_Patient as p1 on bc.PatientId = p1.PatientId LEFT OUTER JOIN
	Lvm_Equipment as e on bc.EquipmentId = e.EquipmentId LEFT OUTER JOIN
	Lvm_Device AS d ON l.DeviceId = d.DeviceId INNER JOIN
	Lvm_DeviceTypeControl AS c ON (d.DeviceTypeId = c.DeviceTypeId or bc.DeviceTypeId = c.DeviceTypeId or (select [dbo].fLvmCtrlSystem()) = c.DeviceTypeId) AND l.ControlId = c.ControlNumber INNER JOIN
	Lvm_Floor as f on l.FloorId = f.FloorId LEFT OUTER JOIN
	Lvm_Room AS r ON l.RoomId = r.RoomId LEFT OUTER JOIN
	Lvm_Department as dp on r.DepartmentId = dp.DepartmentId LEFT OUTER JOIN
	Lvm_BedLvm_Device as ldb ON d.DeviceId = ldb.Lvm_Device_DeviceId LEFT OUTER JOIN
	Lvm_Bed as bd ON ldb.Lvm_Bed_BedId = bd.BedId
	WHERE (IsClosed = 1) AND
	(
	(@IsSuperAdmin=1)
	or ((l.FacilityId = 0) and (l.FacilityId in (SELECT f.FacilityId FROM  Lvm_FacilityUser AS u INNER JOIN Lvm_Facility AS f ON u.FacilityId = f.FacilityId WHERE (u.UserId = @UserId))))
	or (l.FacilityId = @FacilityId)
	)
	AND (@FloorId = 0 or @FloorId is null or f.FloorId = @FloorId)
	and (@HardwareTypeId is null or (@HardwareTypeId = 1 and l.DeviceId is not null) or (@HardwareTypeId = 2 and l.BeaconId is not null))
	AND (((@DepartmentId = 0 or @DepartmentId is null) OR (@DepartmentId is null AND dp.DepartmentId is null)) or (dp.DepartmentId = @DepartmentId)) 
	AND (l.DateControlOn BETWEEN @DateFrom AND @DateTo) 
	AND ((@ResponseTimeMin = 0) or (DATEDIFF(mi, l.DateControlOn, l.DateControlOff) > @ResponseTimeMin)) 
	AND (((@BedList = '' and (f.FloorId = @FloorId or @FloorId = 0)) and (@RoomList = '' and (f.FloorId = @FloorId or @FloorId = 0))) or
	--AND (((@BedList = '' and (f.FloorId = @FloorId or @FloorId = 0) and bd.Number is null) and (@RoomList = '' and (f.FloorId = @FloorId or @FloorId = 0) and bd.Number is null)) or
	bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) OR 
	r.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i))
	--and ((@RoomList='') or r.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i)) 
	--and ((@BedList='') or bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) or bd.Number is NULL or bd.Number = '') 
	GROUP BY --c.ControlCode, 
	CONVERT(date, DateControlOn)
	) as t
	) as t2
	where ((@ShowTop = 0) or (Id <= @ShowTop))  
else if (@DayDiff<92)	-- per week
	select *
	from
	(
	select ROW_NUMBER() OVER (ORDER BY DateOn /*, ControlCode*/)  AS Id, *
	from
	(
	SELECT CONVERT(date,DATEADD(dd, 7-(DATEPART(dw, DateControlOn)), DateControlOn)) DateOn, 
	avg(DATEDIFF(s, l.DateControlOn, l.DateControlOff)) AS ResponseTime, COUNT(*) AS CallCount--, c.ControlCode
	FROM  Lvm_MonitorRecordLog AS l LEFT OUTER JOIN
	Lvm_Beacon as bc on l.BeaconId = bc.BeaconId LEFT OUTER JOIN
	Lvm_Patient as p1 on bc.PatientId = p1.PatientId LEFT OUTER JOIN
	Lvm_Equipment as e on bc.EquipmentId = e.EquipmentId LEFT OUTER JOIN
	Lvm_Device AS d ON l.DeviceId = d.DeviceId INNER JOIN
	Lvm_DeviceTypeControl AS c ON (d.DeviceTypeId = c.DeviceTypeId or bc.DeviceTypeId = c.DeviceTypeId or (select [dbo].fLvmCtrlSystem()) = c.DeviceTypeId) AND l.ControlId = c.ControlNumber INNER JOIN
	Lvm_Floor as f on l.FloorId = f.FloorId LEFT OUTER JOIN
	Lvm_Room AS r ON l.RoomId = r.RoomId LEFT OUTER JOIN
	Lvm_Department as dp on r.DepartmentId = dp.DepartmentId LEFT OUTER JOIN
	Lvm_BedLvm_Device as ldb ON d.DeviceId = ldb.Lvm_Device_DeviceId LEFT OUTER JOIN
	Lvm_Bed as bd ON ldb.Lvm_Bed_BedId = bd.BedId
	WHERE (IsClosed = 1) AND
	(
	(@IsSuperAdmin=1)
	or ((l.FacilityId = 0) and (l.FacilityId in (SELECT f.FacilityId FROM  Lvm_FacilityUser AS u INNER JOIN Lvm_Facility AS f ON u.FacilityId = f.FacilityId WHERE (u.UserId = @UserId))))
	or (l.FacilityId = @FacilityId)
	)
	AND (@FloorId = 0 or @FloorId is null or f.FloorId = @FloorId)
	and (@HardwareTypeId is null or (@HardwareTypeId = 1 and l.DeviceId is not null) or (@HardwareTypeId = 2 and l.BeaconId is not null))
	AND (((@DepartmentId = 0 or @DepartmentId is null) OR (@DepartmentId is null AND dp.DepartmentId is null)) or (dp.DepartmentId = @DepartmentId)) 
	AND (l.DateControlOn BETWEEN @DateFrom AND @DateTo) 
	AND ((@ResponseTimeMin = 0) or (DATEDIFF(mi, l.DateControlOn, l.DateControlOff) > @ResponseTimeMin)) 
	AND (((@BedList = '' and (f.FloorId = @FloorId or @FloorId = 0)) and (@RoomList = '' and (f.FloorId = @FloorId or @FloorId = 0))) or
	--AND (((@BedList = '' and (f.FloorId = @FloorId or @FloorId = 0) and bd.Number is null) and (@RoomList = '' and (f.FloorId = @FloorId or @FloorId = 0) and bd.Number is null)) or
	bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) OR 
	r.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i))
	--and ((@RoomList='') or r.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i)) 
	--and ((@BedList='') or bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) or bd.Number is NULL or bd.Number = '') 
	GROUP BY --c.ControlCode, 
	CONVERT(date,DATEADD(dd, 7-(DATEPART(dw, DateControlOn)), DateControlOn))
	) as t
	) as t2
	where ((@ShowTop = 0) or (Id <= @ShowTop))  
else					-- per month
	select *
	from
	(
	select ROW_NUMBER() OVER (ORDER BY DateOn /*, ControlCode*/)  AS Id, *
	from
	(
	SELECT 
		CAST(
			  CAST(year(DateControlOn) AS VARCHAR(4)) +
			  RIGHT('0' + CAST(MONTH(DateControlOn) AS VARCHAR(2)), 2) +
			  RIGHT('0' + CAST(1 AS VARCHAR(2)), 2) 
		   AS DATETIME) DateOn,	avg(DATEDIFF(s, l.DateControlOn, l.DateControlOff)) AS ResponseTime, COUNT(*) AS CallCount--, c.ControlCode
	FROM  Lvm_MonitorRecordLog AS l LEFT OUTER JOIN
	Lvm_Beacon as bc on l.BeaconId = bc.BeaconId LEFT OUTER JOIN
	Lvm_Patient as p1 on bc.PatientId = p1.PatientId LEFT OUTER JOIN
	Lvm_Equipment as e on bc.EquipmentId = e.EquipmentId LEFT OUTER JOIN
	Lvm_Device AS d ON l.DeviceId = d.DeviceId INNER JOIN
	Lvm_DeviceTypeControl AS c ON (d.DeviceTypeId = c.DeviceTypeId or bc.DeviceTypeId = c.DeviceTypeId or (select [dbo].fLvmCtrlSystem()) = c.DeviceTypeId) AND l.ControlId = c.ControlNumber INNER JOIN
	Lvm_Floor as f on l.FloorId = f.FloorId LEFT OUTER JOIN
	Lvm_Room AS r ON l.RoomId = r.RoomId LEFT OUTER JOIN
	Lvm_Department as dp on r.DepartmentId = dp.DepartmentId LEFT OUTER JOIN
	Lvm_BedLvm_Device as ldb ON d.DeviceId = ldb.Lvm_Device_DeviceId LEFT OUTER JOIN
	Lvm_Bed as bd ON ldb.Lvm_Bed_BedId = bd.BedId
	WHERE (IsClosed = 1) AND
	(
	(@IsSuperAdmin=1)
	or ((l.FacilityId = 0) and (l.FacilityId in (SELECT f.FacilityId FROM  Lvm_FacilityUser AS u INNER JOIN Lvm_Facility AS f ON u.FacilityId = f.FacilityId WHERE (u.UserId = @UserId))))
	or (l.FacilityId = @FacilityId)
	)
	AND (@FloorId = 0 or @FloorId is null or f.FloorId = @FloorId)
	and (@HardwareTypeId is null or (@HardwareTypeId = 1 and l.DeviceId is not null) or (@HardwareTypeId = 2 and l.BeaconId is not null))
	AND (((@DepartmentId = 0 or @DepartmentId is null) OR (@DepartmentId is null AND dp.DepartmentId is null)) or (dp.DepartmentId = @DepartmentId)) 
	AND (l.DateControlOn BETWEEN @DateFrom AND @DateTo) 
	AND ((@ResponseTimeMin = 0) or (DATEDIFF(mi, l.DateControlOn, l.DateControlOff) > @ResponseTimeMin)) 
	AND (((@BedList = '' and (f.FloorId = @FloorId or @FloorId = 0)) and (@RoomList = '' and (f.FloorId = @FloorId or @FloorId = 0))) or
	--AND (((@BedList = '' and (f.FloorId = @FloorId or @FloorId = 0) and bd.Number is null) and (@RoomList = '' and (f.FloorId = @FloorId or @FloorId = 0) and bd.Number is null)) or
	bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) OR 
	r.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i))
	--and ((@RoomList='') or r.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i)) 
	--and ((@BedList='') or bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) or bd.Number is NULL or bd.Number = '')  
	GROUP BY --c.ControlCode, 
	year(DateControlOn) , MONTH(DateControlOn)
	) as t
	) as t2
	where ((@ShowTop = 0) or (Id <= @ShowTop))  

END
GO
/****** Object:  StoredProcedure [dbo].[sLvm_RepDevResponseSumCount]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- sLvm_RepDevResponseSumCount 1, 1, '2027-01-01', '2018-03-22', 0, 0, 0, '103,104'
-- sLvm_RepDevResponseSumCount 1, 1, '2017-06-01', '2018-06-01', 0, 0, 0, ''
ALTER PROCEDURE [dbo].[sLvm_RepDevResponseSumCount]
@FacilityId int,
@DepartmentId int,
@FloorId int,
@DateFrom datetime,
@DateTo datetime,
@ResponseTimeMin int,
@ShowTop int,

@RoomList varchar(4000),
@BedList varchar(8000),
@HardwareTypeId int = null,
@RecCount int OUTPUT
AS
BEGIN
SET NOCOUNT ON;
if (@DateTo = (CONVERT(date, @DateTo))) set @DateTo=DATEADD(d, 1, @DateTo)

set @RecCount=0;

SELECT @RecCount = COUNT(*) 
from (
SELECT ISNULL(dp.DepartmentName, '') as DepartmentName, ISNULL(r.RoomNumber, '') as RoomNumber, ISNULL(d.DeviceName, '') as DeviceName, ISNULL(p1.FullName, '') as PatientName
, ISNULL(bc.BeaconName, '') as BeaconName, ISNULL(e.EquipmentName, '') as EquipmentName, f.Number as FloorNumber
FROM  Lvm_MonitorRecordLog AS ml LEFT OUTER JOIN
	Lvm_Beacon as bc on ml.BeaconId = bc.BeaconId LEFT OUTER JOIN
	Lvm_Patient as p1 on bc.PatientId = p1.PatientId LEFT OUTER JOIN
	Lvm_Equipment as e on bc.EquipmentId = e.EquipmentId LEFT OUTER JOIN
	Lvm_Device AS d ON ml.DeviceId = d.DeviceId INNER JOIN
	Lvm_Floor as f on ml.FloorId = f.FloorId LEFT OUTER JOIN
	Lvm_Room AS r ON ml.RoomId = r.RoomId LEFT OUTER JOIN
	Lvm_Department as dp on r.DepartmentId = dp.DepartmentId LEFT OUTER JOIN
	Lvm_BedLvm_Device as ldb ON d.DeviceId = ldb.Lvm_Device_DeviceId LEFT OUTER JOIN
	Lvm_Bed as bd ON ldb.Lvm_Bed_BedId = bd.BedId
WHERE (ml.IsControlOn = 0) AND (ml.FacilityId = @FacilityId) 
AND (@FloorId = 0 or @FloorId is null or f.FloorId = @FloorId)
and (@HardwareTypeId is null or (@HardwareTypeId = 1 and ml.DeviceId is not null) or (@HardwareTypeId = 2 and ml.BeaconId is not null))
AND (((@DepartmentId = 0 or @DepartmentId is null) OR (@DepartmentId is null AND dp.DepartmentId is null)) or (dp.DepartmentId = @DepartmentId)) 
AND (ml.DateControlOn BETWEEN @DateFrom AND @DateTo)
AND (((@BedList = '' and (f.FloorId = @FloorId or @FloorId = 0)) and (@RoomList = '' and (f.FloorId = @FloorId or @FloorId = 0))) or
--AND (((@BedList = '' and (f.FloorId = @FloorId or @FloorId = 0) and bd.Number is null) and (@RoomList = '' and (f.FloorId = @FloorId or @FloorId = 0) and bd.Number is null)) or
	bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) OR 
	r.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i))
--and ((@RoomList='') or r.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i))
--and ((@BedList='') or bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) or bd.Number is NULL or bd.Number = '') 
GROUP BY dp.DepartmentName, f.Number, r.RoomNumber, d.DeviceName, bc.BeaconName, e.EquipmentName, p1.FullName
having ((@ResponseTimeMin = 0) or (AVG(DATEDIFF(mi, ml.DateControlOn, ml.DateControlOff)) > @ResponseTimeMin)) 
) as t

if ((@ShowTop > 0) and (@RecCount > @ShowTop)) set @RecCount = @ShowTop


select @RecCount RecCount

END
GO
/****** Object:  StoredProcedure [dbo].[sLvm_Reset_DB]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
sLvm_Reset DB
*/
 
ALTER PROCEDURE [dbo].[sLvm_Reset_DB] 
AS
BEGIN
SET NOCOUNT ON;
 
delete Lvm_CdrVodia
delete Lvm_DeviceAction
delete Lvm_BeaconAction
delete Lvm_DeviceRecord	 
delete Lvm_MonitorDeviceMap   
delete Lvm_BeaconRecord	 
delete Lvm_MonitorBeaconMap       
delete Lvm_MonitorRecord
delete Lvm_MonitorRecordLog	  
delete Lvm_PatientRecordLog
delete Lvm_Positioning
delete Lvm_PositioningHistory
delete Lvm_Beacon
delete Lvm_Patient
delete Lvm_Bed	   
delete Lvm_BedLvm_Device        
delete Lvm_Device
delete Lvm_Equipment
delete Lvm_Room	
delete Lvm_RecurringReportRunHistory
delete Lvm_RecurringReport	
delete Lvm_DevResponseTemplate
delete Lvm_CdrTemplate
delete Lvm_WebUrlConfig
delete Lvm_Department
delete Lvm_MobileClient
delete Lvm_RestrictedZone
delete Lvm_Floor
delete Lvm_DeviceActionTemplate
delete Lvm_DeviceRecordImage
delete Lvm_FacilityMonitor
delete Lvm_SecurityIp
--delete Lvm_Facility
--delete Lvm_Address
delete Lvm_CdrPortSip_CallTarget
delete Lvm_DeviceTypeControl
delete Lvm_ResourceText
--delete Lvm_StateProvince
delete Lvm_UrlDebug
--delete Lvm_UrlGeneratorField
delete Lvm_CdrPortSip
--delete Lvm_CdrType
--delete Lvm_Config
--delete Lvm_Country
--delete Lvm_DeviceActionType
delete Lvm_DeviceControlType
delete Lvm_DeviceType
delete Lvm_DeviceDiscovery
--delete Lvm_ImageType
--delete Lvm_MediaType
--delete Lvm_Report
delete Lvm_ResourceTextType
--delete Lvm_Template
--delete Lvm_UrlGeneratorType
delete Lvm_License
delete Lvm_EmailIncoming
delete Lvm_EmailOutgoing
delete Lvm_EmailIncomingProtocols
delete Lvm_AuthenticationMethods


exec Util_ResetIdentityColumn 'Lvm_CdrVodia',0
exec Util_ResetIdentityColumn 'Lvm_DeviceAction',0
exec Util_ResetIdentityColumn 'Lvm_DeviceRecord',0
exec Util_ResetIdentityColumn 'Lvm_MonitorDeviceMap',0
exec Util_ResetIdentityColumn 'Lvm_BeaconAction',0
exec Util_ResetIdentityColumn 'Lvm_BeaconRecord',0
exec Util_ResetIdentityColumn 'Lvm_MonitorBeaconMap',0
exec Util_ResetIdentityColumn 'Lvm_MonitorRecord',0
exec Util_ResetIdentityColumn 'Lvm_MonitorRecordLog',0
exec Util_ResetIdentityColumn 'Lvm_Device',0
exec Util_ResetIdentityColumn 'Lvm_DeviceDiscovery',0
exec Util_ResetIdentityColumn 'Lvm_Floor',0
exec Util_ResetIdentityColumn 'Lvm_Department',0
exec Util_ResetIdentityColumn 'Lvm_DeviceActionTemplate',0
exec Util_ResetIdentityColumn 'Lvm_DeviceRecordImage',0
-- -- exec Util_ResetIdentityColumn 'Lvm_FacilityMonitor',0 -- does not contain an identity column
-- exec Util_ResetIdentityColumn 'Lvm_FacilityUser',0
-- exec Util_ResetIdentityColumn 'Lvm_Image',0
exec Util_ResetIdentityColumn 'Lvm_Room',0
exec Util_ResetIdentityColumn 'Lvm_SecurityIp',0
--exec Util_ResetIdentityColumn 'Lvm_Facility',0
--exec Util_ResetIdentityColumn 'Lvm_Address',0
exec Util_ResetIdentityColumn 'Lvm_CdrPortSip_CallTarget',0
exec Util_ResetIdentityColumn 'Lvm_DeviceTypeControl',0
exec Util_ResetIdentityColumn 'Lvm_ResourceText',0
--exec Util_ResetIdentityColumn 'Lvm_StateProvince',0
exec Util_ResetIdentityColumn 'Lvm_UrlDebug',0
--exec Util_ResetIdentityColumn 'Lvm_UrlGeneratorField',0
exec Util_ResetIdentityColumn 'Lvm_CdrPortSip',0
--exec Util_ResetIdentityColumn 'Lvm_CdrType',0
--exec Util_ResetIdentityColumn 'Lvm_Config',0
--exec Util_ResetIdentityColumn 'Lvm_Country',0
--exec Util_ResetIdentityColumn 'Lvm_DeviceActionType',0
-- -- exec Util_ResetIdentityColumn 'Lvm_DeviceControlType',0 -- does not contain an identity column
exec Util_ResetIdentityColumn 'Lvm_DeviceType',0
--exec Util_ResetIdentityColumn 'Lvm_ImageType',0
--exec Util_ResetIdentityColumn 'Lvm_MediaType',0
--exec Util_ResetIdentityColumn 'Lvm_Report',0
exec Util_ResetIdentityColumn 'Lvm_ResourceTextType',0
--exec Util_ResetIdentityColumn 'Lvm_Template',0
--exec Util_ResetIdentityColumn 'Lvm_UrlGeneratorType',0
--exec Util_ResetIdentityColumn 'Lvm_EmailIncoming',1
--exec Util_ResetIdentityColumn 'Lvm_EmailOutgoing',1
exec Util_ResetIdentityColumn 'Lvm_Bed',0	
exec Util_ResetIdentityColumn 'Lvm_Patient',0
exec Util_ResetIdentityColumn 'Lvm_PatientRecordLog',0	
exec Util_ResetIdentityColumn 'Lvm_DevResponseTemplate',0	
exec Util_ResetIdentityColumn 'Lvm_CdrTemplate',0	
exec Util_ResetIdentityColumn 'Lvm_RecurringReportRunHistory',0	
exec Util_ResetIdentityColumn 'Lvm_RecurringReport',0	
exec Util_ResetIdentityColumn 'Lvm_WebUrlConfig',0
exec Util_ResetIdentityColumn 'Lvm_Equipment',0
exec Util_ResetIdentityColumn 'Lvm_Beacon',0
exec Util_ResetIdentityColumn 'Lvm_Positioning',0
exec Util_ResetIdentityColumn 'Lvm_PositioningHistory',0
exec Util_ResetIdentityColumn 'Lvm_RestrictedZone', 0


INSERT [dbo].[Lvm_EmailIncoming] ([EmailIncomingId], [Type], [Server], [Username], [Password], [Port], [DeleteMessage], [MailboxDelayCheckSec], [Authentication], [SSL]) 
VALUES (1, '', '', '', '', 0, 0, 60, 'Password', 0)
INSERT [dbo].[Lvm_EmailOutgoing] ([EmailOutgoingId], [Email], [Password], [Server], [Port], [SSL], [Authentication]) 
VALUES (1, '', '', '', 0, 0, 'Password')

INSERT [dbo].[Lvm_EmailIncomingProtocols] ([EmailIncomingProtocols], [Name], [Description]) 
VALUES (1, 'POP3', 'POP3 Incoming Mail Server Protocol')
INSERT [dbo].[Lvm_EmailIncomingProtocols] ([EmailIncomingProtocols], [Name], [Description]) 
VALUES (2, 'IMAP', 'IMAP Incoming Mail Server Protocol')

INSERT [dbo].[Lvm_AuthenticationMethods] ([AuthenticationMethodsId], [Name], [Description]) 
VALUES (1, 'Password', 'Password authentication method')
INSERT [dbo].[Lvm_AuthenticationMethods] ([AuthenticationMethodsId], [Name], [Description]) 
VALUES (2, 'MD5', 'MD5 authentication method')
INSERT [dbo].[Lvm_AuthenticationMethods] ([AuthenticationMethodsId], [Name], [Description]) 
VALUES (3, 'NTLM', 'NTLM authentication method')
INSERT [dbo].[Lvm_AuthenticationMethods] ([AuthenticationMethodsId], [Name], [Description]) 
VALUES (4, 'Kerberos', 'Kerberos authentication method')
INSERT [dbo].[Lvm_AuthenticationMethods] ([AuthenticationMethodsId], [Name], [Description]) 
VALUES (5, 'None', 'No authentication method')
 
-- Insert Defaults
----SET IDENTITY_INSERT [dbo].[Lvm_Config] ON 
----GO
----INSERT [dbo].[Lvm_Config] ([ConfigId], [AuthCode], [BaseUrl], [IsDeviceDiscovery], [DeviceDiscoveryFacilityId], [ControlImageWidthMax], [ControlImagePath], [DevRecordImageWidthMax], [DevRecordImagePath]) VALUES (1, N'authcode', NULL, 1, 1, 200, N'/Content/Images/Control', 200, N'/Content/Images/DevRecord')
----GO
----SET IDENTITY_INSERT [dbo].[Lvm_Config] OFF
----GO
---
----SET IDENTITY_INSERT [dbo].[Lvm_MediaType] ON 
----GO
----INSERT [dbo].[Lvm_MediaType] ([MediaTypeId], [MediaType]) VALUES (1, N'Image')
----GO
----INSERT [dbo].[Lvm_MediaType] ([MediaTypeId], [MediaType]) VALUES (2, N'Video')
----GO
----INSERT [dbo].[Lvm_MediaType] ([MediaTypeId], [MediaType]) VALUES (3, N'Live Stream')
----GO
----SET IDENTITY_INSERT [dbo].[Lvm_MediaType] OFF
----GO
---
--SET IDENTITY_INSERT [dbo].[Lvm_DeviceType] ON
--INSERT [dbo].[Lvm_DeviceType] ([DeviceTypeId], [DeviceTypeName], [DeviceTypeDescription]) 
--VALUES (1, N'System', N'System Type')
--SET IDENTITY_INSERT [dbo].[Lvm_DeviceType] OFF
---
--SET IDENTITY_INSERT [dbo].[Lvm_Address] ON 
--GO
--INSERT [dbo].[Lvm_Address] ([AddressId], [StateProvinceId], [CountryId], [City], [Street1], [Street2], [Street3], [Street4], [ZipPostalCode], [Phone], [Fax], [Email], [Website], [ContactName]) VALUES (1, 60, 2, N'Toronto', N'Street1', N'ASDASDSA asda', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL)
--GO
--SET IDENTITY_INSERT [dbo].[Lvm_Address] OFF
--GO
---
----SET IDENTITY_INSERT [dbo].[Lvm_Template] ON 
----GO
----INSERT [dbo].[Lvm_Template] ([TemplateId], [TemplateNumber], [TemplateName], [TemplateFile]) VALUES (3, 1, N'Template1', N'Template1.cshtml')
----GO
----SET IDENTITY_INSERT [dbo].[Lvm_Template] OFF
----GO
---
--SET IDENTITY_INSERT [dbo].[Lvm_Facility] ON 
--GO
--INSERT [dbo].[Lvm_Facility] ([FacilityId], [AddressId], [TemplateId], [FacilityName], [FacilityDescription], [FacilityNotes]) VALUES (1, 1, 3, N'Facility1', N'Facility1 Description', N'Facility1 Notes')
--GO
--SET IDENTITY_INSERT [dbo].[Lvm_Facility] OFF
--GO
---
--SET IDENTITY_INSERT [dbo].[Lvm_Room] ON 
--GO
--INSERT [dbo].[Lvm_Room] ([RoomId], [FacilityId], [RoomNumber], [FloorNumber], [RoomDescription]) VALUES (1, 1, 1, 1, N'111')
--GO
--SET IDENTITY_INSERT [dbo].[Lvm_Room] OFF
--GO
---
--SET IDENTITY_INSERT [dbo].[Lvm_Device] ON 
--GO
--INSERT [dbo].[Lvm_Device] ([DeviceId], [DeviceTypeId], [FacilityId], [RoomId], [DeviceNumber], [DeviceName], [DeviceDescription]) VALUES (1, 1, 1, 1, 1, N'F1D1', N'F1D1 d')
--GO
--SET IDENTITY_INSERT [dbo].[Lvm_Device] OFF
--GO
---
--SET IDENTITY_INSERT [dbo].[Lvm_DeviceTypeControl] ON 
--INSERT [dbo].[Lvm_DeviceTypeControl] ([DeviceTypeControlId], [DeviceTypeId], [ControlNumber], [ControlCode], [ControlName], [ControlImage], [ControlDescription], [ChartColor]) 
--VALUES (1, 1, 1, N'RestrictedZoneEntry', N'RestrictedZoneEntry', N'restricted_zone_alarm.png', N'Restricted zone entry alarm', N'FFFFFF')
--INSERT [dbo].[Lvm_DeviceTypeControl] ([DeviceTypeControlId], [DeviceTypeId], [ControlNumber], [ControlName], [ControlImage], [ControlDescription]) VALUES (2, 1, 2, N'Ctl2', N'ico2.png', N'Ctl2 description')
--GO
--INSERT [dbo].[Lvm_DeviceTypeControl] ([DeviceTypeControlId], [DeviceTypeId], [ControlNumber], [ControlName], [ControlImage], [ControlDescription]) VALUES (3, 1, 3, N'Ctl3', N'ico3.png', N'Ctl3 description')
--GO
--INSERT [dbo].[Lvm_DeviceTypeControl] ([DeviceTypeControlId], [DeviceTypeId], [ControlNumber], [ControlName], [ControlImage], [ControlDescription]) VALUES (4, 1, 4, N'Ctl4', N'ico4.png', N'Ctl4 description')
--GO
--INSERT [dbo].[Lvm_DeviceTypeControl] ([DeviceTypeControlId], [DeviceTypeId], [ControlNumber], [ControlName], [ControlImage], [ControlDescription]) VALUES (7, 1, 5, N'_ico3', N'_ico123.png', NULL)
--GO
--SET IDENTITY_INSERT [dbo].[Lvm_DeviceTypeControl] OFF
END
GO
/****** Object:  StoredProcedure [dbo].[sLvm_Reset_DeviceMonitorRecord]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- sLvm_Reset_DeviceMonitorRecord
ALTER PROCEDURE [dbo].[sLvm_Reset_DeviceMonitorRecord] 
AS
BEGIN
SET NOCOUNT ON;
		        
delete Lvm_DeviceRecord	 
delete Lvm_BeaconRecord       
delete Lvm_MonitorRecord
delete Lvm_MonitorRecordLog	        
       
exec Util_ResetIdentityColumn 'Lvm_BeaconRecord', 0
exec Util_ResetIdentityColumn 'Lvm_DeviceRecord',0        
exec Util_ResetIdentityColumn 'Lvm_MonitorRecord',0	        
exec Util_ResetIdentityColumn 'Lvm_MonitorRecordLog',0
	        
		        
return;

END
GO
/****** Object:  StoredProcedure [dbo].[sLvm_Reset_InsertMonLogTestData]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
declare @DateTo datetime; set @DateTo = DATEADD(day,3,GETDATE())  
exec sLvm_Reset_InsertMonLogTestData '2017-1-1', @DateTo 
*/

ALTER PROCEDURE [dbo].[sLvm_Reset_InsertMonLogTestData]
@DateFrom datetime,
@DateTo datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

declare @MonFrom int, @MonTo int; set @MonFrom=1; set @MonTo=2
declare @FclFrom int, @FclTo int; set @FclFrom=1; set @FclTo=3
declare @DevFrom int, @DevTo int; set @DevFrom=1; set @DevTo=16
declare @DateOn datetime, @DateOff datetime
declare @ControlId int

set @DateOn=@DateFrom
WHILE (@DateOn < @DateTo)  
BEGIN  

	set @DateOn = DATEADD(minute, RAND()*(60 - 1) + 1, @DateOn)
	set @DateOff = DATEADD(minute, RAND()*(17 - 1) + 1, @DateOn)

	set @ControlId = RAND()*4 + 1

	insert into Lvm_MonitorRecordLog (MonitorId,FacilityId,DeviceId,ControlId,IsControlOn,
	DateControlOn,DateControlOff,DeviceRecordIdOn,DeviceRecordIdOff,IsClosed)
	values (RAND()*(@MonTo - @MonFrom) + @MonFrom, RAND()*(@FclTo - @FclFrom) + @FclFrom, RAND()*(@DevTo - @DevFrom) + @DevFrom, @ControlId, 0,
	@DateOn, @DateOff, 1,1,1)
END


END

GO
/****** Object:  StoredProcedure [dbo].[sLvm_ResetDeviceAndRoom]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[sLvm_ResetDeviceAndRoom] 
AS
BEGIN
SET NOCOUNT ON;
		        
delete Lvm_DeviceRecord	  
delete Lvm_BeaconRecord      
delete Lvm_MonitorRecord
delete Lvm_MonitorRecordLog	  
delete Lvm_PatientRecordLog
delete Lvm_BeaconAction
delete Lvm_PositioningHistory
delete Lvm_Positioning
delete Lvm_Beacon
delete Lvm_Patient
delete Lvm_Bed	   
delete Lvm_BedLvm_Device
delete Lvm_DeviceAction
delete Lvm_Device
delete Lvm_Equipment 
delete Lvm_Room		        
       
exec Util_ResetIdentityColumn 'Lvm_BeaconRecord',0  
exec Util_ResetIdentityColumn 'Lvm_DeviceRecord',0        
exec Util_ResetIdentityColumn 'Lvm_MonitorRecord',0	        
exec Util_ResetIdentityColumn 'Lvm_MonitorRecordLog',0
exec Util_ResetIdentityColumn 'Lvm_PositioningHistory',0
exec Util_ResetIdentityColumn 'Lvm_Positioning',0
exec Util_ResetIdentityColumn 'Lvm_DeviceAction',0
exec Util_ResetIdentityColumn 'Lvm_Device',0
exec Util_ResetIdentityColumn 'Lvm_Room',0	
exec Util_ResetIdentityColumn 'Lvm_Bed',0	
exec Util_ResetIdentityColumn 'Lvm_Patient',0
exec Util_ResetIdentityColumn 'Lvm_PatientRecordLog',0		
exec Util_ResetIdentityColumn 'Lvm_Equipment',0
exec Util_ResetIdentityColumn 'Lvm_BeaconAction',0
exec Util_ResetIdentityColumn 'Lvm_Beacon',0        
return;

END
GO
/****** Object:  StoredProcedure [dbo].[sLvm_RoomCsvImport]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Facility Name;Floor Number;Department Name;Room Number;RoomDescription;Beds
-- sLvm_RoomCsvImport 'Demo Facility;1;Nursing Care;102;Room 102;1020,1021'
-- sLvm_RoomCsvImport 'Demo Facility;1;;120;Room 120;'
ALTER PROCEDURE [dbo].[sLvm_RoomCsvImport]
@Csv varchar(max),
@Err varchar(max) output,
@ErrCode int output
AS
BEGIN
	SET NOCOUNT ON;

	declare @FacilityName varchar(100), @FloorNumber varchar(50), @DepartmentName varchar(100), @RoomNumber  varchar(50), @RoomDescription varchar(1000), @Beds varchar(50)
	declare @FacilityId int, @FloorId int, @DepartmentId int, @RoomId int, @BedId int

	set @RoomId = 0
	declare @Msg nvarchar(max) = ''

	declare @Tbl table (Id int NOT NULL identity(1,1), Fld varchar(max))
	insert into @Tbl
	Select  LTRIM(RTRIM(Itm)) Fld FROM dbo.fSplit(@Csv,';')

	select @FacilityName = Fld from @tbl where Id=1
	select @FloorNumber = Fld from @tbl where Id=2
	select @DepartmentName = Fld from @tbl where Id=3
	select @RoomNumber = Fld from @tbl where Id=4
	select @RoomDescription = Fld from @tbl where Id=5
	select @Beds = Fld from @tbl where Id=6

	set @FacilityId = isnull((select top 1 FacilityId from Lvm_Facility where FacilityName=@FacilityName),0)
	set @FloorId = isnull((select top 1 FloorId from Lvm_Floor where FacilityId=@FacilityId and Number=@FloorNumber),0)
	set @DepartmentId = isnull((select top 1 DepartmentId from Lvm_Department where FacilityId=@FacilityId and FloorId=@FloorId and DepartmentName=@DepartmentName),null)

	declare @CheckFloorForDepartment int 
	set @CheckFloorForDepartment = 0
	set @CheckFloorForDepartment = isnull((select top 1 FloorId from Lvm_Department where FacilityId=@FacilityId and DepartmentName=@DepartmentName), 0)

	if (@CheckFloorForDepartment = 0 or @CheckFloorForDepartment is null or @CheckFloorForDepartment != @FloorId)
	set @Msg = @Msg + ' Department "' + @DepartmentName + '" does not exist on floor "' + @FloorNumber + '".'

	if (@FacilityId=0) set @Msg= @Msg + ' Facility "' + @FacilityName + '" is not found.'
	if (@FloorId=0) set @Msg= @Msg + ' Floor "' + @FloorNumber + '" is not found.'

	set @Msg = LTRIM(@Msg);

	IF ((@FacilityId > 0 and @FloorId > 0 and (@Msg = '' or @Msg is null)) and (NOT EXISTS (SELECT * FROM Lvm_Room WHERE FacilityId = @FacilityId AND RoomNumber = @RoomNumber)))
	begin
		set @ErrCode = 1
		insert into Lvm_Room(FacilityId, FloorId, DepartmentId, RoomNumber, RoomDescription) 
		values(@FacilityId, @FloorId, @DepartmentId, @RoomNumber, isnull(@RoomDescription,''))
		select @RoomId = SCOPE_IDENTITY()

		/*
		* 1. split bed string into table rows, check that bed does not already exist or bed is not assigned to a room
		* 2. iterate over each row and add bed entry to Lvm_Bed table
		*/
		if (not(@Beds is null) and @Beds != '')
		begin
			declare @TblBeds table (Id int NOT NULL identity(1,1), Fld varchar(max))
			insert into @TblBeds
			Select  LTRIM(RTRIM(Itm)) Fld FROM dbo.fSplit(@Beds,',') where (NOT EXISTS (select * from Lvm_Bed where Number=Itm) or (select RoomId from Lvm_Bed where Number=Itm) is null)
			DECLARE @LoopCounter INT , @MaxTblId INT, 
					@Number NVARCHAR(50)
			SELECT @LoopCounter = min(Id), @MaxTblId = max(Id) 
			FROM @TblBeds
 
			WHILE(@LoopCounter IS NOT NULL AND @LoopCounter <= @MaxTblId)
			BEGIN
				SELECT @Number = Fld FROM @TblBeds WHERE Id = @LoopCounter
				insert into Lvm_Bed(RoomId, Number, Active, Description, FloorId, DepartmentId, FacilityId)
				values(@RoomId, @Number, 1, 'Added from import', @FloorId, @DepartmentId, @FacilityId)
		  
				SET @LoopCounter  = @LoopCounter  + 1        
			END
		end
	end
	else
	begin
		set @ErrCode = -1
		set @Err = @Msg
	end
END
GO
/****** Object:  StoredProcedure [dbo].[sLvm_UpdateDeviceDiscovery]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- sLvm_UpdateDeviceDiscovery '1-2-3', 1, 2, 3, 4
ALTER PROCEDURE [dbo].[sLvm_UpdateDeviceDiscovery]
@Ids varchar(max),
@FacilityId int,
@FloorId int,
@DeviceTypeId int,
@RoomId int
AS
BEGIN
	SET NOCOUNT ON;

if (@Ids<>'')
update Lvm_DeviceDiscovery 
set DeviceTypeId = case @DeviceTypeId when 0 then DeviceTypeId else @DeviceTypeId end,
FacilityId = case @FacilityId when 0 then FacilityId else @FacilityId end,
FloorId = case @FloorId when 0 then NULL else @FloorId end,
RoomId = case @RoomId when 0 then NULL else @RoomId end
where DeviceDiscoveryId in (SELECT cast(i.Itm as int) Itm FROM dbo.fSplit(@Ids,'-') AS i)

update dd
set dd.DeviceName=d.DeviceName, dd.DeviceDescription=d.DeviceDescription
FROM Lvm_Device AS d INNER JOIN Lvm_DeviceDiscovery AS dd ON d.FacilityId = dd.FacilityId AND d.FloorId = dd.FloorId AND d.DeviceTypeId = dd.DeviceTypeId AND d.DeviceCode = dd.DeviceCode
where DeviceDiscoveryId in (SELECT cast(i.Itm as int) Itm FROM dbo.fSplit(@Ids,'-') AS i)


update dd
set dd.ControlName=c.ControlName
FROM Lvm_DeviceDiscovery AS dd INNER JOIN Lvm_DeviceTypeControl AS c ON dd.DeviceTypeId = c.DeviceTypeId AND dd.ControlCode = c.ControlCode
where DeviceDiscoveryId in (SELECT cast(i.Itm as int) Itm FROM dbo.fSplit(@Ids,'-') AS i)


END
GO
/****** Object:  StoredProcedure [dbo].[sLvmBeaconRecordProcess]    Script Date: 4/25/2018 11:54:47 AM ******/
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

DECLARE @FacilityId INT, @FloorId INT, @DepartmentId INT, @PatientId INT, @EquipmentId INT, @BeaconId INT, @ControlId INT, @IsControlOn BIT, @MonitorId INT, @TemplateId INT, @RestrictedZoneId INT, @BeaconData NVARCHAR(MAX), @MonBeaconData NVARCHAR(MAX); set @MonBeaconData=''
declare @MonitorRecordId int, @Control1 bit, @Control2 bit, @Control3 bit, @Control4 bit, @Control5 bit, @Control6 bit, @Control7 bit, @Control8 bit
declare @IsAnyCtlOn bit; set @IsAnyCtlOn=0
set @MonitorRecordId=0
set @Control1=0; set @Control2=0; set @Control3=0; set @Control4=0; set @Control5=0; set @Control6=0; set @Control7=0; set @Control8=0

declare @TemplateName varchar(100); set @TemplateName=''
declare @BeaconRecordImg varchar(1000)
declare @MediaType int
declare @DNow datetime; set @DNow=getdate();

declare @CtlImgName table (ControlNumber int, ControlImage varchar(300), ControlName varchar(100))

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
		insert into @CtlImgName SELECT ControlNumber, ControlImage, ControlName FROM vLvmControlImageByBeacon WHERE BeaconId = @BeaconId order by ControlNumber

		declare @Img1 varchar(300), @Img2 varchar(300), @Img3 varchar(300), @Img4 varchar(300), @Img5 varchar(300), @Img6 varchar(300), @Img7 varchar(300), @Img8 varchar(300)
		SELECT @Img1=isnull([1],''), @Img2=isnull([2],''), @Img3=isnull([3],''), @Img4=isnull([4],''), @Img5=isnull([5],''), @Img6=isnull([6],''), @Img7=isnull([7],''), @Img8=isnull([8],'')
		FROM (SELECT ControlNumber, ControlImage from @CtlImgName) AS SourceTable
		PIVOT (max(ControlImage) FOR ControlNumber IN ([1], [2], [3], [4], [5], [6], [7], [8])) AS PivotTable

		declare @CtlN1 varchar(100), @CtlN2 varchar(100), @CtlN3 varchar(100), @CtlN4 varchar(100), @CtlN5 varchar(100), @CtlN6 varchar(100), @CtlN7 varchar(100), @CtlN8 varchar(100)
		SELECT @CtlN1=isnull([1],''), @CtlN2=isnull([2],''), @CtlN3=isnull([3],''), @CtlN4=isnull([4],''), @CtlN5=isnull([5],''), @CtlN6=isnull([6],''), @CtlN7=isnull([7],''), @CtlN8=isnull([8],'')
		FROM (SELECT ControlNumber, ControlName from @CtlImgName) AS SourceTable
		PIVOT (max(ControlName) FOR ControlNumber IN ([1], [2], [3], [4], [5], [6], [7], [8])) AS PivotTable


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
		MediaTypeId, BeaconRecordImg, TemplateName)
		values (@FacilityId, @FloorId, @DepartmentId, @PatientId, @EquipmentId, @MonitorId, @BeaconId, @TemplateId, @RestrictedZoneId,
		@Control1, @Control2, @Control3, @Control4, @Control5, @Control6, @Control7, @Control8, 
		@BeaconData, @BeaconRecordId, @DNow,
		@DNow, @DNow, @DNow, @DNow, @DNow, @DNow, @DNow, @DNow,
		@Img1, @Img2, @Img3, @Img4, @Img5, @Img6, @Img7, @Img8, 
		@CtlN1, @CtlN2, @CtlN3, @CtlN4, @CtlN5, @CtlN6, @CtlN7, @CtlN8, 
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
GO
/****** Object:  StoredProcedure [dbo].[sLvmDeviceRecordProcess]    Script Date: 4/25/2018 11:54:47 AM ******/
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
ALTER PROCEDURE [dbo].[sLvmDeviceRecordProcess] 
@DeviceRecordId int
AS
BEGIN
SET NOCOUNT ON;

DECLARE @FacilityId INT, @FloorId INT, @DepartmentId INT, @RoomId INT, @DeviceId int, @ControlId INT, @IsControlOn BIT, @MonitorId INT, @TemplateId INT, @DeviceData NVARCHAR(MAX), @MonDeviceData NVARCHAR(MAX); set @MonDeviceData=''
declare @MonitorRecordId int, @Control1 bit, @Control2 bit, @Control3 bit, @Control4 bit, @Control5 bit, @Control6 bit, @Control7 bit, @Control8 bit
declare @IsAnyCtlOn bit; set @IsAnyCtlOn=0
set @MonitorRecordId=0
set @Control1=0; set @Control2=0; set @Control3=0; set @Control4=0; set @Control5=0; set @Control6=0; set @Control7=0; set @Control8=0

declare @TemplateName varchar(100); set @TemplateName=''
declare @DeviceRecordImg varchar(1000)
declare @MediaType int
declare @DNow datetime; set @DNow=getdate();

declare @CtlImgName table (ControlNumber int, ControlImage varchar(300), ControlName varchar(100))

SELECT @FacilityId=FacilityId, @FloorId=FloorId, @DepartmentId=DepartmentId, @RoomId=RoomId, @DeviceId=DeviceId, @ControlId=ControlId, @IsControlOn=IsControlOn, @MonitorId=MonitorId, @TemplateId=TemplateId, @DeviceData=DeviceData	--, DateCreated, IsProcessed, IsError, ErrorMessage
FROM  Lvm_DeviceRecord
where DeviceRecordId = @DeviceRecordId

select @MonitorRecordId=MonitorRecordId, @MonDeviceData=DeviceData,
@Control1=Control1, @Control2=Control2, @Control3=Control3, @Control4=Control4, @Control5=Control5, @Control6=Control6, @Control7=Control7, @Control8=Control8 
from Lvm_MonitorRecord where DeviceId=@DeviceId

if (@ControlId=1) set @Control1=@IsControlOn; else if (@ControlId=2) set @Control2=@IsControlOn; else if (@ControlId=3) set @Control3=@IsControlOn; else if (@ControlId=4) set @Control4=@IsControlOn; else if (@ControlId=5) set @Control5=@IsControlOn; else if (@ControlId=6) set @Control6=@IsControlOn; else if (@ControlId=7) set @Control7=@IsControlOn; else if (@ControlId=8) set @Control8=@IsControlOn; 

if ((@Control1=1) or (@Control2=1) or (@Control3=1) or (@Control4=1) or (@Control5=1) or (@Control6=1) or (@Control7=1) or (@Control8=1)) set @IsAnyCtlOn=1


if (@MonitorRecordId=0)
-- Add new record if @IsAnyCtlOn
Begin
	if (@IsAnyCtlOn=1) 
		begin
		DELETE FROM @CtlImgName
		insert into @CtlImgName SELECT ControlNumber, ControlImage, ControlName FROM vLvmControlImageByDev WHERE DeviceId = @DeviceId order by ControlNumber

		declare @Img1 varchar(300), @Img2 varchar(300), @Img3 varchar(300), @Img4 varchar(300), @Img5 varchar(300), @Img6 varchar(300), @Img7 varchar(300), @Img8 varchar(300)
		SELECT @Img1=isnull([1],''), @Img2=isnull([2],''), @Img3=isnull([3],''), @Img4=isnull([4],''), @Img5=isnull([5],''), @Img6=isnull([6],''), @Img7=isnull([7],''), @Img8=isnull([8],'')
		FROM (SELECT ControlNumber, ControlImage from @CtlImgName) AS SourceTable
		PIVOT (max(ControlImage) FOR ControlNumber IN ([1], [2], [3], [4], [5], [6], [7], [8])) AS PivotTable

		declare @CtlN1 varchar(100), @CtlN2 varchar(100), @CtlN3 varchar(100), @CtlN4 varchar(100), @CtlN5 varchar(100), @CtlN6 varchar(100), @CtlN7 varchar(100), @CtlN8 varchar(100)
		SELECT @CtlN1=isnull([1],''), @CtlN2=isnull([2],''), @CtlN3=isnull([3],''), @CtlN4=isnull([4],''), @CtlN5=isnull([5],''), @CtlN6=isnull([6],''), @CtlN7=isnull([7],''), @CtlN8=isnull([8],'')
		FROM (SELECT ControlNumber, ControlName from @CtlImgName) AS SourceTable
		PIVOT (max(ControlName) FOR ControlNumber IN ([1], [2], [3], [4], [5], [6], [7], [8])) AS PivotTable


		--declare @DevRecordImagePath varchar(1000); 
		--set @DevRecordImagePath= replace('~/' + (SELECT TOP 1 ImagePath FROM Lvm_ImageType WHERE ImageTypeId = 2) + '/','//','/');

		--set @DeviceRecordImg=dbo.fLvmDevRecImage(@FacilityId, dbo.fLvmGetStrBetween(@DeviceData, 'i=', '&'))
		set @DeviceRecordImg=dbo.fLvmDevImage(@FacilityId, @DeviceId)
		
		set @MediaType=cast(SUBSTRING(@DeviceRecordImg,1,1) as int)
		set @DeviceRecordImg=SUBSTRING(@DeviceRecordImg,2,(len(@DeviceRecordImg)-1))
		--if (CHARINDEX('/', @DeviceRecordImg)=0 ) set @DeviceRecordImg= (replace('~/' + (SELECT TOP 1 ImagePath FROM Lvm_ImageType WHERE ImageTypeId = 2) + '/','//','/')) + cast(@FacilityId as varchar(10)) + '/' + @DeviceRecordImg

		select top 1 @TemplateId=TemplateId, @TemplateName=TemplateName from Lvm_Template where TemplateNumber=@TemplateId

		-- Insert record
		INSERT INTO Lvm_MonitorRecord (FacilityId, FloorId, DepartmentId, RoomId, MonitorId, DeviceId, TemplateId,  
		Control1, Control2, Control3, Control4, Control5, Control6, Control7, Control8,  
		DeviceData, LastDeviceRecordId, DateCreated,
		DateOn1, DateOn2, DateOn3, DateOn4, DateOn5, DateOn6, DateOn7, DateOn8, 
		ControlImg1, ControlImg2, ControlImg3, ControlImg4, ControlImg5, ControlImg6, ControlImg7, ControlImg8, 
		ControlName1, ControlName2, ControlName3, ControlName4, ControlName5, ControlName6, ControlName7, ControlName8, 
		MediaTypeId, DeviceRecordImg, TemplateName)
		values (@FacilityId, @FloorId, @DepartmentId, @RoomId, @MonitorId, @DeviceId, @TemplateId, 
		@Control1, @Control2, @Control3, @Control4, @Control5, @Control6, @Control7, @Control8, 
		@DeviceData, @DeviceRecordId, @DNow,
		@DNow, @DNow, @DNow, @DNow, @DNow, @DNow, @DNow, @DNow,
		@Img1, @Img2, @Img3, @Img4, @Img5, @Img6, @Img7, @Img8, 
		@CtlN1, @CtlN2, @CtlN3, @CtlN4, @CtlN5, @CtlN6, @CtlN7, @CtlN8, 
		@MediaType, @DeviceRecordImg,@TemplateName
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
		
		if (@IsControlOn=0) set @DeviceData=@MonDeviceData -- if a control is turning off we keep Lvm_MonitorRecord DeviceData

		Update Lvm_MonitorRecord set TemplateId=@TemplateId, 
		Control1=@Control1, Control2=@Control2, Control3=@Control3, Control4=@Control4, Control5=@Control5, Control6=@Control6, Control7=@Control7, Control8=@Control8, 
		DeviceData=@DeviceData, LastDeviceRecordId=@DeviceRecordId
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

update Lvm_DeviceRecord set IsProcessed=1 where DeviceRecordId=@DeviceRecordId

--Lvm_MonitorRecordLog
	if (@IsControlOn=1)
	begin
		IF (not EXISTS(SELECT *  FROM  Lvm_MonitorRecordLog  WHERE IsClosed=0 and MonitorId=@MonitorId and FacilityId=@FacilityId and DeviceId=@DeviceId and ControlId=@ControlId and IsControlOn=@IsControlOn))
		INSERT INTO Lvm_MonitorRecordLog (MonitorId, FacilityId, FloorId, DepartmentId, RoomId, DeviceId, ControlId, IsControlOn, DeviceRecordIdOn, DateControlOn, IsClosed)
		values (@MonitorId, @FacilityId, @FloorId, @DepartmentId, @RoomId, @DeviceId, @ControlId, @IsControlOn, @DeviceRecordId, @DNow, 0)
	end
	else
		update Lvm_MonitorRecordLog  set IsControlOn=@IsControlOn, DateControlOff = @DNow, DeviceRecordIdOff = @DeviceRecordId, IsClosed= 1
		where FacilityId=@FacilityId and DeviceId=@DeviceId and ControlId=@ControlId and IsControlOn= 1
END
GO

/****** Object:  StoredProcedure [dbo].[sLvmMonitorAlarm]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
 exec sLvmMonitorHistory 1, 3
 exec sLvmMonitorHistory_0 1, 1
*/
ALTER PROCEDURE [dbo].[sLvmMonitorAlarm] 
@FacilityId int,
@MonitorId int
AS
BEGIN
	SET NOCOUNT ON;

declare @IsMonMapDev bit
declare @IsMonMapBeacon bit
declare @MonMapTblDev table (MonitorDeviceMapId int, FacilityId int, MonitorId int, DeviceId int, DeviceNumber int)
declare @MonMapTblBeacon table (MonitorBeaconMapId int, FacilityId int, MonitorId int, BeaconId int)
--insert into @MonMapTbl select * from Lvm_MonitorDeviceMap where FacilityId = @FacilityId and MonitorId=@MonitorId

if ((select count(*) from @MonMapTblDev)>0) set @IsMonMapDev=1 else set @IsMonMapDev=0
if ((select count(*) from @MonMapTblBeacon)>0) set @IsMonMapBeacon=1 else set @IsMonMapBeacon=0

select top 20 * from
(
select ROW_NUMBER() OVER (ORDER BY DateOn DESC)  AS Id, *
from
(
SELECT distinct dp.DepartmentName, f.Number AS Floor, cast(r.RoomNumber as varchar(20)) AS Room, d.DeviceName, dc.ControlName, dc.ControlImage AS ControlImageFile
, m.DateControlOn AS DateOn, DATEDIFF(s, m.DateControlOn, GETDATE()) AS DateDif, dc.ChartColor as ControlBackgroundColor, d.ImageFile as DeviceImage, @FacilityId as FacilityId
, STRING_AGG(ISNULL(bd.Number + ISNULL(' (' + p.FullName + ')', ''), ''), ',') AS Bed, 
ISNULL(p1.FullName, '') as PatientName, ISNULL(bc.BeaconName, '') as BeaconName, ISNULL(e.EquipmentName, '') as EquipmentName, d.DeviceId, bc.BeaconId, ISNULL(z.ZoneName, '') as ZoneName
FROM  Lvm_MonitorRecordLog AS m LEFT OUTER JOIN
	Lvm_Device AS d ON m.DeviceId = d.DeviceId LEFT OUTER JOIN
	Lvm_Beacon as bc on m.BeaconId = bc.BeaconId LEFT OUTER JOIN
	Lvm_Floor as f on m.FloorId = f.FloorId LEFT OUTER JOIN
	Lvm_Room AS r ON m.RoomId = r.RoomId INNER JOIN
	Lvm_DeviceTypeControl AS dc ON (d.DeviceTypeId = dc.DeviceTypeId or bc.DeviceTypeId = dc.DeviceTypeId or (select [dbo].fLvmCtrlSystem()) = dc.DeviceTypeId) AND m.ControlId = dc.ControlNumber LEFT OUTER JOIN
	Lvm_BeaconRecord AS br ON m.BeaconRecordIdOn = br.BeaconRecordId LEFT OUTER JOIN
	Lvm_DeviceRecord AS dr ON m.DeviceRecordIdOn = dr.DeviceRecordId LEFT OUTER JOIN
	Lvm_Department AS dp ON m.DepartmentId = dp.DepartmentId LEFT OUTER JOIN
	Lvm_BedLvm_Device as ldb ON d.DeviceId = ldb.Lvm_Device_DeviceId LEFT OUTER JOIN
	Lvm_Bed as bd ON ldb.Lvm_Bed_BedId = bd.BedId LEFT OUTER JOIN
	Lvm_Patient AS p ON ldb.Lvm_Bed_BedId = p.BedId LEFT OUTER JOIN
	Lvm_Patient as p1 on bc.PatientId = p1.PatientId LEFT OUTER JOIN
	Lvm_Equipment as e on bc.EquipmentId = e.EquipmentId LEFT OUTER JOIN
	Lvm_RestrictedZone as z on m.RestrictedZoneId = z.RestrictedZoneId
WHERE (m.IsClosed = 0) and m.FacilityId=@FacilityId
and ((((@IsMonMapDev=1) and exists(select * from @MonMapTblDev where DeviceId=m.DeviceId)) or ((@IsMonMapBeacon=1) and exists(select * from @MonMapTblBeacon where BeaconId=m.BeaconId)))
or ((@IsMonMapDev=0 or @IsMonMapBeacon=0) and (m.MonitorId=@MonitorId)))
--and (bd.Number is NULL or p.PatientId is NULL or p.PatientStatusId = 1)
--and m.MonitorId=@MonitorId
GROUP BY dp.DepartmentName, f.Number, r.RoomNumber, d.DeviceName, dc.ControlName, m.DateControlOn, d.ImageFile, dc.ControlImage, dc.ChartColor, p1.FullName, 
e.EquipmentName, bc.BeaconName, d.DeviceId, bc.BeaconId, z.ZoneName
) as t
) as t2

--WHERE [id] > (SELECT MAX([id]) - 5 FROM [MyTable])



--SELECT top 20 dp.DepartmentName, r.FloorNumber AS Floor, cast(r.RoomNumber as varchar(20)) AS Room, d.DeviceName, dc.ControlName, dc.ControlImage AS ControlImageFile
----, dr.DeviceData
--, m.DateControlOn AS DateOn, m.DateControlOff AS DateOff, DATEDIFF(minute, m.DateControlOn, m.DateControlOff) AS DateDif
----, DATEDIFF(minute, m.DateControlOff, GETDATE()) AS DateDifNow
--FROM  Lvm_MonitorRecordLog AS m INNER JOIN
--         Lvm_Device AS d ON m.DeviceId = d.DeviceId INNER JOIN
--         Lvm_Room AS r ON d.RoomId = r.RoomId INNER JOIN
--         Lvm_DeviceTypeControl AS dc ON m.ControlId = dc.DeviceTypeControlId INNER JOIN
--         Lvm_DeviceRecord AS dr ON m.DeviceRecordIdOn = dr.DeviceRecordId INNER JOIN
--         Lvm_Department AS dp ON d.DepartmentId = dp.DepartmentId
--WHERE (m.IsClosed = 1) and m.FacilityId=@FacilityId and m.MonitorId=@MonitorId
--ORDER BY m.DateControlOff DESC


--declare @TblTmp Table (DeviceRecordId int, DeviceId int, ControlId int, IsControlOn bit, DeviceData varchar(max), DateCreated datetime)
--declare @Tbl Table (DeviceRecordId int, DeviceId int, ControlId int, IsControlOn bit, DeviceData varchar(max), DateCreated datetime)

---- ControlId is ControlNumber from Lvm_DeviceTypeControl
----INSERT INTO @Tbl (DeviceRecordId, DeviceId, ControlId, IsControlOn, DeviceData,  DateCreated)
----SELECT TOP (40) DeviceRecordId, DeviceId, ControlId, IsControlOn, DeviceData, DateCreated
----FROM  Lvm_DeviceRecord
----WHERE (IsControlOn = 0) AND (IsError=0)  AND (IsProcessed=1) and (FacilityId = @FacilityId) AND (MonitorId = @MonitorId)
----ORDER BY DateCreated DESC

--INSERT INTO @TblTmp (DeviceRecordId, DeviceId, ControlId, IsControlOn, DeviceData,  DateCreated)
--SELECT TOP (30) DeviceRecordId, DeviceId, ControlId, IsControlOn, DeviceData, DateCreated
--FROM  Lvm_DeviceRecord
--WHERE (IsControlOn = 0) AND (IsError=0)  AND (IsProcessed=1) and (FacilityId = @FacilityId) AND (MonitorId = @MonitorId)
--ORDER BY DateCreated DESC

--INSERT INTO @Tbl (DeviceRecordId, DeviceId, ControlId, IsControlOn, DeviceData,  DateCreated)
--SELECT TOP (20) max(DeviceRecordId) DeviceRecordId, DeviceId, ControlId, IsControlOn, DeviceData, MAX(DateCreated) AS DateCreated
--FROM  @TblTmp
--GROUP BY DeviceId, ControlId, IsControlOn, DeviceData
--ORDER BY DateCreated DESC

----select * from @Tbl; return

--delete @TblTmp

----select * from @Tbl
----return

--INSERT INTO @TblTmp (DeviceRecordId, DeviceId, ControlId, IsControlOn, DeviceData,  DateCreated)
--SELECT TOP (30) tOn.DeviceRecordId, tOn.DeviceId, tOn.ControlId, tOn.IsControlOn, tOn.DeviceData, tOn.DateCreated
--FROM  Lvm_DeviceRecord as tOn
--inner join @Tbl as tOff on tOff.DeviceId= tOn.DeviceId and tOff.ControlId= tOn.ControlId
--WHERE (tOn.IsControlOn = 1) AND (tOn.IsError=0)  AND (tOn.IsProcessed=1) and (tOn.FacilityId = @FacilityId) AND (tOn.MonitorId = @MonitorId)
--ORDER BY tOn.DateCreated DESC

--INSERT INTO @Tbl (DeviceRecordId, DeviceId, ControlId, IsControlOn, DeviceData,  DateCreated)
--SELECT TOP (20) max(DeviceRecordId) DeviceRecordId, DeviceId, ControlId, IsControlOn, DeviceData, MAX(DateCreated) AS DateCreated
--FROM  @TblTmp
--GROUP BY DeviceId, ControlId, IsControlOn, DeviceData
--ORDER BY DateCreated DESC

----select * from @Tbl; 
----return

----INSERT INTO @Tbl (DeviceRecordId, DeviceId, ControlId, IsControlOn, DeviceData,  DateCreated)
----SELECT TOP (20) tOn.DeviceRecordId, tOn.DeviceId, tOn.ControlId, tOn.IsControlOn, tOn.DeviceData, MAX(tOn.DateCreated) AS DateCreated
----FROM  Lvm_DeviceRecord as tOn
----inner join @Tbl as tOff on tOff.DeviceId= tOn.DeviceId and tOff.ControlId= tOn.ControlId
----GROUP BY tOn.DeviceRecordId, tOn.DeviceId, tOn.ControlId, tOn.IsControlOn, tOn.DeviceData
----HAVING (tOn.IsControlOn = 1) AND (tOn.IsError=0)  AND (tOn.IsProcessed=1) and (tOn.FacilityId = @FacilityId) AND (tOn.MonitorId = @MonitorId)
----ORDER BY DateCreated DESC

--select distinct cast(r.RoomNumber as varchar(20)) Room, r.FloorNumber [Floor], d.DeviceName, 
--c.ControlName, c.ControlImage ControlImageFile,
--t.DeviceData, t.DateOn, t.DateOff,
--DATEDIFF(minute, t.DateOn, t.DateOff) DateDif, DATEDIFF(minute, t.DateOff, getdate()) DateDifNow
--from
--(
--SELECT TOP (20) tOn.DeviceId, tOn.ControlId, tOn.DeviceData, tOn.DateCreated DateOn, tOff.DateCreated DateOff
--FROM  @Tbl as tOn
--inner join @Tbl as tOff on tOff.DeviceId= tOn.DeviceId and tOff.ControlId= tOn.ControlId
--WHERE (tOn.IsControlOn = 1) and (tOff.IsControlOn = 0)
--) as t
--inner join Lvm_Device as d on t.DeviceId=d.DeviceId
--inner join Lvm_DeviceTypeControl as c on t.ControlId=c.ControlNumber and d.DeviceTypeId = c.DeviceTypeId
--inner join Lvm_Room as r on r.RoomId=d.RoomId
--order by t.DateOff desc

END


--Mat test
--insert into Lvm_MonitorDeviceMap
--SELECT FacilityId, 3 MonitorId, DeviceId, DeviceNumber
--FROM  Lvm_Device
--WHERE (FacilityId = 1)

--truncate table Lvm_MonitorDeviceMap
GO
/****** Object:  StoredProcedure [dbo].[sLvmMonitorHistory]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
 exec sLvmMonitorHistory 1, 3
 exec sLvmMonitorHistory_0 1, 1
*/
ALTER PROCEDURE [dbo].[sLvmMonitorHistory] 
@FacilityId int,
@MonitorId int
AS
BEGIN
	SET NOCOUNT ON;

declare @IsMonMap bit
declare @MonMapTbl table (MonitorDeviceMapId int, FacilityId int, MonitorId int, DeviceId int, DeviceNumber int)
--insert into @MonMapTbl select * from Lvm_MonitorDeviceMap where FacilityId = @FacilityId and MonitorId=@MonitorId

if ((select count(*) from @MonMapTbl)>0) set @IsMonMap=1 else set @IsMonMap=0

select top 20 * from
(
select ROW_NUMBER() OVER (ORDER BY DateOff DESC)  AS Id, *
from
(
SELECT distinct dp.DepartmentName, f.Number AS Floor, cast(r.RoomNumber as varchar(20)) AS Room, d.DeviceName, dc.ControlName, dc.ControlImage AS ControlImageFile
, m.DateControlOn AS DateOn, m.DateControlOff AS DateOff, DATEDIFF(s, m.DateControlOn, m.DateControlOff) AS DateDif, dc.ChartColor, 
STRING_AGG(ISNULL(bd.Number, '') + ISNULL(' (' + p.FullName + ')', ''), ',') AS Bed, 
ISNULL(p1.FullName, '') as PatientName, ISNULL(bc.BeaconName, '') as BeaconName, ISNULL(e.EquipmentName, '') as EquipmentName, ISNULL(z.ZoneName, '') as ZoneName
FROM  Lvm_MonitorRecordLog AS m LEFT OUTER JOIN
	Lvm_Device AS d ON m.DeviceId = d.DeviceId LEFT OUTER JOIN
	Lvm_Floor AS f ON m.FloorId = f.FloorId LEFT OUTER JOIN
	Lvm_Room AS r ON m.RoomId = r.RoomId LEFT OUTER JOIN
	Lvm_Beacon as bc on m.BeaconId = bc.BeaconId INNER JOIN
	Lvm_DeviceTypeControl AS dc ON (d.DeviceTypeId = dc.DeviceTypeId or bc.DeviceTypeId = dc.DeviceTypeId or (select [dbo].fLvmCtrlSystem()) = dc.DeviceTypeId) AND m.ControlId = dc.ControlNumber LEFT OUTER JOIN
	Lvm_DeviceRecord AS dr ON m.DeviceRecordIdOn = dr.DeviceRecordId LEFT OUTER JOIN
	Lvm_BeaconRecord AS br ON m.BeaconRecordIdOn = br.BeaconRecordId LEFT OUTER JOIN
	Lvm_Department AS dp ON m.DepartmentId = dp.DepartmentId LEFT OUTER JOIN
	Lvm_BedLvm_Device as ldb ON d.DeviceId = ldb.Lvm_Device_DeviceId LEFT OUTER JOIN
	Lvm_Bed as bd ON ldb.Lvm_Bed_BedId = bd.BedId LEFT OUTER JOIN
	Lvm_PatientRecordLog AS pr ON bd.BedId = pr.BedId and pr.DatePatientAdmitted >= m.DateControlOn and pr.DatePatientAdmitted <= m.DateControlOff LEFT OUTER JOIN
	Lvm_Patient AS p ON pr.PatientId = p.PatientId LEFT OUTER JOIN
	Lvm_Patient as p1 on bc.PatientId = p1.PatientId LEFT OUTER JOIN
	Lvm_Equipment as e on bc.EquipmentId = e.EquipmentId LEFT OUTER JOIN
	Lvm_RestrictedZone as z on m.RestrictedZoneId = z.RestrictedZoneId
WHERE (m.IsClosed = 1) and m.FacilityId=@FacilityId 
and (((@IsMonMap=1) and exists(select * from @MonMapTbl where DeviceId=m.DeviceId)) 
	or ((@IsMonMap=0) and (m.MonitorId=@MonitorId)))
--and (bd.Number is NULL or p.PatientId is NULL or p.PatientStatusId = 1)
--and m.MonitorId=@MonitorId
GROUP BY dp.DepartmentName, f.Number, r.RoomNumber, d.DeviceName, dc.ControlName, m.DateControlOn, m.DateControlOff, dc.ControlImage, dc.ChartColor, 
p1.FullName, e.EquipmentName, bc.BeaconName, z.ZoneName
) as t
) as t2

--WHERE [id] > (SELECT MAX([id]) - 5 FROM [MyTable])



--SELECT top 20 dp.DepartmentName, r.FloorNumber AS Floor, cast(r.RoomNumber as varchar(20)) AS Room, d.DeviceName, dc.ControlName, dc.ControlImage AS ControlImageFile
----, dr.DeviceData
--, m.DateControlOn AS DateOn, m.DateControlOff AS DateOff, DATEDIFF(minute, m.DateControlOn, m.DateControlOff) AS DateDif
----, DATEDIFF(minute, m.DateControlOff, GETDATE()) AS DateDifNow
--FROM  Lvm_MonitorRecordLog AS m INNER JOIN
--         Lvm_Device AS d ON m.DeviceId = d.DeviceId INNER JOIN
--         Lvm_Room AS r ON d.RoomId = r.RoomId INNER JOIN
--         Lvm_DeviceTypeControl AS dc ON m.ControlId = dc.DeviceTypeControlId INNER JOIN
--         Lvm_DeviceRecord AS dr ON m.DeviceRecordIdOn = dr.DeviceRecordId INNER JOIN
--         Lvm_Department AS dp ON d.DepartmentId = dp.DepartmentId
--WHERE (m.IsClosed = 1) and m.FacilityId=@FacilityId and m.MonitorId=@MonitorId
--ORDER BY m.DateControlOff DESC


--declare @TblTmp Table (DeviceRecordId int, DeviceId int, ControlId int, IsControlOn bit, DeviceData varchar(max), DateCreated datetime)
--declare @Tbl Table (DeviceRecordId int, DeviceId int, ControlId int, IsControlOn bit, DeviceData varchar(max), DateCreated datetime)

---- ControlId is ControlNumber from Lvm_DeviceTypeControl
----INSERT INTO @Tbl (DeviceRecordId, DeviceId, ControlId, IsControlOn, DeviceData,  DateCreated)
----SELECT TOP (40) DeviceRecordId, DeviceId, ControlId, IsControlOn, DeviceData, DateCreated
----FROM  Lvm_DeviceRecord
----WHERE (IsControlOn = 0) AND (IsError=0)  AND (IsProcessed=1) and (FacilityId = @FacilityId) AND (MonitorId = @MonitorId)
----ORDER BY DateCreated DESC

--INSERT INTO @TblTmp (DeviceRecordId, DeviceId, ControlId, IsControlOn, DeviceData,  DateCreated)
--SELECT TOP (30) DeviceRecordId, DeviceId, ControlId, IsControlOn, DeviceData, DateCreated
--FROM  Lvm_DeviceRecord
--WHERE (IsControlOn = 0) AND (IsError=0)  AND (IsProcessed=1) and (FacilityId = @FacilityId) AND (MonitorId = @MonitorId)
--ORDER BY DateCreated DESC

--INSERT INTO @Tbl (DeviceRecordId, DeviceId, ControlId, IsControlOn, DeviceData,  DateCreated)
--SELECT TOP (20) max(DeviceRecordId) DeviceRecordId, DeviceId, ControlId, IsControlOn, DeviceData, MAX(DateCreated) AS DateCreated
--FROM  @TblTmp
--GROUP BY DeviceId, ControlId, IsControlOn, DeviceData
--ORDER BY DateCreated DESC

----select * from @Tbl; return

--delete @TblTmp

----select * from @Tbl
----return

--INSERT INTO @TblTmp (DeviceRecordId, DeviceId, ControlId, IsControlOn, DeviceData,  DateCreated)
--SELECT TOP (30) tOn.DeviceRecordId, tOn.DeviceId, tOn.ControlId, tOn.IsControlOn, tOn.DeviceData, tOn.DateCreated
--FROM  Lvm_DeviceRecord as tOn
--inner join @Tbl as tOff on tOff.DeviceId= tOn.DeviceId and tOff.ControlId= tOn.ControlId
--WHERE (tOn.IsControlOn = 1) AND (tOn.IsError=0)  AND (tOn.IsProcessed=1) and (tOn.FacilityId = @FacilityId) AND (tOn.MonitorId = @MonitorId)
--ORDER BY tOn.DateCreated DESC

--INSERT INTO @Tbl (DeviceRecordId, DeviceId, ControlId, IsControlOn, DeviceData,  DateCreated)
--SELECT TOP (20) max(DeviceRecordId) DeviceRecordId, DeviceId, ControlId, IsControlOn, DeviceData, MAX(DateCreated) AS DateCreated
--FROM  @TblTmp
--GROUP BY DeviceId, ControlId, IsControlOn, DeviceData
--ORDER BY DateCreated DESC

----select * from @Tbl; 
----return

----INSERT INTO @Tbl (DeviceRecordId, DeviceId, ControlId, IsControlOn, DeviceData,  DateCreated)
----SELECT TOP (20) tOn.DeviceRecordId, tOn.DeviceId, tOn.ControlId, tOn.IsControlOn, tOn.DeviceData, MAX(tOn.DateCreated) AS DateCreated
----FROM  Lvm_DeviceRecord as tOn
----inner join @Tbl as tOff on tOff.DeviceId= tOn.DeviceId and tOff.ControlId= tOn.ControlId
----GROUP BY tOn.DeviceRecordId, tOn.DeviceId, tOn.ControlId, tOn.IsControlOn, tOn.DeviceData
----HAVING (tOn.IsControlOn = 1) AND (tOn.IsError=0)  AND (tOn.IsProcessed=1) and (tOn.FacilityId = @FacilityId) AND (tOn.MonitorId = @MonitorId)
----ORDER BY DateCreated DESC

--select distinct cast(r.RoomNumber as varchar(20)) Room, r.FloorNumber [Floor], d.DeviceName, 
--c.ControlName, c.ControlImage ControlImageFile,
--t.DeviceData, t.DateOn, t.DateOff,
--DATEDIFF(minute, t.DateOn, t.DateOff) DateDif, DATEDIFF(minute, t.DateOff, getdate()) DateDifNow
--from
--(
--SELECT TOP (20) tOn.DeviceId, tOn.ControlId, tOn.DeviceData, tOn.DateCreated DateOn, tOff.DateCreated DateOff
--FROM  @Tbl as tOn
--inner join @Tbl as tOff on tOff.DeviceId= tOn.DeviceId and tOff.ControlId= tOn.ControlId
--WHERE (tOn.IsControlOn = 1) and (tOff.IsControlOn = 0)
--) as t
--inner join Lvm_Device as d on t.DeviceId=d.DeviceId
--inner join Lvm_DeviceTypeControl as c on t.ControlId=c.ControlNumber and d.DeviceTypeId = c.DeviceTypeId
--inner join Lvm_Room as r on r.RoomId=d.RoomId
--order by t.DateOff desc

END


--Mat test
--insert into Lvm_MonitorDeviceMap
--SELECT FacilityId, 3 MonitorId, DeviceId, DeviceNumber
--FROM  Lvm_Device
--WHERE (FacilityId = 1)

--truncate table Lvm_MonitorDeviceMap
GO

/****** Object:  StoredProcedure [dbo].[sLvmMonitorHistoryDevice]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
 exec sLvmMonitorHistory 1, 3
 exec sLvmMonitorHistory_0 1, 1
*/
ALTER PROCEDURE [dbo].[sLvmMonitorHistoryDevice] 
@FacilityId int,
@MonitorId int
AS
BEGIN
	SET NOCOUNT ON;

declare @IsMonMap bit
declare @MonMapTbl table (MonitorDeviceMapId int, FacilityId int, MonitorId int, DeviceId int, DeviceNumber int)
--insert into @MonMapTbl select * from Lvm_MonitorDeviceMap where FacilityId = @FacilityId and MonitorId=@MonitorId

if ((select count(*) from @MonMapTbl)>0) set @IsMonMap=1 else set @IsMonMap=0

select top 20 * from
(
select ROW_NUMBER() OVER (ORDER BY DateOff DESC)  AS Id, *
from
(
SELECT distinct dp.DepartmentName, f.Number AS Floor, cast(r.RoomNumber as varchar(20)) AS Room, d.DeviceName, dc.ControlName, dc.ControlImage AS ControlImageFile
, m.DateControlOn AS DateOn, m.DateControlOff as DateOff, DATEDIFF(s, m.DateControlOn, m.DateControlOff) AS DateDif, dc.ChartColor as ControlBackgroundColor
, d.ImageFile as DeviceImage, @FacilityId as FacilityId, STRING_AGG(ISNULL(bd.Number + ISNULL(p.FullName ,''), ''), ',') AS Bed
, ISNULL(p1.FullName, '') as PatientName, ISNULL(bc.BeaconName, '') as BeaconName, ISNULL(e.EquipmentName, '') as EquipmentName, ISNULL(z.ZoneName, '') as ZoneName
FROM  Lvm_MonitorRecordLog AS m LEFT OUTER JOIN
	Lvm_Device AS d ON m.DeviceId = d.DeviceId LEFT OUTER JOIN
	Lvm_Beacon as bc on m.BeaconId = bc.BeaconId LEFT OUTER JOIN
	Lvm_Floor AS f ON m.FloorId = f.FloorId LEFT OUTER JOIN
	Lvm_Room AS r ON m.RoomId = r.RoomId INNER JOIN
	Lvm_DeviceTypeControl AS dc ON (d.DeviceTypeId = dc.DeviceTypeId or bc.DeviceTypeId = dc.DeviceTypeId or (select [dbo].fLvmCtrlSystem()) = dc.DeviceTypeId) AND m.ControlId = dc.ControlNumber LEFT OUTER JOIN
	Lvm_DeviceRecord AS dr ON m.DeviceRecordIdOn = dr.DeviceRecordId LEFT OUTER JOIN
	Lvm_BeaconRecord AS br ON m.BeaconRecordIdOn = br.BeaconRecordId LEFT OUTER JOIN
	Lvm_Department AS dp ON m.DepartmentId = dp.DepartmentId LEFT OUTER JOIN
	Lvm_BedLvm_Device as ldb ON d.DeviceId = ldb.Lvm_Device_DeviceId LEFT OUTER JOIN
	Lvm_Bed as bd ON ldb.Lvm_Bed_BedId = bd.BedId LEFT OUTER JOIN
	Lvm_PatientRecordLog AS pr ON bd.BedId = pr.BedId and pr.DatePatientAdmitted >= m.DateControlOn and pr.DatePatientAdmitted <= m.DateControlOff LEFT OUTER JOIN
	Lvm_Patient AS p ON pr.PatientId = p.PatientId LEFT OUTER JOIN
	Lvm_Patient as p1 on bc.PatientId = p1.PatientId LEFT OUTER JOIN
	Lvm_Equipment as e on bc.EquipmentId = e.EquipmentId LEFT OUTER JOIN
	Lvm_RestrictedZone as z on m.RestrictedZoneId = z.RestrictedZoneId
WHERE (m.IsClosed = 1) and m.FacilityId=@FacilityId
and (((@IsMonMap=1) and exists(select * from @MonMapTbl where DeviceId=m.DeviceId)) 
or ((@IsMonMap=0) and (m.MonitorId=@MonitorId)))
--and m.MonitorId=@MonitorId
GROUP BY dp.DepartmentName, f.Number, r.RoomNumber, d.DeviceName, bc.BeaconName, p1.FullName, e.EquipmentName, dc.ControlName, m.DateControlOn, m.DateControlOff, 
dc.ControlImage, d.ImageFile, dc.ChartColor, z.ZoneName
) as t
) as t2

--WHERE [id] > (SELECT MAX([id]) - 5 FROM [MyTable])



--SELECT top 20 dp.DepartmentName, r.FloorNumber AS Floor, cast(r.RoomNumber as varchar(20)) AS Room, d.DeviceName, dc.ControlName, dc.ControlImage AS ControlImageFile
----, dr.DeviceData
--, m.DateControlOn AS DateOn, m.DateControlOff AS DateOff, DATEDIFF(minute, m.DateControlOn, m.DateControlOff) AS DateDif
----, DATEDIFF(minute, m.DateControlOff, GETDATE()) AS DateDifNow
--FROM  Lvm_MonitorRecordLog AS m INNER JOIN
--         Lvm_Device AS d ON m.DeviceId = d.DeviceId INNER JOIN
--         Lvm_Room AS r ON d.RoomId = r.RoomId INNER JOIN
--         Lvm_DeviceTypeControl AS dc ON m.ControlId = dc.DeviceTypeControlId INNER JOIN
--         Lvm_DeviceRecord AS dr ON m.DeviceRecordIdOn = dr.DeviceRecordId INNER JOIN
--         Lvm_Department AS dp ON d.DepartmentId = dp.DepartmentId
--WHERE (m.IsClosed = 1) and m.FacilityId=@FacilityId and m.MonitorId=@MonitorId
--ORDER BY m.DateControlOff DESC


--declare @TblTmp Table (DeviceRecordId int, DeviceId int, ControlId int, IsControlOn bit, DeviceData varchar(max), DateCreated datetime)
--declare @Tbl Table (DeviceRecordId int, DeviceId int, ControlId int, IsControlOn bit, DeviceData varchar(max), DateCreated datetime)

---- ControlId is ControlNumber from Lvm_DeviceTypeControl
----INSERT INTO @Tbl (DeviceRecordId, DeviceId, ControlId, IsControlOn, DeviceData,  DateCreated)
----SELECT TOP (40) DeviceRecordId, DeviceId, ControlId, IsControlOn, DeviceData, DateCreated
----FROM  Lvm_DeviceRecord
----WHERE (IsControlOn = 0) AND (IsError=0)  AND (IsProcessed=1) and (FacilityId = @FacilityId) AND (MonitorId = @MonitorId)
----ORDER BY DateCreated DESC

--INSERT INTO @TblTmp (DeviceRecordId, DeviceId, ControlId, IsControlOn, DeviceData,  DateCreated)
--SELECT TOP (30) DeviceRecordId, DeviceId, ControlId, IsControlOn, DeviceData, DateCreated
--FROM  Lvm_DeviceRecord
--WHERE (IsControlOn = 0) AND (IsError=0)  AND (IsProcessed=1) and (FacilityId = @FacilityId) AND (MonitorId = @MonitorId)
--ORDER BY DateCreated DESC

--INSERT INTO @Tbl (DeviceRecordId, DeviceId, ControlId, IsControlOn, DeviceData,  DateCreated)
--SELECT TOP (20) max(DeviceRecordId) DeviceRecordId, DeviceId, ControlId, IsControlOn, DeviceData, MAX(DateCreated) AS DateCreated
--FROM  @TblTmp
--GROUP BY DeviceId, ControlId, IsControlOn, DeviceData
--ORDER BY DateCreated DESC

----select * from @Tbl; return

--delete @TblTmp

----select * from @Tbl
----return

--INSERT INTO @TblTmp (DeviceRecordId, DeviceId, ControlId, IsControlOn, DeviceData,  DateCreated)
--SELECT TOP (30) tOn.DeviceRecordId, tOn.DeviceId, tOn.ControlId, tOn.IsControlOn, tOn.DeviceData, tOn.DateCreated
--FROM  Lvm_DeviceRecord as tOn
--inner join @Tbl as tOff on tOff.DeviceId= tOn.DeviceId and tOff.ControlId= tOn.ControlId
--WHERE (tOn.IsControlOn = 1) AND (tOn.IsError=0)  AND (tOn.IsProcessed=1) and (tOn.FacilityId = @FacilityId) AND (tOn.MonitorId = @MonitorId)
--ORDER BY tOn.DateCreated DESC

--INSERT INTO @Tbl (DeviceRecordId, DeviceId, ControlId, IsControlOn, DeviceData,  DateCreated)
--SELECT TOP (20) max(DeviceRecordId) DeviceRecordId, DeviceId, ControlId, IsControlOn, DeviceData, MAX(DateCreated) AS DateCreated
--FROM  @TblTmp
--GROUP BY DeviceId, ControlId, IsControlOn, DeviceData
--ORDER BY DateCreated DESC

----select * from @Tbl; 
----return

----INSERT INTO @Tbl (DeviceRecordId, DeviceId, ControlId, IsControlOn, DeviceData,  DateCreated)
----SELECT TOP (20) tOn.DeviceRecordId, tOn.DeviceId, tOn.ControlId, tOn.IsControlOn, tOn.DeviceData, MAX(tOn.DateCreated) AS DateCreated
----FROM  Lvm_DeviceRecord as tOn
----inner join @Tbl as tOff on tOff.DeviceId= tOn.DeviceId and tOff.ControlId= tOn.ControlId
----GROUP BY tOn.DeviceRecordId, tOn.DeviceId, tOn.ControlId, tOn.IsControlOn, tOn.DeviceData
----HAVING (tOn.IsControlOn = 1) AND (tOn.IsError=0)  AND (tOn.IsProcessed=1) and (tOn.FacilityId = @FacilityId) AND (tOn.MonitorId = @MonitorId)
----ORDER BY DateCreated DESC

--select distinct cast(r.RoomNumber as varchar(20)) Room, r.FloorNumber [Floor], d.DeviceName, 
--c.ControlName, c.ControlImage ControlImageFile,
--t.DeviceData, t.DateOn, t.DateOff,
--DATEDIFF(minute, t.DateOn, t.DateOff) DateDif, DATEDIFF(minute, t.DateOff, getdate()) DateDifNow
--from
--(
--SELECT TOP (20) tOn.DeviceId, tOn.ControlId, tOn.DeviceData, tOn.DateCreated DateOn, tOff.DateCreated DateOff
--FROM  @Tbl as tOn
--inner join @Tbl as tOff on tOff.DeviceId= tOn.DeviceId and tOff.ControlId= tOn.ControlId
--WHERE (tOn.IsControlOn = 1) and (tOff.IsControlOn = 0)
--) as t
--inner join Lvm_Device as d on t.DeviceId=d.DeviceId
--inner join Lvm_DeviceTypeControl as c on t.ControlId=c.ControlNumber and d.DeviceTypeId = c.DeviceTypeId
--inner join Lvm_Room as r on r.RoomId=d.RoomId
--order by t.DateOff desc

END


--Mat test
--insert into Lvm_MonitorDeviceMap
--SELECT FacilityId, 3 MonitorId, DeviceId, DeviceNumber
--FROM  Lvm_Device
--WHERE (FacilityId = 1)

--truncate table Lvm_MonitorDeviceMap
GO
/****** Object:  StoredProcedure [dbo].[sLvmMonitorTemplateCss]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- sLvmMonitorTemplateCss 1, 1
ALTER PROCEDURE [dbo].[sLvmMonitorTemplateCss] 
@FacilityId int,
@MonitorId int
AS
BEGIN
	SET NOCOUNT ON;
SELECT distinct Lvm_Template.TemplateName + '.css' TemplateCss
FROM  Lvm_MonitorRecord INNER JOIN
         Lvm_Template ON Lvm_MonitorRecord.TemplateId = Lvm_Template.TemplateId
WHERE (Lvm_MonitorRecord.FacilityId = @FacilityId) AND (Lvm_MonitorRecord.MonitorId = @MonitorId)

END
GO
/****** Object:  StoredProcedure [dbo].[sLvmRepFacilityDevCalls]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- sLvmRepFacilityDevCalls 1, 1, '2017-01-01', '2018-03-22'
ALTER PROCEDURE [dbo].[sLvmRepFacilityDevCalls]
@FacilityId int,
@DepartmentId int,
@FloorId int,
@DateFrom datetime,
@DateTo datetime
AS
BEGIN
	SET NOCOUNT ON;

select ROW_NUMBER() OVER (ORDER BY CallCount DESC)  AS Id, *
from
(
SELECT dp.DepartmentName, f.Number as FloorNumber, r.RoomNumber, d.DeviceName, COUNT(*) AS CallCount
FROM  Lvm_MonitorRecordLog AS ml INNER JOIN
         Lvm_Device AS d ON ml.DeviceId = d.DeviceId INNER JOIN
		 Lvm_Floor as f on d.FloorId = f.FloorId LEFT OUTER JOIN
         Lvm_Room AS r ON d.RoomId = r.RoomId LEFT OUTER JOIN
         Lvm_Department AS dp ON r.DepartmentId = dp.DepartmentId
WHERE (ml.FacilityId = @FacilityId) 
and (@FloorId = 0 or @FloorId = f.FloorId)
AND (((@DepartmentId = 0 or @DepartmentId is null) and (dp.DepartmentId is null)) OR (dp.DepartmentId = @DepartmentId))
AND (ml.DateControlOn BETWEEN @DateFrom AND @DateTo) 
GROUP BY dp.DepartmentName, f.Number, r.RoomNumber, d.DeviceName
--ORDER BY CallCount DESC
) as t
END
GO
/****** Object:  StoredProcedure [dbo].[sLvmRepFacilityDevResponseAvg]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- sLvmRepFacilityDevResponseAvg 1, 1, '2017-01-01', '2018-03-22'
ALTER PROCEDURE [dbo].[sLvmRepFacilityDevResponseAvg]
@FacilityId int,
@DepartmentId int,
@FloorId int,
@DateFrom datetime,
@DateTo datetime
AS
BEGIN
	SET NOCOUNT ON;
	if (@DateTo = (CONVERT(date, @DateTo))) set @DateTo=DATEADD(d, 1, @DateTo)

select ROW_NUMBER() OVER (ORDER BY ResponseTimeAvg DESC)  AS Id, *
from
(
SELECT dp.DepartmentName Department, f.Number [Floor], r.RoomNumber Room, d.DeviceName Device, COUNT(*) AS CallCount , AVG(DATEDIFF(mi, ml.DateControlOn, ml.DateControlOff)) AS ResponseTimeAvg 
FROM  Lvm_MonitorRecordLog AS ml INNER JOIN
         Lvm_Device AS d ON ml.DeviceId = d.DeviceId INNER JOIN
		 Lvm_Floor as f on d.FloorId = f.FloorId LEFT OUTER JOIN
         Lvm_Room AS r ON d.RoomId = r.RoomId LEFT OUTER JOIN
         Lvm_Department AS dp ON r.DepartmentId = dp.DepartmentId
WHERE (ml.IsControlOn = 0) AND (ml.FacilityId = @FacilityId) 
and (@FloorId = 0 or @FloorId = f.FloorId)
AND (((@DepartmentId = 0 or @DepartmentId is null) and (dp.DepartmentId is null)) or (dp.DepartmentId = @DepartmentId))
		 AND (ml.DateControlOn BETWEEN @DateFrom AND @DateTo)
GROUP BY dp.DepartmentName, f.Number, r.RoomNumber, d.DeviceName
) as t

END
GO
/****** Object:  StoredProcedure [dbo].[sLvmRepFacilityMonitorCalls]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- sLvmRepFacilityMonitorCalls 1, '2017-01-01', '2018-03-22'
ALTER PROCEDURE [dbo].[sLvmRepFacilityMonitorCalls]
@FacilityId int,
@DateFrom datetime,
@DateTo datetime
AS
BEGIN
	SET NOCOUNT ON;

select ROW_NUMBER() OVER (ORDER BY ResponseTimeAvg DESC)  AS Id, *
from
(
SELECT fm.MonitorName, AVG(DATEDIFF(mi, ml.DateControlOn, ml.DateControlOff)) AS ResponseTimeAvg, COUNT(*) AS CallCount
FROM  Lvm_FacilityMonitor AS fm INNER JOIN
         Lvm_MonitorRecordLog AS ml ON fm.MonitorId = ml.MonitorId
WHERE (fm.FacilityId = @FacilityId) AND (ml.DateControlOn BETWEEN @DateFrom AND @DateTo)
GROUP BY fm.MonitorName
--ORDER BY fm.MonitorName
) as t

END
GO
/****** Object:  StoredProcedure [dbo].[sLvmUserFacility]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
 exec sLvmUserFacility '', 1
*/
ALTER PROCEDURE [dbo].[sLvmUserFacility] 
@UserId nvarchar(128),
@SuperAdmin bit
AS
BEGIN
	SET NOCOUNT ON;
if (@SuperAdmin=1)

SELECT FacilityId, FacilityName
FROM  Lvm_Facility 

else

SELECT f.FacilityId, f.FacilityName
FROM  Lvm_FacilityUser AS u INNER JOIN
         Lvm_Facility AS f ON u.FacilityId = f.FacilityId
WHERE (u.UserId = @UserId)

END
GO
/****** Object:  StoredProcedure [dbo].[Util_CascadingDataViewer]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Util_CascadingDataViewer 'LvMonitor'
ALTER proc [dbo].[Util_CascadingDataViewer]
(
	@pDatabaseName		sysname
,	@pSchemaName		sysname
,	@pTableName			sysname
,	@pFilterCols		nvarchar(max)		--comma delimited list of columns on which to apply filter
,	@pFilterValues		nvarchar(max)		--comma delimited list of values to filter on
,	@pNumberOfRows		int				= 0 OUTPUT
,	@pShowData			bit				= 0 --display data
,	@pPrintSQL			bit				= 0 --Print dynamic SQL or not
,	@pDebug				bit				= 0 --Output data at various points for debugging purposes
,	@pDependantLevels	smallint		= -1
)
as
BEGIN
	SET NOCOUNT ON;
	SET	@pNumberOfRows = 0;
	DECLARE	@vColumnsAndValues	TABLE
	(
		column_ordinal		tinyint not null primary key
	,	column_name			sysname not null unique nonclustered
	,	column_value		nvarchar(max)
	,	column_type			sysname	null
	,	column_precision	tinyint null
	,	column_scale		tinyint null
	);
	DECLARE	@vSQL				NVARCHAR(MAX)
	,		@vSQL2				NVARCHAR(MAX)
	,		@vParmDefinition	NVARCHAR(MAX)
	,		@vNumberOfRows		INT
	,		@raiserrormsg NVARCHAR(2000);
	DECLARE @LEN INT;	
	DECLARE	@ErrorNumber		INT
	,		@ErrorMessage		nvarchar(2048)
	,		@ErrorState			INT
	,		@ErrorSeverity		INT
	,		@vNumSelfRefKeys	INT;	
	DECLARE	@vDepends	TABLE
	(
			TableNum						smallint
	,		Occurrence						smallint
	,		child_Schema					sysname
	,		child_Table						sysname
	,		parent_Schema					sysname
	,		parent_Table					sysname
	,		DependLevel						smallint
	,		fk_name							sysname
	,		uk_name							sysname
	,		HasNoDescendantTables			bit
	,		NumOccurencesOfDependantTable	int
	);
	DECLARE	@vSelfRefKeys	TABLE
	(
		ParentUniqueKey		sysname
	,	ChildForeignKey		sysname
	,	ParentColumn		sysname
	,	ChildColumn			sysname
	);
	DECLARE	@vPrimaryAndUniqueKeys	TABLE (
			[IndexName]		sysname
	,		[IsPrimaryKey]	bit
	,		[ColumnName]	sysname
	,		[key_ordinal]	int
	);
	DECLARE	@vIndexCols	TABLE
	(
		fk_name			sysname
	,	child_schema	sysname
	,	child_table		sysname
	,	parent_schema	sysname
	,	parent_table	sysname
	,	child_column	sysname
	,	parent_column	sysname
	);
	DECLARE	@vColumns	TABLE (
		[ColumnName]		sysname
	,	[ColumnType]		sysname
	)
	DECLARE	@vTableNum						smallint
	,		@vOccurrence					smallint
	,		@vHasNoDescendantTables			bit
	,		@vNumOccurencesOfDependantTable	int
	,		@vCurrentChildSchema			sysname
	,		@vCurrentChildTable				sysname
	,		@vCurrentParentSchema			sysname
	,		@vCurrentParentTable			sysname
	,		@vCurrentFKName					sysname
	,		@vCurrentUKName					sysname
	,		@vCurrentChildColumn			sysname
	,		@vCurrentParentColumn			sysname
	,		@vFirstColumnIteration			bit
	,		@vColumnOrdinal					tinyint
	,		@vColumnName					sysname
	,		@vColumnType					sysname
	,		@vColumnPrecision				tinyint
	,		@vColumnScale					tinyint
	,		@vColumnValue					nvarchar(max);
	SET		@LEN=LEN(@pFilterCols)+1;
	
	--Remove any apostrophes from @pFilterValues
	SET		@pFilterValues = REPLACE(CAST(@pFilterValues AS NVARCHAR(MAX)),'''','''''');

	/****Check input values****/
	--Check object names are not zero-length
	IF (LEN(@pDatabaseName) = 0 OR LEN(@pSchemaName) = 0 OR LEN(@pTableName) = 0)
	BEGIN
		SET	@raiserrormsg = 'Object names cannot be zero length';
		RAISERROR(@raiserrormsg,16,1);
		RETURN;
	END
	--Check database exists
	IF NOT EXISTS (SELECT	[database_id]	FROM	sys.databases d	WHERE	d.[name] = @pdatabaseName)
	BEGIN
		SET @raiserrormsg = 'Supplied database @pDatabaseName name does not exist';
		SET	@raiserrormsg = REPLACE(@raiserrormsg,'@pDatabaseName',@pDatabaseName);
		RAISERROR(@raiserrormsg,16,1);
		RETURN;
	END
	--Check executer can create tables (because he/she needs to be able to in order to exec this sproc)
	BEGIN TRY 
		SET	@vSQL = N'
		create table [@pDatabaseName]..[t]([i] int);
		drop table [@pDatabaseName]..[t];
		';
		SET		@vSQL = REPLACE(@vSQL,'@pDatabaseName',@pDatabaseName);
		EXEC sp_executesql @vSQL;
	END TRY
	BEGIN CATCH
		SET @raiserrormsg = ERROR_MESSAGE();
		RAISERROR(@raiserrormsg,16,1);
		RETURN;
	END CATCH

	--Check at least one column name has been supplied
	IF	(REPLACE(@pFilterCols,' ','') = '')
	BEGIN
		RAISERROR('You must specify at least value one for @pFilterCols',16,1);
		RETURN;
	END
	--Check at least one column value has been supplied
	IF	@pFilterValues = ''
	BEGIN
		RAISERROR('You must specify a value for @pFilterValues',16,1);
		RETURN;
	END
	--Check specified table is valid
	SET	@vSQL = 'SELECT * into #t FROM @pDatabaseName.sys.tables where name = ''@pTableName'' and OBJECT_SCHEMA_NAME(object_id,DB_ID(''@pDatabasename'')) = ''@pSchemaName'';'
	SET	@vSQL = REPLACE(@vSQL, '@pDatabaseName',	@pdatabaseName);
	SET	@vSQL = REPLACE(@vSQL, '@pTableName',		@pTableName);
	SET	@vSQL = REPLACE(@vSQL, '@pSchemaName',		@pSchemaName);
	IF	@pPrintSQL = 1
		PRINT @vSQL;
	EXEC	sp_executesql @vSQL;
	IF	@@ROWCOUNT = 0
	BEGIN
		SET @raiserrormsg = @pDatabaseName + '.' + @pSchemaName + '.' + @pTableName + ' is not a valid table';
		RAISERROR(@raiserrormsg,16,1);
		RETURN;
	END
	--Check number of columns equals number of column values
	DECLARE	@vCommaStartPos					TINYINT = 0
	,		@vNumberOfColumnsIn_pFilterCols	TINYINT = 0
	,		@vNumberOfValuesIn_pFilterValues	TINYINT = 0;
	WHILE	( CHARINDEX(',',@pFilterCols,@vCommaStartPos + 1) > 0 )
	BEGIN
		SET	@vNumberOfColumnsIn_pFilterCols = @vNumberOfColumnsIn_pFilterCols + 1;
		SET	@vCommaStartPos = CHARINDEX(',',@pFilterCols,@vCommaStartPos + 1);
	END
	SET		@vCommaStartPos	= 0;
	WHILE	( CHARINDEX(',',@pFilterValues,@vCommaStartPos + 1) > 0 )
	BEGIN
		SET	@vNumberOfValuesIn_pFilterValues = @vNumberOfValuesIn_pFilterValues + 1;
		SET	@vCommaStartPos = CHARINDEX(',',@pFilterValues,@vCommaStartPos + 1);
	END
	IF	(@vNumberOfColumnsIn_pFilterCols != @vNumberOfValuesIn_pFilterValues)
	BEGIN
		RAISERROR('There must be the same count of values in @pFilterCols as there are columns in @pFilterValues',16,1);
		RETURN;
	END

	/***First things first ... convert list of columns & list of values into a table we can query over because we will need them later at numerous points ***/
	--Get list of specified columns first
	BEGIN TRY
			;With a AS
			( 
				SELECT	cast(1 as int) AS nStart, 
						cast(isNull(NULLIF(CHARINDEX(',',@pFilterCols,1),0),@LEN) as int) AS nEnd,
						RTRIM(LTRIM(SUBSTRING(@pFilterCols,1,isNull(NULLIF(CHARINDEX(',',@pFilterCols,1),0),@LEN)-1))) AS VALUE
				UNION All
				SELECT	cast(nEnd+1 as int), 
						cast(isNull(NULLIF(CHARINDEX(',',@pFilterCols,nEnd+1),0),@LEN) as int),
						RTRIM(LTRIM(SUBSTRING(@pFilterCols,nEnd+1,isNull(NULLIF(CHARINDEX(',',@pFilterCols,nEnd+1),0),@LEN)-nEnd-1)))
				FROM a
				WHERE nEnd<@LEN
			)
			INSERT	INTO @vColumnsAndValues (column_ordinal,column_name)
			SELECT Row_Number() OVER (ORDER BY nStart) as column_ordinal,
			NULLIF(VALUE,'') as column_name
			FROM a;
			IF	(@pDebug = 1)
			BEGIN
				SELECT	'@vColumnsAndValues' AS TableName,v.column_name,v.column_ordinal,v.column_type,v.column_value,v.column_precision,v.column_scale
				FROM	@vColumnsAndValues v;
			END
	END TRY
	BEGIN CATCH
			SET	@ErrorMessage	= ERROR_MESSAGE();
			SET	@ErrorNumber	= ERROR_NUMBER();
			SET	@ErrorSeverity	= ERROR_SEVERITY();
			SET	@ErrorState		= ERROR_STATE();
			IF (@ErrorNumber = 2627)
			BEGIN
				PRINT 'Cannot have repeated column names';
				RETURN;
			END
			ELSE
			BEGIN
				--rethrow
				RAISERROR(@ErrorMessage,@ErrorSeverity,@ErrorState);
				RETURN;
			END
	END CATCH

	--...followed by list of specified values
	SET		@LEN=LEN(@pFilterValues)+1;
	;With a AS
	( 
		SELECT	cast(1 as int) AS nStart, 
				cast(isNull(NULLIF(CHARINDEX(',',@pFilterValues,1),0),@LEN) as int) AS nEnd,
				RTRIM(LTRIM(SUBSTRING(@pFilterValues,1,isNull(NULLIF(CHARINDEX(',',@pFilterValues,1),0),@LEN)-1))) AS VALUE
		UNION All
		SELECT	cast(nEnd+1 as int), 
				cast(isNull(NULLIF(CHARINDEX(',',@pFilterValues,nEnd+1),0),@LEN) as int),
				RTRIM(LTRIM(SUBSTRING(@pFilterValues,nEnd+1,isNull(NULLIF(CHARINDEX(',',@pFilterValues,nEnd+1),0),@LEN)-nEnd-1)))
		FROM a
		WHERE nEnd<@LEN
	)
	MERGE	INTO @vColumnsAndValues tgt
	USING	(
			SELECT Row_Number() OVER (ORDER BY nStart) as column_ordinal,
			NULLIF(VALUE,'') as column_value
			FROM a
			) src
	ON		tgt.column_ordinal = src.column_ordinal
	WHEN	MATCHED THEN
			UPDATE
			SET		tgt.column_value = src.column_value;
	IF	(@pDebug = 1)
	BEGIN
		SELECT	'@vColumnsAndValues' AS TableName,v.column_name,v.column_ordinal,v.column_type,v.column_value,v.column_precision,v.column_scale
		FROM	@vColumnsAndValues v;
	END
	
	--Now get all the necessary type information
	IF EXISTS (SELECT * FROM tempdb.sys.tables where name = 'column_metadataXW64W' and SCHEMA_NAME(schema_id) = 'dbo')
			DROP TABLE tempdb.dbo.column_metadataXW64W;
	SET	@vSQL = N'
SELECT	q.column_name
,		CASE	WHEN	q.is_user_defined = 0 THEN q.column_type
				ELSE	N''['' + q.column_type_schema + N''].['' + q.column_type + N'']''
		END		AS column_type
,		q.column_precision
,		q.column_scale
INTO	tempdb.dbo.column_metadataXW64W --Just some arbitrary name that will never be used elsewhere.
FROM	(
		select	c.name as column_name,SCHEMA_NAME(t.schema_id) as column_type_schema,t.name as column_type,c.precision as column_precision,c.scale as column_scale,t.is_user_defined
		from	[@pDatabaseName].sys.columns c
		inner	join [@pDatabaseName].sys.types t --need to join to sys.types because TYPE_NAME does not work across DBs. Also we need to know is_user_defined.
		on		c.user_type_id = t.user_type_id
		where	OBJECT_NAME(c.object_id,DB_ID(''@pDatabaseName''))		=	''@pTableName''
		and		OBJECT_SCHEMA_NAME(c.object_id,DB_ID(''@pDatabaseName''))	=	''@pSchemaName''
		)q
--select	name as column_name, TYPE_NAME(user_type_id) as column_type,precision as column_precision,scale as column_scale
--into	tempdb.dbo.column_metadataXW64W --Just some arbitrary name that will never be used elsewhere.
--from	@pDatabaseName.sys.columns
--where	OBJECT_NAME(object_id,DB_ID(''@pDatabaseName''))		=	''@pTableName''
--and		OBJECT_SCHEMA_NAME(object_id,DB_ID(''@pDatabaseName''))	=	''@pSchemaName''
	';
	SET	@vSQL = REPLACE(@vSQL, '@pDatabaseName',	@pDatabaseName);
	SET	@vSQL = REPLACE(@vSQL, '@pSchemaName',		@pSchemaName);
	SET	@vSQL = REPLACE(@vSQL, '@pTableName',		@pTableName);
	IF	@pPrintSQL = 1
		PRINT @vSQL;
	EXECUTE	sp_executesql @vSQL;

	MERGE	INTO @vColumnsAndValues tgt
	USING	tempdb.dbo.column_metadataXW64W src
	ON		tgt.column_name = src.column_name
	WHEN	MATCHED THEN
			UPDATE
			SET		tgt.column_type			= src.column_type
			,		tgt.column_precision	= src.column_precision
			,		tgt.column_scale		= src.column_scale
			;
	drop table tempdb.dbo.column_metadataXW64W;
	/***End getting list of columns and all metadata ***/
	IF	(@pDebug = 1)
	BEGIN
		SELECT	'@vColumnsAndValues' AS TableName,v.column_name,v.column_ordinal,v.column_type,v.column_value,v.column_precision,v.column_scale
		FROM	@vColumnsAndValues v;
	END
	
	
	--********Check input values are valid as per the schema********
	--Check all specified columns exist
	SELECT	1 as countofnullcolnames
	INTO	#anynullcolnames
	FROM	@vColumnsAndValues
	WHERE	column_type IS NULL;
	IF	(@@ROWCOUNT > 0)
	BEGIN
			SET @raiserrormsg = 'Not all columns specified in @pFilterCols parameter exist in ' + @pDatabasename + '.' + @pSchemaName + '.' + @pTableName;
			RAISERROR(@raiserrormsg,16,1);
			RETURN;
	END
	--Check columns are of types we are set up to handle!
	SELECT	1 AS countofnhandledcolumntypes
	INTO	#anyunhandledcolumntypes
	FROM	@vColumnsAndValues
	WHERE	lower(column_type) NOT IN ('int','tinyint','smallint','bigint','varchar','nvarchar','char','nchar');
	IF	(@@ROWCOUNT > 0)
	BEGIN
			SET @raiserrormsg = 'Current version of ' + OBJECT_NAME(@@PROCID,DB_ID('master')) + ' only works for columns of type tinyint,smallint,int,bigint,varchar,nvarchar,char,nchar. Sorry!';
			RAISERROR(@raiserrormsg,16,1);
			RETURN;
	END
	
	--********End of checking input values are valid********
	
	--Discover tables dependent on named table
	SET	@vSQL =		N'
WITH	fk_tables AS
(
		SELECT	OBJECT_SCHEMA_NAME(parent_object_id,DB_ID(''@pDatabaseName'')) AS child_schema
		,		OBJECT_NAME(parent_object_id,DB_ID(''@pDatabaseName'')) AS child_table
		,		OBJECT_SCHEMA_NAME(referenced_object_id,DB_ID(''@pDatabaseName'')) AS parent_schema
		,		OBJECT_NAME(referenced_object_id,DB_ID(''@pDatabaseName'')) AS parent_table
		,		fk.Name AS fk_name 
		,		i.Name AS uk_name  --name of unique key in referenced (i.e. parent) table
		FROM	@pdatabaseName.sys.foreign_keys fk
		INNER	JOIN @pdatabaseName.sys.indexes i
		ON		fk.referenced_object_id = i.object_id
		AND		fk.key_index_id = i.index_id
		WHERE	i.is_unique = 1
),		dependents AS
(
		SELECT	fk.child_schema,fk.child_table,fk.parent_schema,fk.parent_table,1 AS DependLevel, fk.fk_name, fk.uk_name
		FROM	fk_tables fk
		WHERE	fk.parent_schema = ''@pSchemaName''
		AND		fk.parent_table = ''@pTableName''
		UNION	ALL
		SELECT	fk.child_schema,fk.child_table,fk.parent_schema,fk.parent_table,d.DependLevel + 1, fk.fk_name, fk.uk_name
		FROM	fk_tables fk
		INNER	JOIN dependents d
		ON		(	fk.parent_schema = d.child_schema
				AND		fk.parent_table = d.child_table)
		AND		NOT		(	fk.parent_schema = d.parent_schema
						AND	fk.parent_table = d.parent_table)
),		filtered_dependants AS
(
		SELECT	DISTINCT d.child_Schema, d.child_Table, d.parent_Schema, d.parent_Table, d.DependLevel, fk_name, uk_name 
		FROM	dependents d
		WHERE	d.[DependLevel] <= @pDependantLevels OR @pDependantLevels <= -1
),		number_of_table_occurences AS
(
		SELECT	fd.[child_schema],fd.[child_table],COUNT(*) AS [NumOccurencesOfDependantTable]
		FROM	filtered_dependants fd
		GROUP	BY fd.[child_schema],fd.[child_table]
)
SELECT	ROW_NUMBER() OVER (ORDER BY q.DependLevel ASC) AS TableNum
,		ROW_NUMBER() OVER (PARTITION BY q.child_table,q.child_schema ORDER BY q.DependLevel) AS Occurrence
,		q.child_schema,q.child_table,q.parent_schema,q.parent_table,q.DependLevel,q.fk_name,q.uk_name
,		CAST(CASE WHEN q2.parent_schema IS NULL THEN  1 ELSE 0 END AS BIT) AS HasNoDescendantTables
,		occ.[NumOccurencesOfDependantTable]
FROM	filtered_dependants q
INNER	JOIN number_of_table_occurences occ
ON		q.[child_schema] = occ.[child_schema]
AND		q.[child_table] = occ.[child_table]
LEFT	OUTER JOIN (	SELECT	DISTINCT fd.[parent_schema],fd.[parent_table]
						FROM	filtered_dependants fd) q2  --Joining back to itself to see if there are any dependant tables or not
ON		q.child_schema = q2.parent_schema
AND		q.child_table = q2.parent_table
;'

	SET		@vSQL = REPLACE(@vSQL, '@pDatabaseName', @pdatabaseName);
	SET		@vSQL = REPLACE(@vSQL, '@pSchemaName', @pSchemaName);
	SET		@vSQL = REPLACE(@vSQL, '@pTableName', @pTableName);
	SET		@vSQL = REPLACE(@vSQL, '@pDependantLevels', @pDependantLevels);
	IF	(@pPrintSQL = 1)
			PRINT	@vSQL;
	INSERT	@vDepends
	EXEC	sp_executesql	@vSQL;
	IF	(@pDebug =1)
	BEGIN
			SELECT	'@vDepends' As TableName,v.TableNum,v.child_Schema,v.child_Table,v.parent_Schema,v.parent_Table,v.DependLevel,v.fk_name,v.uk_name
			FROM	@vDepends v
	END
	--Build SELECT statement for selecting the appropriate data from the starting table
	PRINT	N'Starting table: ' + @pTableName;
	SET		@vSQL = N'
SELECT	''@pSchemaName.@pTableName'' AS CascadingDataViewerTableName, c.*
INTO	[@pDatabaseName]..[cascadingdataviewer_@pschemaName_@pTableName]  --wanted to make this a temp table but then not referenceable from later dynamic SQL
FROM	[@pDatabaseName].[@pSchemaName].[@pTableName] c
'

	DECLARE	columns_cursor CURSOR FOR
	SELECT	column_ordinal, column_name,column_type,column_precision,column_scale,column_value
	FROM	@vColumnsAndValues;
	OPEN	columns_cursor;
	FETCH	NEXT	FROM columns_cursor 
	INTO	@vColumnOrdinal,@vColumnName,@vColumnType,@vColumnPrecision,@vColumnScale,@vColumnValue;
	WHILE	@@FETCH_STATUS = 0
	BEGIN
			SET	@vSQL = @vSQL + CASE WHEN @vColumnOrdinal = 1 THEN 'WHERE' ELSE 'AND' END + '	';
			SET	@vSQL = @vSQL + 'c.[' + @vColumnName + '] = ' +	CASE	WHEN	@vColumnType = 'int'		THEN	@vColumnValue
																		WHEN	@vColumnType = 'bigint'		THEN	@vColumnValue
																		WHEN	@vColumnType = 'tinyint'	THEN	@vColumnValue
																		WHEN	@vColumnType = 'smallint'	THEN	@vColumnValue
																		WHEN	@vColumnType = 'varchar'	THEN	'''' + @vColumnValue + ''''
																		WHEN	@vColumnType = 'nvarchar'	THEN	'''' + @vColumnValue + ''''
																		WHEN	@vColumnType = 'char'		THEN	'''' + @vColumnValue + ''''
																		WHEN	@vColumnType = 'nchar'		THEN	'''' + @vColumnValue + ''''
																		ELSE	'' --If we get to here then something has gone wrong elsewhere because above CASEs should cover all eventualities
																END + CHAR(10);
			FETCH	NEXT	FROM columns_cursor 
			INTO	@vColumnOrdinal,@vColumnName,@vColumnType,@vColumnPrecision,@vColumnScale,@vColumnValue;
	END	
	
	SET		@vSQL = REPLACE(@vSQL, '@pDatabaseName',	@pDatabaseName);
	SET		@vSQL = REPLACE(@vSQL, '@pTableName',		@pTableName);
	SET		@vSQL = REPLACE(@vSQL, '@pSchemaName',		@pSchemaName);
	
	SET		@vSQL = @vSQL + ';
SELECT	@RowCountOUT = @@ROWCOUNT;
';
	SET		@vParmDefinition = N'@RowCountOUT int OUTPUT';

	IF	@pPrintSQL = 1
			PRINT	@vSQL;
	EXEC	sp_executesql @vSQL, @vParmDefinition, @RowCountOUT = @pNumberOfRows OUTPUT ;

	--Is table self-referencing?
	SET		@vSQL = '
SELECT	i.[name] as ParentUniqueKey,fk.[name] as ChildForeignKey,c.[name] AS ParentColumn,fkcc.[name] AS ChildColumn
FROM	[@pDatabaseName].[sys].[tables] t 
INNER	JOIN [@pDatabaseName].[sys].[foreign_keys] fk
ON		t.object_id = fk.parent_object_id
LEFT	OUTER JOIN [@pDatabaseName].[sys].[indexes] i
ON		fk.[referenced_object_id] = i.[object_id]
AND		fk.[key_index_id] = i.[index_id]
INNER	JOIN [@pDatabaseName].[sys].[index_columns] ic
ON		i.[index_id] = ic.[index_id]
AND		i.[object_id] = ic.[object_id]
INNER	JOIN [@pDatabasename].[sys].[columns] c 
ON		ic.[object_id] = c.[object_id]
AND		ic.[column_id] = c.[column_id]
INNER	JOIN [@pDatabasename].[sys].[foreign_key_columns] fkc
ON		fk.[object_id] = fkc.constraint_object_id
INNER	JOIN [@pDatabaseName].[sys].[columns] fkcc
ON		fkc.[parent_column_id] = fkcc.column_id
AND		fkc.[parent_object_id] = fkcc.[object_id]
WHERE	t.[name] = ''@pTableName''
AND		t.[type] = ''U''
AND		OBJECT_SCHEMA_NAME(t.[object_id],DB_ID(''@pDatabaseName'')) = ''@pSchemaname''
AND		fk.parent_object_id = fk.referenced_object_id --AND table is referencing itself
;

SELECT	@NumSelfRefKeysOUT = @@ROWCOUNT;
';
	SET		@vParmDefinition = N'@NumSelfRefKeysOUT int OUTPUT';
	SET		@vSQL = REPLACE(@vSQL,'@pDatabaseName',@pDatabasename);
	SET		@vSQL = REPLACE(@vSQL,'@pSchemaName',@pSchemaName);
	SET		@vSQL = REPLACE(@vSQL,'@pTableName',@pTableName);
	IF	(@pPrintSQL = 1)
			PRINT	@vSQL;

	INSERT	@vSelfRefKeys
	EXEC	sp_executesql	@vSQL, @vParmDefinition, @NumSelfRefKeysOUT = @vNumSelfRefKeys OUTPUT;
	IF	(@pDebug =1)
	BEGIN
			SELECT	'@vSelfRefKeys',ParentUniqueKey,ChildForeignKey,ParentColumn,ChildColumn
			FROM	@vSelfRefKeys v
	END
	IF	@vNumSelfRefKeys > 0
	BEGIN
		--Table is self-referencing so loop until there are no more rows to pull out
		--SELECT	ParentUniqueKey,ChildForeignKey,ParentColumn,ChildColumn
		--FROM	@vSelfRefKeys v
		SET		@vSQL = N'
DECLARE	@CumulativeRowCount int = 0
,		@CurrentIterationRowCount int = -1;

WHILE (@CurrentIterationRowCount <> 0)
BEGIN
	INSERT	[@pDatabaseName]..[cascadingdataviewer_@pschemaName_@pTableName]
	SELECT	''@pSchemaName.@pTableName'' AS CascadingDataViewerTableName, c.*
	FROM	[@pDatabaseName].[@pSchemaName].[@pTableName] c
	INNER	JOIN [@pDatabaseName]..[cascadingdataviewer_@pschemaName_@pTableName] p
';
		SET		@vFirstColumnIteration = 1;
		DECLARE	self_ref_cols_cursor	CURSOR FOR
		SELECT	ParentColumn,ChildColumn
		FROM	@vSelfRefKeys
		OPEN	self_ref_cols_cursor;
		FETCH	NEXT FROM self_ref_cols_cursor
		INTO	@vCurrentParentColumn,@vCurrentChildColumn;
		WHILE	@@FETCH_STATUS = 0
		BEGIN
				SET		@vSQL = @vSQL + CASE	WHEN @vFirstColumnIteration = 1 THEN N'	ON' 
												ELSE N'	AND' 
										END + N'		c.[' + @vCurrentChildColumn + N'] = p.[' + @vCurrentParentColumn + ']' + CHAR(10);
				SET		@vFirstColumnIteration = 0;
				FETCH	NEXT FROM self_ref_cols_cursor
				INTO	@vCurrentChildColumn,@vCurrentParentColumn;
		END	
		CLOSE	self_ref_cols_cursor;
		DEALLOCATE self_ref_cols_cursor;

		SET		@vSQL = @vSQL + N'	LEFT	OUTER JOIN [@pDatabaseName]..[cascadingdataviewer_@pschemaName_@pTableName] d ' + CHAR(10);
		SET		@vFirstColumnIteration = 1;
		--Loop over columns, building up SQL statement as we go!
		DECLARE	left_join_cursor	CURSOR FOR
		SELECT	ParentColumn
		FROM	@vSelfRefKeys
		OPEN	left_join_cursor;
		FETCH	NEXT FROM left_join_cursor
		INTO	@vCurrentParentColumn;
		WHILE	@@FETCH_STATUS = 0
		BEGIN
				SET		@vSQL = @vSQL + CASE	WHEN @vFirstColumnIteration = 1 THEN N'	ON' 
												ELSE N'	AND' 
										END + N'		c.[' + @vCurrentParentColumn + N'] = d.[' + @vCurrentParentColumn + ']' + CHAR(10);
				SET		@vFirstColumnIteration = 0;
				FETCH	NEXT FROM left_join_cursor
				INTO	@vCurrentParentColumn;
		END	
		CLOSE	left_join_cursor;
		DEALLOCATE left_join_cursor;
		SET		@vSQL = @vSQL + N'	WHERE	d.[' + @vCurrentParentColumn + '] IS NULL'

		SET		@vSQL = @vSQL + ';
	SELECT	@CurrentIterationRowCount = @@ROWCOUNT;  --Need to store @@ROWCOUNT because we need to reference it twice, once in the next line and once in the loop condition
	SELECT	@CumulativeRowCount = @CumulativeRowCount + @CurrentIterationRowCount;
END
SELECT	@RowCountOUT = @CumulativeRowCount;
';

		SET		@vSQL = REPLACE(@vSQL,'@pDatabaseName',@pDatabasename);
		SET		@vSQL = REPLACE(@vSQL,'@pSchemaName',@pSchemaName);
		SET		@vSQL = REPLACE(@vSQL,'@pTableName',@pTableName);
		IF	(@pPrintSQL = 1)
			PRINT	@vSQL;
		SET		@vParmDefinition = N'@RowCountOUT int OUTPUT';
		EXEC	sp_executesql @vSQL, @vParmDefinition, @RowCountOUT = @vNumberOfRows OUTPUT ;
		SET		@pNumberOfRows = @pNumberOfRows + @vNumberOfRows;
	END

	--END of dealing with [@pSchemaName].[@pTableName]

	DECLARE	create_table_cursor	CURSOR FOR
	SELECT	[TableNum], [child_schema], [child_table], [parent_Schema], [parent_Table], [fk_name], [uk_name], [Occurrence], [HasNoDescendantTables], [NumOccurencesOfDependantTable]
	FROM	@vDepends
	ORDER BY [dependLevel] ASC,[Occurrence] ASC;
	
	OPEN	create_table_cursor;
	FETCH	NEXT FROM create_table_cursor
	INTO	@vTableNum, @vCurrentChildSchema,@vCurrentChildTable,@vCurrentParentSchema,
			@vCurrentParentTable,@vCurrentFKName,@vCurrentUKName,@vOccurrence,@vHasNoDescendantTables,@vNumOccurencesOfDependantTable;
	
	WHILE	@@FETCH_STATUS = 0
	BEGIN
			SET	@vSQL =	N'Current table: [@vCurrentChildSchema].[@vCurrentChildTable],  Dependant on: [@vCurrentParentSchema].[@vCurrentParentTable]';
			SET	@vSQL = REPLACE(@vSQL,'@vCurrentChildSchema',@vCurrentChildSchema);
			SET	@vSQL = REPLACE(@vSQL,'@vCurrentChildTable',@vCurrentChildTable);
			SET	@vSQL = REPLACE(@vSQL,'@vCurrentParentSchema',@vCurrentParentSchema);
			SET	@vSQL = REPLACE(@vSQL,'@vCurrentParentTable',@vCurrentParentTable);
			PRINT	@vSQL;
			DELETE FROM	@vIndexCols;
			--Get columns in unique key of named table		
			SET	@vSQL = N'
select	fk.name as fk_name
,		OBJECT_SCHEMA_NAME(fkc.parent_object_id, DB_ID(''@pDatabaseName'')) as child_schema
,		OBJECT_NAME(fkc.parent_object_id, DB_ID(''@pDatabaseName'')) as child_table
,		OBJECT_SCHEMA_NAME(fkc.referenced_object_id, DB_ID(''@pDatabaseName'')) as parent_schema
,		OBJECT_NAME(fkc.referenced_object_id, DB_ID(''@pDatabaseName'')) as parent_table
,		child_c.name as child_column
,		parent_c.name as parent_column
from	@pDatabaseName.sys.foreign_keys fk
inner	join @pDatabaseName.sys.foreign_key_columns fkc
on		fk.object_id = fkc.constraint_object_id
inner	join @pDatabaseName.sys.columns child_c
on		fkc.parent_object_id = child_c.object_id
and		fkc.parent_column_id = child_c.column_id
inner	join @pDatabaseName.sys.columns parent_c
on		fkc.referenced_object_id = parent_c.object_id
and		fkc.referenced_column_id = parent_c.column_id
where	fk.Name = ''@vCurrentFKName''
and		OBJECT_NAME(child_c.object_id,DB_ID(''@pDatabaseName'')) = ''@vCurrentChildTable''
and		OBJECT_SCHEMA_NAME(child_c.object_id,DB_ID(''@pDatabaseName'')) = ''@vCurrentChildSchema''
'
			
			SET		@vSQL = REPLACE(@vSQL, '@pDatabaseName',		@pDatabaseName);
			SET		@vSQL = REPLACE(@vSQL, '@vCurrentFKName',		@vCurrentFKName);
			SET		@vSQL = REPLACE(@vSQL, '@vCurrentChildTable',	@vCurrentChildTable);
			SET		@vSQL = REPLACE(@vSQL, '@vCurrentChildSchema',	@vCurrentChildSchema);
									
			INSERT	@vIndexCols
			EXEC	sp_executesql @vSQL;
			IF		@pDebug = 1
					SELECT	'@vIndexCols' AS TableName,v.fk_name,v.child_schema,v.child_table,v.child_column,v.parent_schema,v.parent_table,v.parent_column
					FROM	@vIndexCols v;
			
			--**********************************************
			--Build SELECT statements for selecting the appropriate data from the current dependent table
			DECLARE	@vChildTableName SYSNAME	= 'cascadingdataviewer_' + @vCurrentChildSchema + '_' + @vCurrentChildTable
			,		@vParentTableName SYSNAME	= 'cascadingdataviewer_' + @vCurrentParentSchema + '_' + @vCurrentParentTable;
			DECLARE	@vSelectList NVARCHAR(MAX) = N'
SELECT	''@vCurrentChildSchema.@vCurrentChildTable'' AS [CascadingDataViewerTableName]
		--I was originally going to include the name of the referenced table and the names of the keys but then realised that there may be more than one
		--reason for a row to be considered a dependant row, so I could not include this information.
		--CAST(''@vCurrentFKName'' AS SYSNAME) AS ReferencingKey, 
		--''@vCurrentParentSchema.@vCurrentParentTable'' AS ReferencedTable, 
		--CAST(''@vCurrentUKName'' AS SYSNAME) AS ReferencedKey, 
		--c.*
		';
		SET		@vSQL = '
SELECT	cols.[Name],TYPE_NAME(cols.user_type_id)
FROM	@pDatabaseName.sys.columns cols
WHERE	OBJECT_NAME(cols.object_id,DB_ID(''@pDatabasename'')) = ''@vCurrentChildTable''
AND		OBJECT_SCHEMA_NAME(cols.object_id,DB_ID(''@pDatabasename'')) = ''@vCurrentChildSchema''
';
		SET		@vSQL = REPLACE(@vSQL, '@pDatabaseName',		@pDatabaseName);
		SET		@vSQL = REPLACE(@vSQL, '@vCurrentChildTable',	@vCurrentChildTable);
		SET		@vSQL = REPLACE(@vSQL, '@vCurrentChildSchema',	@vCurrentChildSchema);
		PRINT	@vSQL;
		DELETE	FROM @vColumns;
		INSERT	@vColumns
		EXEC	sp_executesql @vSQL;

		--Loop over list of columns in @pTableName so we can build up @vSelectList, making sure we treat each one of them appropriately
		DECLARE	col_cur	CURSOR
		FOR		SELECT [ColumnName],[ColumnType] FROM @vColumns;
		OPEN	col_cur;
		FETCH	NEXT FROM col_cur
		INTO	@vColumnName,@vColumnType;
		WHILE	(@@FETCH_STATUS = 0)
		BEGIN
				IF	(@vColumnType <> 'timestamp' AND @vColumnType <> 'rowversion') --future-proofing by including rowversion
				SET		@vSelectList = @vSelectList + N',c.[' + @vColumnName + N']';
		
				FETCH	NEXT FROM col_cur
				INTO	@vColumnName,@vColumnType;
		END
		CLOSE	col_cur;
		DEALLOCATE	col_cur;
		----------------------------------------------------------------
		---Get a list of all the candidate keys on the current table
		SET	@vSQL	=	'
select	i.name as IndexName
,		i.is_primary_key AS IsPrimaryKey
,		c.name AS ColumnName
,		ic.[key_ordinal]
from	[@pDatabaseName].sys.indexes i
INNER	JOIN [@pDatabaseName].sys.index_columns ic 
ON		i.object_id = ic.object_id
AND		i.index_id = ic.index_id
INNER	JOIN [@pDatabaseName].sys.columns c
ON		ic.object_id = c.object_id
AND		ic.column_id = c.column_id
WHERE	i.is_unique = 1
AND		OBJECT_NAME(i.object_id,DB_ID(''@pDatabaseName''))			= ''@vCurrentChildTable''
AND		OBJECT_SCHEMA_NAME(i.object_id,DB_ID(''@pDatabaseName''))	= ''@vCurrentChildSchema'';'
			SET	@vSQL = REPLACE(@vSQL, '@pDatabaseName',			@pDatabaseName);
			SET	@vSQL = REPLACE(@vSQL, '@vCurrentChildTable',		@vCurrentChildTable);
			SET	@vSQL = REPLACE(@vSQL, '@vCurrentChildSchema',	@vCurrentChildSchema);
			IF	@pPrintSQL = 1
					PRINT	@vSQL;
			DELETE	FROM @vPrimaryAndUniqueKeys;
			INSERT	@vPrimaryAndUniqueKeys
			EXEC	sp_executesql	@vSQL;
			------End getting a list of all candidate keys on current dependant table
			----------------------------------------------------------------

			IF (		@vOccurrence = 1 
					AND	(@vCurrentChildTable <> @pTableName OR @vCurrentChildSchema <> @pSchemaName) --To deal with edge case where the dependant table is the same as the "starter" table (i.e. it has a self-reference)
			)  --Table has not yet been created
			BEGIN
					SET		@vSQL = @vSelectList + N'
INTO	[@pDatabaseName]..[@vChildTableName]  --wanted to make this a temp table but then not referenceable from later dynamic SQL
FROM	[@pDatabaseName].[@vCurrentChildSchema].[@vCurrentChildTable] c 
INNER	JOIN [sys].[tables] t  --Joining to any arbitrary table means that any identities on the original table will not get carried across
ON		t.[object_id] = t.[object_id]
WHERE	1 = 0; --Create an empty table';

					--Cursor to loop over all primary/unique constraints on the table
					DECLARE	key_cursor CURSOR FOR
					SELECT	DISTINCT k.IndexName,k.IsPrimaryKey
					FROM	@vPrimaryAndUniqueKeys k;
					DECLARE	@vIndexName			sysname
					,		@vIsPrimaryKey		bit
					,		@vIndexColumnName	sysname;
					OPEN	key_cursor;
					FETCH	NEXT FROM key_cursor
					INTO	@vIndexName,@vIsPrimaryKey;
					WHILE	@@FETCH_STATUS = 0
					BEGIN
							SET	@vSQL = @vSQL + '
ALTER	TABLE [@pDatabaseName]..[@vChildTableName] ADD CONSTRAINT [@vIndexname_cascadingdataviewer] ' + CASE WHEN @vIsPrimaryKey = 1 THEN 'PRIMARY KEY' ELSE 'UNIQUE' END + ' (';	
							--Cursor to loop over all column on the index
							DECLARE	index_column_names CURSOR FOR
							SELECT	k.[ColumnName]
							FROM	@vPrimaryAndUniqueKeys k
							WHERE	k.[IndexName] = @vIndexName
							ORDER	BY k.[key_ordinal] ASC;
							OPEN	index_column_names;
							FETCH	NEXT FROM index_column_names
							INTO	@vIndexColumnName;
							WHILE	@@FETCH_STATUS = 0
							BEGIN
									SET	@vSQL = @vSQL + '[' + @vIndexColumnName + '],';
									FETCH	NEXT FROM index_column_names
									INTO	@vIndexColumnName;
							END
							CLOSE	index_column_names;
							DEALLOCATE	index_column_names;
							SET		@vSQL = SUBSTRING(@vSQL,1,LEN(@vSQL)-1);--Get rid of the last comma
							SET		@vSQL = @vSQL + ');'; --close off the list of columns on the constraint
							SET		@vSQL = REPLACE(@vSQL, '@vIndexname',@vIndexname);
							FETCH	NEXT FROM key_cursor
							INTO	@vIndexName,@vIsPrimaryKey;
					END
					CLOSE	key_cursor;
					DEALLOCATE	key_cursor;

					SET		@vSQL = REPLACE(@vSQL, '@pDatabaseName',		@pDatabaseName);
					SET		@vSQL = REPLACE(@vSQL, '@vCurrentChildSchema',	@vCurrentChildSchema);
					SET		@vSQL = REPLACE(@vSQL, '@vCurrentChildTable',	@vCurrentChildTable);
					SET		@vSQL = REPLACE(@vSQL, '@vCurrentParentSchema',	@vCurrentParentSchema);
					SET		@vSQL = REPLACE(@vSQL, '@vCurrentParentTable',	@vCurrentParentTable);
					SET		@vSQL = REPLACE(@vSQL, '@vCurrentUKName',		@vCurrentUKName);
					SET		@vSQL = REPLACE(@vSQL, '@vCurrentFKName',		@vCurrentFKName);
					SET		@vSQL = REPLACE(@vSQL, '@vChildTableName',		@vChildTableName);
					SET		@vSQL = REPLACE(@vSQL, '@vParentTableName',		@vParentTableName);

					IF	@pPrintSQL = 1
							PRINT	@vSQL;
					--**********************************************
					EXEC	sp_executesql @vSQL;
			END

			SET		@vSQL = N'
DECLARE	@CumulativeRowCount int = 0
,		@CurrentIterationRowCount int = -1;

WHILE (@CurrentIterationRowCount <> 0) --we loop in order to take care of the case where the table is self-referencing
BEGIN';
			IF (@vHasNoDescendantTables = 1 AND @pShowData = 0 AND @vOccurrence = @vNumOccurencesOfDependantTable) --IF there is no need to store the data, don't store it!!!
					SET		@vSQL = @vSQL + N'
			SELECT	@CumulativeRowCount = COUNT(*)';
			ELSE
					SET		@vSQL = @vSQL + N'
			INSERT	INTO [@pDatabaseName]..[@vChildTableName]' + @vSelectList;

			SET		@vSQL = @vSQL + N'
			FROM	[@pDatabaseName].[@vCurrentChildSchema].[@vCurrentChildTable] c 
			INNER	JOIN [@pDatabaseName]..[@vParentTableName] p
';
			SET		@vFirstColumnIteration = 1;
			--Loop over columns, building up SQL statement as we go!
			DECLARE	cols_cursor	CURSOR FOR
			SELECT	child_column, parent_column
			FROM	@vIndexCols
			OPEN	cols_cursor;
			FETCH	NEXT FROM cols_cursor
			INTO	@vCurrentChildColumn,@vCurrentParentColumn;
			WHILE	@@FETCH_STATUS = 0
			BEGIN
					SET		@vSQL = @vSQL + CASE	WHEN @vFirstColumnIteration = 1 THEN N'	ON' 
													ELSE N'	AND' 
											END + N'		c.[' + @vCurrentChildColumn + N'] = p.[' + @vCurrentParentColumn + ']' + CHAR(10);
					SET		@vFirstColumnIteration = 0;
					FETCH	NEXT FROM cols_cursor
					INTO	@vCurrentChildColumn,@vCurrentParentColumn;
			END	
			CLOSE	cols_cursor;
			DEALLOCATE cols_cursor;
			IF EXISTS (SELECT 1 FROM @vPrimaryAndUniqueKeys) --If there are no candidate keys on the table then we can't join it to itself
			BEGIN
					SET		@vSQL = @vSQL + N'	LEFT	OUTER JOIN [@pDatabaseName]..[@vChildTableName] d ' + CHAR(10);
					SET		@vFirstColumnIteration = 1;
					--Loop over columns, building up SQL statement as we go!
					DECLARE	left_join_cursor	CURSOR FOR
					SELECT	p.[ColumnName]--,p.[key_ordinal]
					FROM	@vPrimaryAndUniqueKeys p
					INNER	JOIN ( --We get the MAX IndexName because we only need to join on the columns for one candidate key, it doesn't matter which one. Doing a MAX gives us that one.
							SELECT	MAX([IndexName]) AS [MaxIndexName]
							FROM	@vPrimaryAndUniqueKeys
					)m_p
					ON		p.[IndexName] = m_p.[MaxIndexName]
					ORDER	BY p.[key_ordinal] ASC;

					OPEN	left_join_cursor;
					FETCH	NEXT FROM left_join_cursor
					INTO	@vCurrentChildColumn;--,@vCurrentParentColumn;
					WHILE	@@FETCH_STATUS = 0
					BEGIN
							SET		@vSQL = @vSQL + CASE	WHEN @vFirstColumnIteration = 1 THEN N'	ON' 
															ELSE N'	AND' 
													END + N'		c.[' + @vCurrentChildColumn + N'] = d.[' + @vCurrentChildColumn + ']' + CHAR(10);
							SET		@vFirstColumnIteration = 0;
							FETCH	NEXT FROM left_join_cursor
							INTO	@vCurrentChildColumn;--,@vCurrentParentColumn;
					END	
					CLOSE	left_join_cursor;
					DEALLOCATE left_join_cursor;
					SET		@vSQL = @vSQL + N'	WHERE	d.[' + @vCurrentChildColumn + '] IS NULL'
			END

			IF (@vHasNoDescendantTables = 1 AND @pShowData = 0 AND @vOccurrence = @vNumOccurencesOfDependantTable) --IF this is the case then we're not storing the data and we've already captured @CumulativeRowCount, so break out of the loop
					SET		@vSQL = @vSQL + '
			SET	@CurrentIterationRowCount = 0;'; --this will break out of the loop
			ELSE
					
					SET		@vSQL = @vSQL + ';
			SELECT	@CurrentIterationRowCount = @@ROWCOUNT;  --Need to store @@ROWCOUNT because we need to reference it twice, once in the next line and once in the loop condition
			SELECT	@CumulativeRowCount = @CumulativeRowCount + @CurrentIterationRowCount;'
			IF NOT EXISTS (SELECT 1 FROM @vPrimaryAndUniqueKeys) --If there are no candidate keys on the table then we looping will be an infinite loop (cos it'll just carry on adding the same rows over and over again). So, break out of the loop.
			SET		@vSQL = @vSQL + '
			SET	@CurrentIterationRowCount = 0;'; --this will break out of the loop
			SET		@vSQL = @vSQL + '
END';
			SET		@vSQL = @vSQL + '

SELECT	@RowCountOUT = @CumulativeRowCount;
';
			
			SET		@vSQL = REPLACE(@vSQL, '@pDatabaseName',		@pDatabaseName);
			SET		@vSQL = REPLACE(@vSQL, '@vCurrentChildSchema',	@vCurrentChildSchema);
			SET		@vSQL = REPLACE(@vSQL, '@vCurrentChildTable',	@vCurrentChildTable);
			SET		@vSQL = REPLACE(@vSQL, '@vCurrentParentSchema',	@vCurrentParentSchema);
			SET		@vSQL = REPLACE(@vSQL, '@vCurrentParentTable',	@vCurrentParentTable);
			SET		@vSQL = REPLACE(@vSQL, '@vCurrentUKName',		@vCurrentUKName);
			SET		@vSQL = REPLACE(@vSQL, '@vCurrentFKName',		@vCurrentFKName);
			SET		@vSQL = REPLACE(@vSQL, '@vChildTableName',		@vChildTableName);
			SET		@vSQL = REPLACE(@vSQL, '@vParentTableName',		@vParentTableName);

			IF	@pPrintSQL = 1
					PRINT	@vSQL;
			--**********************************************
			SET		@vParmDefinition = N'@RowCountOUT int OUTPUT';
			EXEC	sp_executesql @vSQL, @vParmDefinition, @RowCountOUT = @vNumberOfRows OUTPUT ;    --Copies the data into a temporary table so that we can show that data later (if the user has asked to see it)
			SET		@pNumberOfRows = @pNumberOfRows + @vNumberOfRows;
			FETCH	NEXT FROM create_table_cursor
			INTO	@vTableNum,@vCurrentChildSchema,@vCurrentChildTable,@vCurrentParentSchema,
					@vCurrentParentTable,@vCurrentFKName,@vCurrentUKName,@vOccurrence,@vHasNoDescendantTables,@vNumOccurencesOfDependantTable;
	END	
	CLOSE		create_table_cursor;
	DEALLOCATE	create_table_cursor;
	
	--SELECT all data from the tables we have created, in order that we created them.
	IF	@pShowData = 1
	BEGIN
			SET	@vChildTableName = N'cascadingdataviewer_' + @pSchemaName + N'_' + @pTableName;
			SET	@vSQL = N'
IF EXISTS(SELECT 1 FROM [@pDatabaseName]..[' + @vChildTableName + N'])
SELECT	*
FROM	[@pDatabaseName]..[' + @vChildTableName + N'];';
			SET		@vSQL = REPLACE(@vSQL, '@pDatabaseName',		@pDatabaseName);
			IF	@pPrintSQL = 1 PRINT @vSQL;
			EXEC sp_executesql @vSQL;


			DECLARE	select_cursor	CURSOR FOR
			SELECT	q.child_schema, q.child_table
			FROM	(
					SELECT	MIN(v.TableNum)MinTableNum,v.child_schema, v.child_table
					FROM	@vDepends v
					WHERE	NOT	(		v.[child_schema]	=	@pSchemaName --this WHERE clause protects against the starter table being self-referencing. Without this WHERE clause
								AND		v.[child_table]		=	@pTableName) -- we would ultimately be selecting from it twice
					GROUP	BY v.child_schema, v.child_table
					)q
			ORDER	BY q.MinTableNum;

			OPEN	select_cursor;
			FETCH	NEXT FROM select_cursor
			INTO	@vCurrentChildSchema,@vCurrentChildTable;
			
			WHILE	@@FETCH_STATUS = 0
			BEGIN
					SET	@vChildTableName = N'cascadingdataviewer_' + @vCurrentChildSchema + N'_' + @vCurrentChildTable;
					SET		@vSQL = N'
IF EXISTS(SELECT 1 FROM [@pDatabaseName]..[' + @vChildTableName + '])
SELECT	*
FROM	[@pDatabaseName]..[' + @vChildTableName + N'];';
					SET		@vSQL = REPLACE(@vSQL, '@pDatabaseName',		@pDatabaseName);
					IF	(@pPrintSQL = 1) PRINT @vSQL;
					EXECUTE	sp_executesql @vSQL;
					FETCH	NEXT FROM select_cursor
					INTO	@vCurrentChildSchema,@vCurrentChildTable;
			END
			CLOSE		select_cursor;
			DEALLOCATE	select_cursor;
	END
	
	--**********Cleanup temp tables
	DECLARE	delete_cursor	CURSOR FOR
	SELECT	DISTINCT child_schema, child_table
	FROM	@vDepends;

	OPEN	delete_cursor;
	FETCH	NEXT FROM delete_cursor
	INTO	@vCurrentChildSchema,@vCurrentChildTable;
	
	WHILE	@@FETCH_STATUS = 0
	BEGIN
			SET		@vSQL = N'DROP TABLE [@pDatabaseName]..[cascadingdataviewer_' + @vCurrentChildSchema + '_' + @vCurrentChildTable + ']';
			SET		@vSQL = REPLACE(@vSQL,'@pDatabaseName',@pDatabaseName);
			IF	(@pPrintSQL = 1) PRINT @vSQL;
			
			IF	(@vCurrentChildSchema <> @pSchemaName OR @vCurrentChildTable <> @pTableName) --If the table to be dropped is the same as the "starter" table (i.e. it self-references), don't drop it (because it gets fropped later)
				EXECUTE	sp_executesql @vSQL;
			
			FETCH	NEXT FROM delete_cursor
			INTO	@vCurrentChildSchema,@vCurrentChildTable;
	END
	CLOSE		delete_cursor;
	DEALLOCATE	delete_cursor;
	
	--Drop the starting table!
	SET		@vSQL = N'DROP TABLE [@pDatabaseName]..[cascadingdataviewer_' + @pSchemaName + '_' + @pTableName + ']';
	SET		@vSQL = REPLACE(@vSQL,'@pDatabaseName',@pDatabaseName);
	IF	(@pPrintSQL = 1) PRINT @vSQL;
	EXECUTE	sp_executesql @vSQL;
END

GO
/****** Object:  StoredProcedure [dbo].[Util_FindStringInDB]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--	Util_FindStringInDB 'Ctl1'

ALTER PROCEDURE [dbo].[Util_FindStringInDB]
@Search varchar(256)

as

SELECT [Name] ObjectName,  
	ObjectType = 
	CASE xtype 
		WHEN 'u' THEN 'Table'   
		WHEN 'p' THEN 'Stored Procedure'   
		WHEN 'v' THEN 'View'
		ELSE ''  
	end
FROM SYSOBJECTS 
WHERE ID IN (SELECT ID FROM SYSCOMMENTS WHERE TEXT LIKE '%' + @Search + '%')
order by ObjectType, ObjectName

/*SELECT ROUTINE_NAME, ROUTINE_DEFINITION FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_DEFINITION LIKE '%lq_Campaign%' AND ROUTINE_TYPE='PROCEDURE'*/



GO
/****** Object:  StoredProcedure [dbo].[Util_GetTablesWithColumnName]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--		Util_GetTablesWithColumnName 'Ctl1'
ALTER PROCEDURE [dbo].[Util_GetTablesWithColumnName]
	@ColumnName varchar(256)
AS

SELECT t.name AS table_name,
SCHEMA_NAME(schema_id) AS schema_name,
c.name AS column_name
FROM sys.tables AS t
INNER JOIN sys.columns c ON t.OBJECT_ID = c.OBJECT_ID
WHERE c.name LIKE '%' + @ColumnName + '%'
ORDER BY schema_name, table_name;
GO
/****** Object:  StoredProcedure [dbo].[Util_ResetIdentityColumn]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- Util_ResetIdentityColumn 'MFW_ShippingStatus', 4

ALTER PROCEDURE [dbo].[Util_ResetIdentityColumn]
@TblName varchar(256),
@NextNum int = 1

as

DBCC CHECKIDENT(@TblName, RESEED, @NextNum)

-- TRUNCATE TABLE @TblName
GO
/****** Object:  StoredProcedure [dbo].[Util_sLvmGetForeignKeyTables]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*
Util_sLvmGetForeignKeyTables 'Lvm_DeviceAction'
*/

ALTER PROCEDURE [dbo].[Util_sLvmGetForeignKeyTables]
@TblName varchar(300)
AS
BEGIN
	
SELECT t.name AS TableWithForeignKey, fk.constraint_column_id AS FK_PartNo, c.name AS ForeignKeyColumn
FROM sys.foreign_key_columns AS fk INNER JOIN
 sys.tables AS t ON fk.parent_object_id = t.object_id INNER JOIN
 sys.columns AS c ON fk.parent_object_id = c.object_id AND fk.parent_column_id = c.column_id
where fk.referenced_object_id = (select object_id from sys.tables where name = @TblName)
order by TableWithForeignKey, FK_PartNo

END

GO
/****** Object:  StoredProcedure [dbo].[Util_TableDependencyOrder]    Script Date: 4/25/2018 11:54:47 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Util_TableDependencyOrder
ALTER proc [dbo].[Util_TableDependencyOrder]

as
BEGIN
	with fk_tables as (
    select    s1.name as from_schema    
    ,        o1.Name as from_table    
    ,        s2.name as to_schema    
    ,        o2.Name as to_table    
    from    sys.foreign_keys fk    
    inner    join sys.objects o1    
    on        fk.parent_object_id = o1.object_id    
    inner    join sys.schemas s1    
    on        o1.schema_id = s1.schema_id    
    inner    join sys.objects o2    
    on        fk.referenced_object_id = o2.object_id    
    inner    join sys.schemas s2    
    on        o2.schema_id = s2.schema_id    
    /*For the purposes of finding dependency hierarchy       
        we're not worried about self-referencing tables*/
    where    not    (    s1.name = s2.name                 
            and        o1.name = o2.name)
)
,ordered_tables AS 
(        SELECT    s.name as schemaName
        ,        t.name as tableName
        ,        0 AS Level    
        FROM    (    select    *                
                    from    sys.tables                 
                    where    name <> 'sysdiagrams') t    
        INNER    JOIN sys.schemas s    
        on        t.schema_id = s.schema_id    
        LEFT    OUTER JOIN fk_tables fk    
        ON        s.name = fk.from_schema    
        AND        t.name = fk.from_table    
        WHERE    fk.from_schema IS NULL
        UNION    ALL
        SELECT    fk.from_schema
        ,        fk.from_table
        ,        ot.Level + 1    
        FROM    fk_tables fk    
        INNER    JOIN ordered_tables ot    
        ON        fk.to_schema = ot.schemaName    
        AND        fk.to_table = ot.tableName
)select    distinct    ot.schemaName
,        ot.tableName
,        ot.Level
from    ordered_tables ot
inner    join (
        select    schemaName
        ,        tableName
        ,        MAX(Level) maxLevel        
        from    ordered_tables        
        group    by schemaName,tableName
        ) mx
on        ot.schemaName = mx.schemaName
and        ot.tableName = mx.tableName
and        mx.maxLevel = ot.Level
order by ot.level desc

END

GO
