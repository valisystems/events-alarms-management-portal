USE [LvMonitor]
GO

/****** Object:  View [dbo].[vLvmControlImageByDev]    Script Date: 8/21/2018 11:57:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[vLvmControlImageByDev]
AS
SELECT dbo.Lvm_Device.FacilityId, dbo.Lvm_Device.DeviceId, dbo.Lvm_DeviceTypeControl.ControlNumber, dbo.Lvm_DeviceTypeControl.ControlCode, dbo.Lvm_DeviceTypeControl.ControlImage, dbo.Lvm_DeviceTypeControl.ControlName
FROM  dbo.Lvm_DeviceTypeControl INNER JOIN
         dbo.Lvm_DeviceType ON dbo.Lvm_DeviceTypeControl.DeviceTypeId = dbo.Lvm_DeviceType.DeviceTypeId INNER JOIN
         dbo.Lvm_Device ON dbo.Lvm_DeviceType.DeviceTypeId = dbo.Lvm_Device.DeviceTypeId
GO


