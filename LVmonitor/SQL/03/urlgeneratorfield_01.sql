USE [LvMonitor]
GO

INSERT INTO [dbo].[Lvm_UrlGeneratorField]
           ([UrlGeneratorTypeId]
           ,[FieldTitle]
           ,[FieldUrl]
           ,[DataType]
           ,[DefaultVal]
           ,[ListOrder]
           ,[Classes])
     VALUES
           (10
           ,'URL'
           ,'url'
           ,'String'
           ,'http://'
           ,0
           ,'')

INSERT INTO [dbo].[Lvm_UrlGeneratorField]
           ([UrlGeneratorTypeId]
           ,[FieldTitle]
           ,[FieldUrl]
           ,[DataType]
           ,[DefaultVal]
           ,[ListOrder]
           ,[Classes])
     VALUES
           (10
           ,'Dir'
           ,'dir'
           ,'String'
           ,''
           ,2
           ,'hidden')

INSERT INTO [dbo].[Lvm_UrlGeneratorField]
           ([UrlGeneratorTypeId]
           ,[FieldTitle]
           ,[FieldUrl]
           ,[DataType]
           ,[DefaultVal]
           ,[ListOrder]
           ,[Classes])
     VALUES
           (10
           ,'Port'
           ,'port'
           ,'int'
           ,''
           ,1
           ,'')

INSERT INTO [dbo].[Lvm_UrlGeneratorField]
           ([UrlGeneratorTypeId]
           ,[FieldTitle]
           ,[FieldUrl]
           ,[DataType]
           ,[DefaultVal]
           ,[ListOrder]
           ,[Classes])
     VALUES
           (10
           ,'Action'
           ,'action'
           ,'String'
           ,'stream'
           ,3
           ,'hidden')

INSERT INTO [dbo].[Lvm_UrlGeneratorField]
           ([UrlGeneratorTypeId]
           ,[FieldTitle]
           ,[FieldUrl]
           ,[DataType]
           ,[DefaultVal]
           ,[ListOrder]
           ,[Classes])
     VALUES
           (11
           ,'URL'
           ,'url'
           ,'String'
           ,'http://'
           ,0
           ,'')

INSERT INTO [dbo].[Lvm_UrlGeneratorField]
           ([UrlGeneratorTypeId]
           ,[FieldTitle]
           ,[FieldUrl]
           ,[DataType]
           ,[DefaultVal]
           ,[ListOrder]
           ,[Classes])
     VALUES
           (11
           ,'Dir'
           ,'dir'
           ,'String'
           ,''
           ,2
           ,'hidden')

INSERT INTO [dbo].[Lvm_UrlGeneratorField]
           ([UrlGeneratorTypeId]
           ,[FieldTitle]
           ,[FieldUrl]
           ,[DataType]
           ,[DefaultVal]
           ,[ListOrder]
           ,[Classes])
     VALUES
           (11
           ,'Port'
           ,'port'
           ,'int'
           ,''
           ,1
           ,'')

INSERT INTO [dbo].[Lvm_UrlGeneratorField]
           ([UrlGeneratorTypeId]
           ,[FieldTitle]
           ,[FieldUrl]
           ,[DataType]
           ,[DefaultVal]
           ,[ListOrder]
           ,[Classes])
     VALUES
           (11
           ,'Action'
           ,'action'
           ,'String'
           ,'snapshot'
           ,3
           ,'hidden')

INSERT INTO [dbo].[Lvm_UrlGeneratorField]
           ([UrlGeneratorTypeId]
           ,[FieldTitle]
           ,[FieldUrl]
           ,[DataType]
           ,[DefaultVal]
           ,[ListOrder]
           ,[Classes])
     VALUES
           (12
           ,'URL'
           ,'url'
           ,'String'
           ,'http://'
           ,0
           ,'')

INSERT INTO [dbo].[Lvm_UrlGeneratorField]
           ([UrlGeneratorTypeId]
           ,[FieldTitle]
           ,[FieldUrl]
           ,[DataType]
           ,[DefaultVal]
           ,[ListOrder]
           ,[Classes])
     VALUES
           (12
           ,'Dir'
           ,'dir'
           ,'String'
           ,'/cameras/{camera_id}/video'
           ,2
           ,'hidden replace_par')

INSERT INTO [dbo].[Lvm_UrlGeneratorField]
           ([UrlGeneratorTypeId]
           ,[FieldTitle]
           ,[FieldUrl]
           ,[DataType]
           ,[DefaultVal]
           ,[ListOrder]
           ,[Classes])
     VALUES
           (12
           ,'Port'
           ,'port'
           ,'int'
           ,''
           ,1
           ,'')

INSERT INTO [dbo].[Lvm_UrlGeneratorField]
           ([UrlGeneratorTypeId]
           ,[FieldTitle]
           ,[FieldUrl]
           ,[DataType]
           ,[DefaultVal]
           ,[ListOrder]
           ,[Classes])
     VALUES
           (12
           ,'Camera ID'
           ,'camera_id'
           ,'int'
           ,'0'
           ,3
           ,'')

INSERT INTO [dbo].[Lvm_UrlGeneratorField]
           ([UrlGeneratorTypeId]
           ,[FieldTitle]
           ,[FieldUrl]
           ,[DataType]
           ,[DefaultVal]
           ,[ListOrder]
           ,[Classes])
     VALUES
           (12
           ,'Keep Aspect Ratio'
           ,'keep_aspect_ratio'
           ,'Bool'
           ,'on'
           ,4
           ,'')

INSERT INTO [dbo].[Lvm_UrlGeneratorField]
           ([UrlGeneratorTypeId]
           ,[FieldTitle]
           ,[FieldUrl]
           ,[DataType]
           ,[DefaultVal]
           ,[ListOrder]
           ,[Classes])
     VALUES
           (12
           ,'Quality'
           ,'quality'
           ,'int'
           ,'35'
           ,5
           ,'')

INSERT INTO [dbo].[Lvm_UrlGeneratorField]
           ([UrlGeneratorTypeId]
           ,[FieldTitle]
           ,[FieldUrl]
           ,[DataType]
           ,[DefaultVal]
           ,[ListOrder]
           ,[Classes])
     VALUES
           (12
           ,'Resolution'
           ,'resolution'
           ,'String'
           ,'480x270'
           ,6
           ,'')

INSERT INTO [dbo].[Lvm_UrlGeneratorField]
           ([UrlGeneratorTypeId]
           ,[FieldTitle]
           ,[FieldUrl]
           ,[DataType]
           ,[DefaultVal]
           ,[ListOrder]
           ,[Classes])
     VALUES
           (12
           ,'Authorization'
           ,'authorization'
           ,'String'
           ,'Basic%20d2ViOg=='
           ,7
           ,'hidden')

INSERT INTO [dbo].[Lvm_UrlGeneratorField]
           ([UrlGeneratorTypeId]
           ,[FieldTitle]
           ,[FieldUrl]
           ,[DataType]
           ,[DefaultVal]
           ,[ListOrder]
           ,[Classes])
     VALUES
           (12
           ,'FPS'
           ,'fps'
           ,'int'
           ,'5'
           ,8
           ,'')

INSERT INTO [dbo].[Lvm_UrlGeneratorField]
           ([UrlGeneratorTypeId]
           ,[FieldTitle]
           ,[FieldUrl]
           ,[DataType]
           ,[DefaultVal]
           ,[ListOrder]
           ,[Classes])
     VALUES
           (13
           ,'URL'
           ,'url'
           ,'String'
           ,'http://'
           ,0
           ,'')

INSERT INTO [dbo].[Lvm_UrlGeneratorField]
           ([UrlGeneratorTypeId]
           ,[FieldTitle]
           ,[FieldUrl]
           ,[DataType]
           ,[DefaultVal]
           ,[ListOrder]
           ,[Classes])
     VALUES
           (13
           ,'Dir'
           ,'dir'
           ,'String'
           ,'/cameras/{camera_id}/image'
           ,2
           ,'hidden replace_par')

INSERT INTO [dbo].[Lvm_UrlGeneratorField]
           ([UrlGeneratorTypeId]
           ,[FieldTitle]
           ,[FieldUrl]
           ,[DataType]
           ,[DefaultVal]
           ,[ListOrder]
           ,[Classes])
     VALUES
           (13
           ,'Port'
           ,'port'
           ,'int'
           ,''
           ,1
           ,'')

INSERT INTO [dbo].[Lvm_UrlGeneratorField]
           ([UrlGeneratorTypeId]
           ,[FieldTitle]
           ,[FieldUrl]
           ,[DataType]
           ,[DefaultVal]
           ,[ListOrder]
           ,[Classes])
     VALUES
           (13
           ,'Camera ID'
           ,'camera_id'
           ,'int'
           ,'0'
           ,3
           ,'')

INSERT INTO [dbo].[Lvm_UrlGeneratorField]
           ([UrlGeneratorTypeId]
           ,[FieldTitle]
           ,[FieldUrl]
           ,[DataType]
           ,[DefaultVal]
           ,[ListOrder]
           ,[Classes])
     VALUES
           (13
           ,'Keep Aspect Ratio'
           ,'keep_aspect_ratio'
           ,'Bool'
           ,'on'
           ,4
           ,'')

INSERT INTO [dbo].[Lvm_UrlGeneratorField]
           ([UrlGeneratorTypeId]
           ,[FieldTitle]
           ,[FieldUrl]
           ,[DataType]
           ,[DefaultVal]
           ,[ListOrder]
           ,[Classes])
     VALUES
           (13
           ,'Quality'
           ,'quality'
           ,'int'
           ,'75'
           ,5
           ,'')

INSERT INTO [dbo].[Lvm_UrlGeneratorField]
           ([UrlGeneratorTypeId]
           ,[FieldTitle]
           ,[FieldUrl]
           ,[DataType]
           ,[DefaultVal]
           ,[ListOrder]
           ,[Classes])
     VALUES
           (13
           ,'Resolution'
           ,'resolution'
           ,'String'
           ,'480x270'
           ,6
           ,'')

INSERT INTO [dbo].[Lvm_UrlGeneratorField]
           ([UrlGeneratorTypeId]
           ,[FieldTitle]
           ,[FieldUrl]
           ,[DataType]
           ,[DefaultVal]
           ,[ListOrder]
           ,[Classes])
     VALUES
           (13
           ,'Authorization'
           ,'authorization'
           ,'String'
           ,'Basic%20d2ViOg=='
           ,7
           ,'hidden')

GO


