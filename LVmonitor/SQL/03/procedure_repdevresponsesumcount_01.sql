USE [LvMonitor]
GO
/****** Object:  StoredProcedure [dbo].[sLvm_RepDevResponseSumCount]    Script Date: 8/20/2018 5:15:40 AM ******/
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
AND (((@BedList = '' and (f.FloorId = @FloorId or @FloorId = 0 or @FloorId is null) and bd.Number is null) and (@RoomList = '' and (f.FloorId = @FloorId or @FloorId = 0 or @FloorId is null) and bd.Number is null)) or
--AND (((@BedList = '' and (f.FloorId = @FloorId or @FloorId = 0) and bd.Number is null) and (@RoomList = '' and (f.FloorId = @FloorId or @FloorId = 0) and bd.Number is null)) or
	bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) OR 
	r.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i))
--and ((@RoomList='') or r.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i))
--and ((@BedList='') or bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) or bd.Number is NULL or bd.Number = '') 
GROUP BY dp.DepartmentName, f.Number, r.RoomNumber, d.DeviceName, bc.BeaconName, e.EquipmentName, p1.FullName
having ((@ResponseTimeMin = 0) or (AVG(DATEDIFF(mi, ml.DateControlOn, ml.DateControlOff)) > @ResponseTimeMin) or (@ResponseTimeMin = -1)) 
) as t

if ((@ShowTop > 0) and (@RecCount > @ShowTop)) set @RecCount = @ShowTop


select @RecCount RecCount

END
