USE [LvMonitor]
GO

INSERT INTO [dbo].[Lvm_UrlGeneratorType]
           ([UrlGeneratorType]
           ,[ListOrder])
     VALUES
           ('Patient Station Stream'
           ,9)

INSERT INTO [dbo].[Lvm_UrlGeneratorType]
           ([UrlGeneratorType]
           ,[ListOrder])
     VALUES
           ('Patient Station Image'
           ,10)

INSERT INTO [dbo].[Lvm_UrlGeneratorType]
           ([UrlGeneratorType]
           ,[ListOrder])
     VALUES
           ('CCTV Camera Stream'
           ,11)

INSERT INTO [dbo].[Lvm_UrlGeneratorType]
           ([UrlGeneratorType]
           ,[ListOrder])
     VALUES
           ('CCTV Camera Image'
           ,12)
GO


