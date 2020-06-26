USE [LvMonitor]
GO

/****** Object:  View [dbo].[vLvmControlImageByBeacon]    Script Date: 8/21/2018 11:56:42 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER VIEW [dbo].[vLvmControlImageByBeacon]
AS
SELECT        dbo.Lvm_Beacon.FacilityId, dbo.Lvm_Beacon.BeaconId, dbo.Lvm_DeviceTypeControl.ControlNumber, dbo.Lvm_DeviceTypeControl.ControlCode, dbo.Lvm_DeviceTypeControl.ControlImage, dbo.Lvm_DeviceTypeControl.ControlName
FROM            dbo.Lvm_DeviceTypeControl INNER JOIN
                         dbo.Lvm_DeviceType ON dbo.Lvm_DeviceTypeControl.DeviceTypeId = dbo.Lvm_DeviceType.DeviceTypeId INNER JOIN
                         dbo.Lvm_Beacon ON dbo.Lvm_DeviceType.DeviceTypeId = dbo.Lvm_Beacon.DeviceTypeId
GO


