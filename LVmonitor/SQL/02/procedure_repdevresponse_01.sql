USE [LvMonitor]
GO
/****** Object:  StoredProcedure [dbo].[sLvm_RepDevResponse]    Script Date: 8/14/2018 4:10:58 AM ******/
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
	CASE WHEN @Sort = 'DateControlOn' THEN DateControlOn END, 
	CASE WHEN @Sort = 'ControlName desc' THEN ControlName END desc, 
	CASE WHEN @Sort = 'ControlName' THEN ControlName END,
	CASE WHEN @Sort = '' THEN DateControlOn END desc
)  AS Id, *
from
(
SELECT ISNULL(dp.DepartmentName, '') as DepartmentName, f.Number as FloorNumber, ISNULL(r.RoomNumber, '') as RoomNumber
, STRING_AGG(ISNULL((bd.Number + ISNULL(' (' + p.FullName + ')', '')), ''), ',') AS BedNumber
, ISNULL(d.DeviceName, '') as DeviceName, (select [dbo].fConvertTimeToHHMMSS(DATEDIFF(s, ml.DateControlOn, ml.DateControlOff), 's')) AS ResponseTime, ml.DateControlOn
, ISNULL(p1.FullName, '') as PatientName, ISNULL(bc.BeaconName, '') as BeaconName, ISNULL(e.EquipmentName, '') as EquipmentName, c.ControlName, c.ChartColor
FROM  Lvm_MonitorRecordLog AS ml LEFT OUTER JOIN
	Lvm_Beacon as bc on ml.BeaconId = bc.BeaconId LEFT OUTER JOIN
	Lvm_Patient as p1 on bc.PatientId = p1.PatientId LEFT OUTER JOIN
	Lvm_Equipment as e on bc.EquipmentId = e.EquipmentId LEFT OUTER JOIN
	Lvm_Device AS d ON ml.DeviceId = d.DeviceId INNER JOIN
	Lvm_DeviceTypeControl AS c ON (d.DeviceTypeId = c.DeviceTypeId or bc.DeviceTypeId = c.DeviceTypeId) AND ml.ControlId = c.ControlNumber INNER JOIN
	Lvm_Floor as f ON ml.FloorId = f.FloorId LEFT OUTER JOIN
	Lvm_Room AS r ON ml.RoomId = r.RoomId LEFT OUTER JOIN
	Lvm_BedLvm_Device as ldb ON d.DeviceId = ldb.Lvm_Device_DeviceId LEFT OUTER JOIN
	Lvm_Bed as bd ON ldb.Lvm_Bed_BedId = bd.BedId LEFT OUTER JOIN
	Lvm_PatientRecordLog AS pr ON bd.BedId = pr.BedId and pr.IsActive = 1 and pr.DatePatientAdmitted <= ml.DateControlOn and (pr.DatePatientDispatched is null or pr.DatePatientDispatched <= ml.DateControlOff) LEFT OUTER JOIN
	Lvm_Patient AS p ON pr.PatientId = p.PatientId LEFT OUTER JOIN
	Lvm_Department AS dp ON ml.DepartmentId = dp.DepartmentId
WHERE (ml.IsControlOn = 0) AND (ml.FacilityId = @FacilityId) 
AND (@FloorId = 0 or @FloorId is null or f.FloorId = @FloorId)
and (@HardwareTypeId is null or (@HardwareTypeId = 1 and ml.DeviceId is not null) or (@HardwareTypeId = 2 and ml.BeaconId is not null))
AND (((@DepartmentId = 0 or @DepartmentId is null) OR (@DepartmentId is null AND dp.DepartmentId is null)) or (dp.DepartmentId = @DepartmentId)) 
AND (ml.DateControlOn BETWEEN @DateFrom AND @DateTo) 
AND ((@ResponseTimeMin = 0) or (DATEDIFF(mi, ml.DateControlOn, ml.DateControlOff) > @ResponseTimeMin))
AND (((@BedList = '' and (f.FloorId = @FloorId or @FloorId = 0 or @FloorId is null)) and (@RoomList = '' and (f.FloorId = @FloorId or @FloorId = 0 or @FloorId is null))) or
--AND (((@BedList = '' and (f.FloorId = @FloorId or @FloorId = 0) and bd.Number is null) and (@RoomList = '' and (f.FloorId = @FloorId or @FloorId = 0) and bd.Number is null)) or
	bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) OR 
	r.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i))
--AND ((@RoomList='') or r.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i))
--AND ((@BedList='') or bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i))
--and (p.PatientId is NULL or p.PatientStatusId = 1)

--ORDER BY ResponseTime DESC
GROUP BY dp.DepartmentName, f.Number, r.RoomNumber, d.DeviceName, ml.DateControlOn, ml.DateControlOff, 
	DATEDIFF(mi, ml.DateControlOn, ml.DateControlOff), p1.FullName, e.EquipmentName, bc.BeaconName, c.ControlName, c.ChartColor
) as t
) as t2
where ((@ShowTop = 0) or (Id <= @ShowTop))  
and ((@PageNumber = 0) or Id BETWEEN (@PageNumber - 1) * @PageSize + 1 And (@PageNumber * @PageSize))

END
