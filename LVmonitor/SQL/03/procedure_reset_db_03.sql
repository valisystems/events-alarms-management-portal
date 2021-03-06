USE [LvMonitor]
GO
/****** Object:  StoredProcedure [dbo].[sLvm_Reset_DB]    Script Date: 9/23/2018 11:20:07 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*
sLvm_Reset DB
*/
 
ALTER PROCEDURE [dbo].[sLvm_Reset_DB] 
AS
BEGIN
SET NOCOUNT ON;

/*
* clear images
*/

delete Lvm_Image
delete Lvm_ImageType

exec Util_ResetIdentityColumn 'Lvm_Image',0
exec Util_ResetIdentityColumn 'Lvm_ImageType',0

/*
* clear templates
*/

delete Lvm_Template

exec Util_ResetIdentityColumn 'Lvm_Template',0

/*
* clear information tables
*/

delete Lvm_DeviceDiscovery
delete Lvm_CdrVodia
delete Lvm_DeviceAction
delete Lvm_BeaconAction
delete Lvm_DeviceRecord	 
delete Lvm_MonitorDeviceMap   
delete Lvm_BeaconRecord	 
delete Lvm_MonitorBeaconMap       
delete Lvm_MonitorRecord
delete Lvm_MonitorRecordLog	  
delete Lvm_PatientRecordLog
delete Lvm_Positioning
delete Lvm_PositioningHistory
delete Lvm_Beacon
delete Lvm_Patient
delete Lvm_Bed	   
delete Lvm_BedLvm_Device      
delete Lvm_Device
delete Lvm_CdrExtension
delete Lvm_Equipment
delete Lvm_Room	
delete Lvm_RecurringReportRunHistory
delete Lvm_RecurringReport	
delete Lvm_DevResponseTemplate
delete Lvm_CdrTemplate
delete Lvm_WebUrlConfig
delete Lvm_FacilityMonitor
delete Lvm_Department
delete Lvm_MobileClient
delete Lvm_RestrictedZone
delete Lvm_Floor
delete Lvm_DeviceActionTemplate
delete Lvm_DeviceRecordImage
delete Lvm_SecurityIp
delete Lvm_CdrPortSip_CallTarget
delete Lvm_DeviceTypeControl
delete Lvm_ResourceText
delete Lvm_UrlDebug
delete Lvm_CdrPortSip
delete Lvm_DeviceControlType
delete Lvm_DeviceType
delete Lvm_ResourceTextType
delete Lvm_License
delete Lvm_EmailIncoming
delete Lvm_EmailOutgoing
delete Lvm_EmailIncomingProtocols
delete Lvm_AuthenticationMethods


exec Util_ResetIdentityColumn 'Lvm_CdrVodia',0
exec Util_ResetIdentityColumn 'Lvm_DeviceAction',0
exec Util_ResetIdentityColumn 'Lvm_DeviceRecord',0
exec Util_ResetIdentityColumn 'Lvm_MonitorDeviceMap',0
exec Util_ResetIdentityColumn 'Lvm_BeaconAction',0
exec Util_ResetIdentityColumn 'Lvm_BeaconRecord',0
exec Util_ResetIdentityColumn 'Lvm_MonitorBeaconMap',0
exec Util_ResetIdentityColumn 'Lvm_MonitorRecord',0
exec Util_ResetIdentityColumn 'Lvm_MonitorRecordLog',0
exec Util_ResetIdentityColumn 'Lvm_Device',0
exec Util_ResetIdentityColumn 'Lvm_DeviceDiscovery',0
exec Util_ResetIdentityColumn 'Lvm_CdrExtension',0
exec Util_ResetIdentityColumn 'Lvm_Floor',0
exec Util_ResetIdentityColumn 'Lvm_Department',0
exec Util_ResetIdentityColumn 'Lvm_DeviceActionTemplate',0
exec Util_ResetIdentityColumn 'Lvm_DeviceRecordImage',0
exec Util_ResetIdentityColumn 'Lvm_Room',0
exec Util_ResetIdentityColumn 'Lvm_SecurityIp',0
exec Util_ResetIdentityColumn 'Lvm_CdrPortSip_CallTarget',0
exec Util_ResetIdentityColumn 'Lvm_DeviceTypeControl',0
exec Util_ResetIdentityColumn 'Lvm_ResourceText',0
exec Util_ResetIdentityColumn 'Lvm_UrlDebug',0
exec Util_ResetIdentityColumn 'Lvm_CdrPortSip',0
exec Util_ResetIdentityColumn 'Lvm_DeviceType',0
exec Util_ResetIdentityColumn 'Lvm_ResourceTextType',0
exec Util_ResetIdentityColumn 'Lvm_Bed',0	
exec Util_ResetIdentityColumn 'Lvm_Patient',0
exec Util_ResetIdentityColumn 'Lvm_PatientRecordLog',0	
exec Util_ResetIdentityColumn 'Lvm_DevResponseTemplate',0	
exec Util_ResetIdentityColumn 'Lvm_CdrTemplate',0	
exec Util_ResetIdentityColumn 'Lvm_RecurringReportRunHistory',0	
exec Util_ResetIdentityColumn 'Lvm_RecurringReport',0	
exec Util_ResetIdentityColumn 'Lvm_WebUrlConfig',0
exec Util_ResetIdentityColumn 'Lvm_Equipment',0
exec Util_ResetIdentityColumn 'Lvm_Beacon',0
exec Util_ResetIdentityColumn 'Lvm_Positioning',0
exec Util_ResetIdentityColumn 'Lvm_PositioningHistory',0
exec Util_ResetIdentityColumn 'Lvm_RestrictedZone', 0


INSERT [dbo].[Lvm_EmailIncoming] ([EmailIncomingId], [Type], [Server], [Username], [Password], [Port], [DeleteMessage], [MailboxDelayCheckSec], [Authentication], [SSL]) 
VALUES (1, '', '', '', '', 0, 0, 60, 'Password', 0)
INSERT [dbo].[Lvm_EmailOutgoing] ([EmailOutgoingId], [Email], [Password], [Server], [Port], [SSL], [Authentication]) 
VALUES (1, '', '', '', 0, 0, 'Password')

INSERT [dbo].[Lvm_EmailIncomingProtocols] ([EmailIncomingProtocols], [Name], [Description]) 
VALUES (1, 'POP3', 'POP3 Incoming Mail Server Protocol')
INSERT [dbo].[Lvm_EmailIncomingProtocols] ([EmailIncomingProtocols], [Name], [Description]) 
VALUES (2, 'IMAP', 'IMAP Incoming Mail Server Protocol')

INSERT [dbo].[Lvm_AuthenticationMethods] ([AuthenticationMethodsId], [Name], [Description]) 
VALUES (1, 'Password', 'Password authentication method')
INSERT [dbo].[Lvm_AuthenticationMethods] ([AuthenticationMethodsId], [Name], [Description]) 
VALUES (2, 'MD5', 'MD5 authentication method')
INSERT [dbo].[Lvm_AuthenticationMethods] ([AuthenticationMethodsId], [Name], [Description]) 
VALUES (3, 'NTLM', 'NTLM authentication method')
INSERT [dbo].[Lvm_AuthenticationMethods] ([AuthenticationMethodsId], [Name], [Description]) 
VALUES (4, 'Kerberos', 'Kerberos authentication method')
INSERT [dbo].[Lvm_AuthenticationMethods] ([AuthenticationMethodsId], [Name], [Description]) 
VALUES (5, 'None', 'No authentication method')
 
END


/****** Object:  StoredProcedure [dbo].[sLvm_BeaconActionReplaceTags]    Script Date: 4/24/2018 2:11:18 PM ******/
SET ANSI_NULLS ON
