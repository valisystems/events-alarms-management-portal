USE [LvMonitor]
GO
/****** Object:  StoredProcedure [dbo].[sLvm_RepCdrRecChart]    Script Date: 10/19/2018 1:38:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- sLvm_RepCdrRecChart 1, 1, '2017-01-01', '2018-03-22', 0, 0, '', '',  '103,104', -1
-- sLvm_RepCdrRecChart 1, 0, '2017-01-01', '2018-03-22', 0, 0, '', '',  '', -1
-- sLvm_RepCdrRecChart 2, 0, '2017-06-08', '2017-06-13', 0, 0, '', '',  '', -1
ALTER PROCEDURE [dbo].[sLvm_RepCdrRecChart]
@FacilityId int,
@DateFrom datetime,
@DateTo datetime,
@RingDurationMin int,
@CallDurationMin int,

@From varchar(100),
@To varchar(100),

@Direction int, -- =-1
@IsNurseCall bit
AS
BEGIN
	SET NOCOUNT ON;

if (@DateTo = (CONVERT(date, @DateTo))) set @DateTo=DATEADD(d, 1, @DateTo)
set @RingDurationMin = @RingDurationMin*1000;
declare @Tbl table (Id int, DateCall datetime, Calls int, CallStatus varchar(100), CallRingDuration decimal, CallTalkDuration decimal)

declare @CdrTypeId int;
SELECT @CdrTypeId = CdrTypeId FROM  Lvm_Facility WHERE (FacilityId = @FacilityId)
--select @CdrTypeId
if (@CdrTypeId=1) -- PortSip
	insert into  @Tbl
	SELECT ROW_NUMBER() OVER (ORDER BY c.CallStartTime, c.CallStatus)  AS Id, c.CallStartTime DateCall,  1 Calls, c.CallStatus, c.CallRingDuration, c.CallTalkTime
	FROM Lvm_CdrPortSip AS c
	WHERE (c.FacilityId = @FacilityId) 
	and ((@Direction = -1) or ((@Direction = 0) and (c.CallDirection = 'Outbound')) or ((@Direction = 1) and (c.CallDirection = 'Inbound')))
	AND ((@RingDurationMin = 0) or (c.CallRingDuration >= @RingDurationMin))
	AND ((@CallDurationMin = 0) or (c.CallTalkTime >= @CallDurationMin))
	AND ((@From = '') or (c.[Caller] = @From))
	AND ((@To = '') or (c.Callee = @To))
	AND ((@IsNurseCall = 1 and c.[IsNurseCall] = @IsNurseCall) or @IsNurseCall = 0)
else if (@CdrTypeId=2) -- Vodia
	insert into  @Tbl
	SELECT ROW_NUMBER() OVER (ORDER BY c.TimeStart /*, c.CallStatus*/)  AS Id, c.TimeStart DateCall,  1 Calls, '' CallStatus, c.RingDuration, c.Duration
	FROM  Lvm_CdrVodia AS c
	WHERE (c.FacilityId = @FacilityId) 
	and ((@Direction = -1) or (c.Direction = @Direction))
	AND (c.TimeStart BETWEEN @DateFrom AND @DateTo) 
	AND ((@RingDurationMin = 0) or (c.RingDuration >= @RingDurationMin))
	AND ((@CallDurationMin = 0) or (c.Duration >= @CallDurationMin))
	AND ((@From = '') or (c.[From] = @From))
	AND ((@To = '') or (c.[To] = @To))
	AND ((@IsNurseCall = 1 and c.[IsNurseCall] = @IsNurseCall) or @IsNurseCall = 0)

declare @DayDiff int; set @DayDiff = DATEDIFF(d, @DateFrom, @DateTo)

--select @DayDiff d, * from @Tbl

if (@DayDiff<3)			-- per hour
	select ROW_NUMBER() OVER (ORDER BY DateCall, CallStatus) AS Id, DateCall, Calls, CallStatus, CallRingDuration, CallTalkDuration
	from
	(
	select dateadd(hour, datediff(hour, 0, DateCall), 0) as DateCall, 
	count(*) AS Calls, CallStatus, AVG(CallRingDuration)/1000 as CallRingDuration, AVG(CallTalkDuration) as CallTalkDuration
	from @Tbl
	GROUP BY dateadd(hour, datediff(hour, 0, DateCall), 0), CallStatus
	) t
else if (@DayDiff<32)	--per day
	select ROW_NUMBER() OVER (ORDER BY DateCall, CallStatus) AS Id, DateCall, Calls, CallStatus, CallRingDuration, CallTalkDuration
	from
	(
	select CONVERT(date, DateCall) as DateCall, 
	count(*) AS Calls, CallStatus, AVG(CallRingDuration)/1000 as CallRingDuration, AVG(CallTalkDuration) as CallTalkDuration
	from @Tbl
	GROUP BY CONVERT(date, DateCall), CallStatus
	) t
else if (@DayDiff<92)	-- per week
	select ROW_NUMBER() OVER (ORDER BY DateCall, CallStatus) AS Id, DateCall, Calls, CallStatus, CallRingDuration, CallTalkDuration
	from
	(
	select CONVERT(date,DATEADD(dd, 7-(DATEPART(dw, DateCall)), DateCall)) as DateCall, 
	count(*) AS Calls, CallStatus, AVG(CallRingDuration)/1000 as CallRingDuration, AVG(CallTalkDuration) as CallTalkDuration
	from @Tbl
	GROUP BY CONVERT(date,DATEADD(dd, 7-(DATEPART(dw, DateCall)), DateCall)), CallStatus
	) t
else					-- per month
	select ROW_NUMBER() OVER (ORDER BY DateCall, CallStatus) AS Id, DateCall, Calls, CallStatus, CallRingDuration, CallTalkDuration
	from
	(
	select CAST(
			  CAST(year(DateCall) AS VARCHAR(4)) +
			  RIGHT('0' + CAST(MONTH(DateCall) AS VARCHAR(2)), 2) +
			  RIGHT('0' + CAST(1 AS VARCHAR(2)), 2) 
		   AS DATETIME) as DateCall, 
	count(*) AS Calls, CallStatus, AVG(CallRingDuration)/1000 as CallRingDuration, AVG(CallTalkDuration) as CallTalkDuration
	from @Tbl
	GROUP BY year(DateCall) , MONTH(DateCall), CallStatus
	) t
END
