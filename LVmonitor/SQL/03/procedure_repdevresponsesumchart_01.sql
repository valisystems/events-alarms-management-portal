USE [LvMonitor]
GO
/****** Object:  StoredProcedure [dbo].[sLvm_RepDevResponseSumChart]    Script Date: 8/20/2018 5:15:37 AM ******/
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
	Lvm_DeviceTypeControl AS c ON (d.DeviceTypeId = c.DeviceTypeId or bc.DeviceTypeId = c.DeviceTypeId) AND l.ControlId = c.ControlNumber INNER JOIN
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
	AND ((@ResponseTimeMin = 0) or (DATEDIFF(mi, l.DateControlOn, l.DateControlOff) > @ResponseTimeMin) or (@ResponseTimeMin = -1)) 
	AND (((@BedList = '' and (f.FloorId = @FloorId or @FloorId = 0 or @FloorId is null) and bd.Number is null) and (@RoomList = '' and (f.FloorId = @FloorId or @FloorId = 0 or @FloorId is null) and bd.Number is null)) or
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
	Lvm_DeviceTypeControl AS c ON (d.DeviceTypeId = c.DeviceTypeId or bc.DeviceTypeId = c.DeviceTypeId) AND l.ControlId = c.ControlNumber INNER JOIN
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
	AND ((@ResponseTimeMin = 0) or (DATEDIFF(mi, l.DateControlOn, l.DateControlOff) > @ResponseTimeMin) or (@ResponseTimeMin = -1)) 
	AND (((@BedList = '' and (f.FloorId = @FloorId or @FloorId = 0 or @FloorId is null) and bd.Number is null) and (@RoomList = '' and (f.FloorId = @FloorId or @FloorId = 0 or @FloorId is null) and bd.Number is null)) or
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
	Lvm_DeviceTypeControl AS c ON (d.DeviceTypeId = c.DeviceTypeId or bc.DeviceTypeId = c.DeviceTypeId) AND l.ControlId = c.ControlNumber INNER JOIN
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
	AND ((@ResponseTimeMin = 0) or (DATEDIFF(mi, l.DateControlOn, l.DateControlOff) > @ResponseTimeMin) or (@ResponseTimeMin = -1)) 
	AND (((@BedList = '' and (f.FloorId = @FloorId or @FloorId = 0 or @FloorId is null) and bd.Number is null) and (@RoomList = '' and (f.FloorId = @FloorId or @FloorId = 0 or @FloorId is null) and bd.Number is null)) or
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
	Lvm_DeviceTypeControl AS c ON (d.DeviceTypeId = c.DeviceTypeId or bc.DeviceTypeId = c.DeviceTypeId) AND l.ControlId = c.ControlNumber INNER JOIN
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
	AND ((@ResponseTimeMin = 0) or (DATEDIFF(mi, l.DateControlOn, l.DateControlOff) > @ResponseTimeMin) or (@ResponseTimeMin = -1)) 
	AND (((@BedList = '' and (f.FloorId = @FloorId or @FloorId = 0 or @FloorId is null) and bd.Number is null) and (@RoomList = '' and (f.FloorId = @FloorId or @FloorId = 0 or @FloorId is null) and bd.Number is null)) or
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
