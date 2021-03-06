USE [LvMonitor]
GO
/****** Object:  UserDefinedFunction [dbo].[fLvmDevImage]    Script Date: 9/21/2018 5:27:59 AM ******/
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
set @path = (SELECT TOP 1 ImagePath FROM Lvm_ImageType WHERE ImageTypeId = 2);
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