USE [LvMonitor]
GO
/****** Object:  StoredProcedure [dbo].[sLvm_RepCdrRecCount]    Script Date: 10/21/2018 4:18:17 AM ******/
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
@FloorId int,
@RoomList varchar(4000),
@BedList varchar(8000),
@DateFrom datetime,
@DateTo datetime,
@RingDurationMin int,
@CallDurationMin int,

@From varchar(100),
@To varchar(100),

@Direction int, -- =-1
@IsNurseCall bit,
@RecCount int OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

if (@DateTo = (CONVERT(date, @DateTo))) set @DateTo=DATEADD(d, 1, @DateTo)

set @RingDurationMin = @RingDurationMin*1000;
set @RecCount=0;

declare @CdrTypeId int;
SELECT @CdrTypeId = CdrTypeId FROM  Lvm_Facility WHERE (FacilityId = @FacilityId)
--select @CdrTypeId
if (@CdrTypeId=1) -- PortSip
	SELECT @RecCount = COUNT(*)
	FROM (
	SELECT c.CdrPortSipId, c.CallStartTime, c.CallEndedTime, c.CallDirection, c.Caller, c.Callee, c.CallStatus, c.CallRingDuration, c.CallTalkTime
	FROM Lvm_CdrPortSip AS c LEFT OUTER JOIN
	Lvm_Beacon as bc on c.BeaconId = bc.BeaconId LEFT OUTER JOIN
	Lvm_Patient as p1 on bc.PatientId = p1.PatientId LEFT OUTER JOIN
	Lvm_Equipment as e on bc.EquipmentId = e.EquipmentId LEFT OUTER JOIN
	Lvm_Device AS d ON c.DeviceId = d.DeviceId LEFT OUTER JOIN
	Lvm_Floor as f ON c.FloorId = f.FloorId LEFT OUTER JOIN
	Lvm_Room AS r ON c.RoomId = r.RoomId LEFT OUTER JOIN
	Lvm_BedLvm_Device as ldb ON d.DeviceId = ldb.Lvm_Device_DeviceId LEFT OUTER JOIN
	Lvm_Bed as bd ON ldb.Lvm_Bed_BedId = bd.BedId LEFT OUTER JOIN
	Lvm_Department AS dp ON c.DepartmentId = dp.DepartmentId
	WHERE (c.FacilityId = @FacilityId) 
	AND (@FloorId = 0 or @FloorId is null or f.FloorId = @FloorId)
	AND (((@DepartmentId = 0 or @DepartmentId is null) OR (@DepartmentId is null AND dp.DepartmentId is null)) or (dp.DepartmentId = @DepartmentId)) 
	AND (((@BedList = '' and (f.FloorId = @FloorId or @FloorId = 0 or @FloorId is null)) and (@RoomList = '' and (f.FloorId = @FloorId or @FloorId = 0 or @FloorId is null))) or
	bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) OR 
	r.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i))
	and ((@Direction = -1) or ((@Direction = 0) and (c.CallDirection = 'Outbound')) or ((@Direction = 1) and (c.CallDirection = 'Inbound')))
	AND ((@RingDurationMin = 0) or (c.CallRingDuration >= @RingDurationMin))
	AND ((@CallDurationMin = 0) or (c.CallTalkTime >= @CallDurationMin))
	AND ((@From = '') or (c.[Caller] = @From))
	AND ((@To = '') or (c.Callee = @To))
	AND ((@IsNurseCall = 1 and c.[IsNurseCall] = @IsNurseCall) or @IsNurseCall = 0)
	GROUP BY c.CdrPortSipId, c.CallStartTime, c.CallEndedTime, c.CallDirection, c.Caller, c.Callee, c.CallStatus, c.CallRingDuration, c.CallTalkTime
	) as t
else if (@CdrTypeId=2) -- Vodia
	SELECT @RecCount = COUNT(*)
	from (
	select c.CdrVodiaId, c.TimeStart, c.TimeEnd, c.RingDuration, c.Duration, c.Direction, c.[From], c.[To]
	FROM  Lvm_CdrVodia AS c LEFT OUTER JOIN
	Lvm_Beacon as bc on c.BeaconId = bc.BeaconId LEFT OUTER JOIN
	Lvm_Patient as p1 on bc.PatientId = p1.PatientId LEFT OUTER JOIN
	Lvm_Equipment as e on bc.EquipmentId = e.EquipmentId LEFT OUTER JOIN
	Lvm_Device AS d ON c.DeviceId = d.DeviceId LEFT OUTER JOIN
	Lvm_Floor as f ON c.FloorId = f.FloorId LEFT OUTER JOIN
	Lvm_Room AS r ON c.RoomId = r.RoomId LEFT OUTER JOIN
	Lvm_BedLvm_Device as ldb ON d.DeviceId = ldb.Lvm_Device_DeviceId LEFT OUTER JOIN
	Lvm_Bed as bd ON ldb.Lvm_Bed_BedId = bd.BedId LEFT OUTER JOIN
	Lvm_Department AS dp ON c.DepartmentId = dp.DepartmentId
	WHERE (c.FacilityId = @FacilityId)
	AND (@FloorId = 0 or @FloorId is null or f.FloorId = @FloorId)
	AND (((@DepartmentId = 0 or @DepartmentId is null) OR (@DepartmentId is null AND dp.DepartmentId is null)) or (dp.DepartmentId = @DepartmentId)) 
	AND (((@BedList = '' and (f.FloorId = @FloorId or @FloorId = 0 or @FloorId is null)) and (@RoomList = '' and (f.FloorId = @FloorId or @FloorId = 0 or @FloorId is null))) or
	bd.Number in (SELECT i.Itm FROM dbo.fSplit(@BedList,',') AS i) OR 
	r.RoomNumber in (SELECT i.Itm FROM dbo.fSplit(@RoomList,',') AS i))
	and ((@Direction = -1) or (c.Direction = @Direction))
	AND (c.TimeStart BETWEEN @DateFrom AND @DateTo) 
	AND ((@RingDurationMin = 0) or (c.RingDuration >= @RingDurationMin))
	AND ((@CallDurationMin = 0) or (c.Duration >= @CallDurationMin))
	AND ((@From = '') or (c.[From] = @From))
	AND ((@To = '') or (c.[To] = @To))
	AND ((@IsNurseCall = 1 and c.[IsNurseCall] = @IsNurseCall) or @IsNurseCall = 0)
	GROUP BY c.CdrVodiaId, c.TimeStart, c.TimeEnd, c.RingDuration, c.Duration, c.Direction, c.[From], c.[To]
	) as t
select @RecCount RecCount

END
