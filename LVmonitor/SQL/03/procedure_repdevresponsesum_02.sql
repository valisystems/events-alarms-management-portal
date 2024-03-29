USE [LvMonitor]
GO
/****** Object:  StoredProcedure [dbo].[sLvm_RepDevResponseSum]    Script Date: 8/20/2018 5:15:33 AM ******/
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
@PageNumber int = 0, -- start with 1
@PageSize int = 0,
@HardwareTypeId int = null
AS
BEGIN
	SET NOCOUNT ON;
	declare @PatientName varchar(20)=''
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
	CASE WHEN @Sort = 'Bed desc' THEN BedStr END desc, 
	CASE WHEN @Sort = 'Bed' THEN BedStr END, 
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
	CASE WHEN @Sort = 'RespTimeAvg' THEN RespTimeAvg END,
	CASE WHEN @Sort = 'ControlName desc' THEN ControlName END desc, 
	CASE WHEN @Sort = 'ControlName' THEN ControlName END, 
	CASE WHEN @ResponseTimeMin = -1 THEN CallCount END desc,
	CASE WHEN @Sort = '' THEN RespTimeAvg END desc
)  AS Id, (Select TOP 1 LTRIM(RTRIM(Itm)) Fld FROM dbo.fSplit([BedStr],',') group by Itm) as Bed, *
from
(
SELECT ISNULL(dp.DepartmentName, '') as Department, f.Number [Floor], ISNULL(r.RoomNumber, '') as Room, STRING_AGG(ISNULL((bd.Number + ISNULL(' (' + p.FullName + ')', '')), ''), ',') AS BedStr
, ISNULL(d.DeviceName, '') as Device, ISNULL(bc.BeaconName, '') as Beacon, ISNULL(e.EquipmentName, '') as Equipment, ISNULL(p1.FullName, '') as Patient, COUNT(*) AS CallCount
, AVG(DATEDIFF(s, ml.DateControlOn, ml.DateControlOff)) as RespTimeAvg, c.ControlName, c.ChartColor
 --(select [dbo].fConvertTimeToHHMMSS(DATEDIFF(s, ml.DateControlOn, ml.DateControlOff), 's')) AS RespTimeAvg
FROM  Lvm_MonitorRecordLog AS ml LEFT OUTER JOIN
	Lvm_Beacon as bc on ml.BeaconId = bc.BeaconId LEFT OUTER JOIN
	Lvm_Patient as p1 on bc.PatientId = p1.PatientId LEFT OUTER JOIN
	Lvm_Equipment as e on bc.EquipmentId = e.EquipmentId LEFT OUTER JOIN
	Lvm_Device AS d ON ml.DeviceId = d.DeviceId INNER JOIN
	Lvm_DeviceTypeControl AS c ON (d.DeviceTypeId = c.DeviceTypeId or bc.DeviceTypeId = c.DeviceTypeId) AND ml.ControlId = c.ControlNumber INNER JOIN
	Lvm_Floor as f on ml.FloorId = f.FloorId LEFT OUTER JOIN
	Lvm_Room AS r ON ml.RoomId = r.RoomId LEFT OUTER JOIN
	Lvm_Department AS dp ON ml.DepartmentId = dp.DepartmentId LEFT OUTER JOIN
	Lvm_BedLvm_Device as ldb ON d.DeviceId = ldb.Lvm_Device_DeviceId LEFT OUTER JOIN
	Lvm_Bed as bd ON ldb.Lvm_Bed_BedId = bd.BedId LEFT OUTER JOIN
	Lvm_PatientRecordLog AS pr ON bd.BedId = pr.BedId and pr.IsActive = 1 and pr.DatePatientAdmitted <= ml.DateControlOn and (pr.DatePatientDispatched is null or pr.DatePatientDispatched <= ml.DateControlOff) LEFT OUTER JOIN
	Lvm_Patient AS p ON pr.PatientId = p.PatientId
WHERE (ml.IsControlOn = 0) AND (ml.FacilityId = @FacilityId) 
AND (@FloorId = 0 or @FloorId is null or f.FloorId = @FloorId)
and (@HardwareTypeId is null or (@HardwareTypeId = 1 and ml.DeviceId is not null) or (@HardwareTypeId = 2 and ml.BeaconId is not null))
AND (((@DepartmentId = 0 or @DepartmentId is null) OR (@DepartmentId is null AND dp.DepartmentId is null)) or (dp.DepartmentId = @DepartmentId)) 
AND (ml.DateControlOn BETWEEN @DateFrom AND @DateTo)
AND (((@BedList = '' and (f.FloorId = @FloorId or @FloorId = 0 or @FloorId is null) and bd.Number is null) and (@RoomList = '' and (f.FloorId = @FloorId or @FloorId = 0 or @FloorId is null) and bd.Number is null)) or
--AND (((@BedList = '' and (f.FloorId = @FloorId or @FloorId = 0) and bd.Number is null) and (@RoomList = '' and (f.FloorId = @FloorId or @FloorId = 0) and bd.Number is null)) or
	bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) OR 
	r.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i))
--AND ((@RoomList='') or r.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i))
--AND ((@BedList='') or bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) or bd.Number is NULL or bd.Number = '')
GROUP BY dp.DepartmentName, f.Number, r.RoomNumber, d.DeviceName, bc.BeaconName, e.EquipmentName, p1.FullName, c.ControlName, c.ChartColor
having ((@ResponseTimeMin = 0) or (AVG(DATEDIFF(mi, ml.DateControlOn, ml.DateControlOff)) > @ResponseTimeMin) or (@ResponseTimeMin = -1)) 
) as t
) as t2
where ((@ShowTop = 0) or (Id <= @ShowTop))  
and ((@PageNumber = 0) or Id BETWEEN (@PageNumber - 1) * @PageSize + 1 And (@PageNumber * @PageSize))

END
