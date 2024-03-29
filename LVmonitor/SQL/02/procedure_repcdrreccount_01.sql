USE [LvMonitor]
GO
/****** Object:  StoredProcedure [dbo].[sLvm_RepCdrRecCount]    Script Date: 10/19/2018 1:38:37 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- sLvm_RepCdrRecCount 1, 1, '2017-01-01', '2018-03-22', 0, 0, '', '',  '103,104', -1
-- sLvm_RepCdrRecCount 1, 0, '2017-01-01', '2018-03-22', 0, 0, '', '',  '', -1
-- sLvm_RepCdrRecCount 2, 0, '2017-01-01', '2018-03-22', 0, 0, '', '',  '', -1
ALTER PROCEDURE [dbo].[sLvm_RepCdrRecCount]
@FacilityId int,
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
	FROM Lvm_CdrPortSip AS c
	WHERE (c.FacilityId = @FacilityId) 
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
	FROM  Lvm_CdrVodia AS c
	WHERE (c.FacilityId = @FacilityId) 
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
