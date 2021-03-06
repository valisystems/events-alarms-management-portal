USE [LvMonitor]
GO
/****** Object:  StoredProcedure [dbo].[sLvm_FilterDevices]    Script Date: 8/6/2018 10:39:15 PM ******/
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
	[IsSupportCancelAllAlarms] AS [IsSupportCancelAllAlarms],
	[DeviceCode] AS [DeviceCode],
	[RoomId] AS [RoomId], 
	[DeviceName] AS [DeviceName],
	[FacilityId] AS [FacilityId], 
	[DepartmentId] AS [DepartmentId], 
	[FloorId] AS [FloorId],
	[ImageId] AS [ImageId],
	[MediaTypeId] AS [MediaTypeId],
	[CdrExtensionId] AS [CdrExtensionId],
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
		[Extent1].[IsSupportCancelAllAlarms] AS [IsSupportCancelAllAlarms],
		[Extent1].[RoomId] AS [RoomId],
		[Extent1].[FacilityId] AS [FacilityId],
		[Extent1].[ImageId] AS [ImageId],
		[Extent1].[MediaTypeId] AS [MediaTypeId],
		[Extent1].[CdrExtensionId] AS [CdrExtensionId],
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
