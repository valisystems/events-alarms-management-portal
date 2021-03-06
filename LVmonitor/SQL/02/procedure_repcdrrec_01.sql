USE [LvMonitor]
GO
/****** Object:  StoredProcedure [dbo].[sLvm_RepCdrRec]    Script Date: 8/14/2018 4:36:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- sLvm_RepCdrRec 1, 1, '2017-01-01', '2018-03-22', 0, 0, '', '',  '103,104', -1 '', 1, 100
-- sLvm_RepCdrRec 1, 0, '2017-01-01', '2018-03-22', 0, 0, '', '',  '', -1 '', 1, 100
-- sLvm_RepCdrRec 2, 0, '2017-01-01', '2018-03-22', 0, 0, '', '',  '', -1 '', 1, 100
ALTER PROCEDURE [dbo].[sLvm_RepCdrRec]
@FacilityId int,
@DateFrom datetime,
@DateTo datetime,
@RingDurationMin int,
@CallDurationMin int,

@From varchar(100),
@To varchar(100),

@Direction int, -- =-1

@Sort varchar(50)=''
,
@PageNumber int = 0, -- strart with 1
@PageSize int = 0
AS
BEGIN
	SET NOCOUNT ON;

if (@DateTo = (CONVERT(date, @DateTo))) set @DateTo=DATEADD(d, 1, @DateTo)
set @RingDurationMin = @RingDurationMin*1000;
declare @Tbl table (RecId int, CallStart datetime, CallEnd datetime, ProviderFileName varchar(200), SystemFileName varchar(200), Direction varchar(50), 
	[From] varchar(50), [To] varchar(50), CallStatus varchar(50), RingDuration int, TalkTime int, RecordLocation varchar(500) )

declare @CdrTypeId int;
SELECT @CdrTypeId = CdrTypeId FROM  Lvm_Facility WHERE (FacilityId = @FacilityId)
--select @CdrTypeId

--SELECT *
--	FROM  Lvm_CdrVodia

if (@CdrTypeId=1) -- PortSip
	insert into @Tbl (RecId, CallStart, CallEnd, ProviderFileName, SystemFileName, Direction, [From], [To], CallStatus, RingDuration, TalkTime, RecordLocation)
	SELECT c.CdrPortSipId, c.CallStartTime, c.CallEndedTime, c.ProviderFileName, c.SystemFileName, c.CallDirection, c.Caller, c.Callee, c.CallStatus, c.CallRingDuration, c.CallTalkTime, c.RecordingLocation
	FROM Lvm_CdrPortSip AS c
	WHERE (c.FacilityId = @FacilityId) 
	and ((@Direction = -1) or ((@Direction = 0) and (c.CallDirection = 'Outbound')) or ((@Direction = 1) and (c.CallDirection = 'Inbound')))
	AND ((@RingDurationMin = 0) or (c.CallRingDuration >= @RingDurationMin))
	AND ((@CallDurationMin = 0) or (c.CallTalkTime >= @CallDurationMin))
	AND ((@From = '') or (c.[Caller] = @From))
	AND ((@To = '') or (c.Callee = @To))
	GROUP BY c.CdrPortSipId, c.CallStartTime, c.CallEndedTime, c.ProviderFileName, c.SystemFileName, c.CallDirection, c.Caller, c.Callee, c.CallStatus, c.CallRingDuration, c.CallTalkTime, c.RecordingLocation
else if (@CdrTypeId=2) -- Vodia
	insert into @Tbl (RecId, CallStart, CallEnd, ProviderFileName, SystemFileName, Direction, [From], [To], CallStatus, RingDuration, TalkTime, RecordLocation)
	SELECT c.CdrVodiaId, c.TimeStart, c.TimeEnd, c.ProviderFileName, c.SystemFileName
	, case c.Direction when 1 then 'Inbound' else 'Outbound' end Direction, c.[From], c.[To], '', -- c.Quality -- Status ???
	c.RingDuration, c.Duration, c.RecordLocation
	FROM  Lvm_CdrVodia AS c
	WHERE (c.FacilityId = @FacilityId) 
	and ((@Direction = -1) or (c.Direction = @Direction))
	AND (c.TimeStart BETWEEN @DateFrom AND @DateTo) 
	AND ((@RingDurationMin = 0) or (c.RingDuration >= @RingDurationMin))
	AND ((@CallDurationMin = 0) or (c.Duration >= @CallDurationMin))
	AND ((@From = '') or (c.[From] = @From))
	AND ((@To = '') or (c.[To] = @To))
	GROUP BY c.CdrVodiaId, c.TimeStart, c.TimeEnd, c.ProviderFileName, c.SystemFileName, c.RingDuration, c.Duration, c.Direction, c.[From], c.[To], c.RecordLocation
select *
from
(
select ROW_NUMBER() OVER (ORDER BY 
	CASE WHEN @Sort = 'CallStart desc' THEN CallStart END desc, 
	CASE WHEN @Sort = 'CallStart' THEN CallStart END, 
	CASE WHEN @Sort = 'CallEnd desc' THEN CallEnd END desc, 
	CASE WHEN @Sort = 'CallEnd' THEN CallEnd END, 
	CASE WHEN @Sort = 'Direction desc' THEN Direction END desc, 
	CASE WHEN @Sort = 'Direction' THEN Direction END, 
	CASE WHEN @Sort = '[From] desc' THEN [From] END desc, 
	CASE WHEN @Sort = '[From]' THEN [From] END, 
	CASE WHEN @Sort = '[To] desc' THEN [To] END desc, 
	CASE WHEN @Sort = '[To]' THEN [To] END,
	CASE WHEN @Sort = 'CallStatus desc' THEN CallStatus END desc, 
	CASE WHEN @Sort = 'CallStatus' THEN CallStatus END, 
	CASE WHEN @Sort = 'RingDuration desc' THEN RingDuration END desc, 
	CASE WHEN @Sort = 'RingDuration' THEN RingDuration END, 
	CASE WHEN @Sort = 'TalkTime desc' THEN TalkTime END desc, 
	CASE WHEN @Sort = 'TalkTime' THEN TalkTime END, 
	CASE WHEN @Sort = '' THEN CallStart END desc
)  AS Id, *
from
(
SELECT * FROM  @Tbl
) as t
) as t2
where ((@PageNumber = 0) or Id BETWEEN (@PageNumber - 1) * @PageSize + 1 And (@PageNumber * @PageSize))

END
