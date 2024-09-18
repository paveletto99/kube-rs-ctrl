IF NOT EXISTS(SELECT * FROM sys.databases WHERE name = 'CONFIG_KIND')
BEGIN
    CREATE DATABASE CONFIG_KIND
END
GO

IF NOT EXISTS(SELECT * FROM sys.databases WHERE name = 'TEST_KIND')
BEGIN
    CREATE DATABASE TEST_KIND
END
GO

USE CONFIG_KIND
GO

IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='TENANT' and xtype='U')
BEGIN
    CREATE TABLE [dbo].[TENANT](
        [Id] [uniqueidentifier] NOT NULL,
        [CREATION_DATE] [datetime] NULL,
        [CREATION_DATE_ACCURACY] [nvarchar](5) NULL,
        [CREATED_BY] [uniqueidentifier] NULL,
        [LAST_MODIFICATION_DATE] [datetime] NULL,
        [LAST_MODIFICATION_DATE_ACCURACY] [nvarchar](5) NULL,
        [MODIFIED_BY] [uniqueidentifier] NULL,
        [CREATOR_BUSINESS_UNIT] [uniqueidentifier] NULL,
        [OWNER_BUSINESS_UNIT] [uniqueidentifier] NULL,
        [ENTITY_STATUS] [nvarchar](50) NULL,
        [PARENTID] [uniqueidentifier] NULL,
        [DESCRIPTION] [nvarchar](max) NULL,
        [STATUS] [nvarchar](50) NULL,
        [NAME] [nvarchar](30) NULL,
        [SQL_CONNECTION_STRING] [nvarchar](1000) NULL,
        [SQL_DATA_PROVIDER] [nvarchar](50) NULL,
        [IS_DEFAULT] [nvarchar](50) NULL,
        [NOSQL_CONNECTION_STRING] [nvarchar](1000) NULL,
        [NOSQL_DATA_PROVIDER] [nvarchar](50) NULL,
        [CUSTOMIZATIONS] [nvarchar](200) NULL,
        [READ_LOGS_ENABLED] [nvarchar](50) NULL,
        [FILE_ACCESS_PROVIDER] [nvarchar](200) NULL,
        [FILE_ACCESS_CONNECTION_STRING] [nvarchar](1000) NULL,
        [FILE_ACCESS_BASE_PATH] [nvarchar](200) NULL,
        [ENABLED_SERVICES] [nvarchar](200) NULL,
        [ADMIN_EMAIL] [nvarchar](200) NULL,
        [OWNER] [nvarchar](200) NULL,
        [ENABLED_MICROSERVICES] [nvarchar](200) NULL,
        [COLUMN_ENCRYPTION_KEY] [nvarchar](200) NULL,
        [LOGGING_DURATION] [float] NULL,
        [LOGGING_DURATION_UM] [nvarchar](50) NULL,
        [TENANT_ENABLE_LOGGING] [nvarchar](50) NULL,
        [TENANT_ENABLE_JOURNALING] [nvarchar](50) NULL,
        [TENANT_JOURNALING_SAME_AS_LOGGING] [nvarchar](50) NULL,
        [CUSTOMER_NAME] [nvarchar](200) NULL,
        [COUNTRY] [nvarchar](50) NULL,
        [DEFAULT_LANGUAGE] [nvarchar](50) NULL,
        [ADMIN_CONTACT_FIRST_NAME] [nvarchar](40) NULL,
        [ADMIN_CONTACT_LAST_NAME] [nvarchar](40) NULL,
        [EXTERNAL_ID] [nvarchar](50) NULL,
        [ENABLED_DOCUMENT_TYPES] [nvarchar](125) NULL,
        [TENANT_DOCUMENT_LANGUAGE] [nvarchar](50) NULL,
        [ERROR_STEP] [nvarchar](50) NULL,
     CONSTRAINT [PK_TENANT] PRIMARY KEY CLUSTERED
    (
        [Id] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

USE CONFIG_KIND
GO

IF NOT EXISTS(SELECT * FROM [dbo].[TENANT] WHERE [NAME] = 'default')
BEGIN
INSERT INTO [dbo].[TENANT]
          ([Id]
          ,[CREATOR_BUSINESS_UNIT]
          ,[OWNER_BUSINESS_UNIT]
          ,[ENTITY_STATUS]
          ,[PARENTID]
          ,[DESCRIPTION]
          ,[NAME]
          ,[SQL_CONNECTION_STRING]
          ,[SQL_DATA_PROVIDER]
          ,[IS_DEFAULT]
          ,[NOSQL_CONNECTION_STRING]
          ,[NOSQL_DATA_PROVIDER]
          ,[CUSTOMIZATIONS]
          ,[READ_LOGS_ENABLED]
          ,[FILE_ACCESS_PROVIDER]
          ,[FILE_ACCESS_BASE_PATH]
          ,[ENABLED_SERVICES]
          ,[ENABLED_MICROSERVICES]
          ,[COLUMN_ENCRYPTION_KEY]
          ,[LOGGING_DURATION]
          ,[LOGGING_DURATION_UM]
          ,[TENANT_ENABLE_LOGGING]
          ,[TENANT_ENABLE_JOURNALING]
          ,[TENANT_JOURNALING_SAME_AS_LOGGING]
          ,[CUSTOMER_NAME]
          ,[COUNTRY]
          ,[DEFAULT_LANGUAGE]
          ,[ADMIN_CONTACT_FIRST_NAME]
          ,[ADMIN_CONTACT_LAST_NAME]
          ,[EXTERNAL_ID]
          ,[ENABLED_DOCUMENT_TYPES]
          ,[TENANT_DOCUMENT_LANGUAGE]
          ,[ERROR_STEP]
          ,[STATUS])
    VALUES
          (NEWID()
          ,'00000000-0000-0000-0000-000000000001'
          ,'00000000-0000-0000-0000-000000000001'
          ,'ACTIVE'
          ,NULL
          ,'Default'
          ,'default'
          ,'Data Source=sqlserver;User=sa;Password=SSinRORFpwO88vCT-wNqgQvnH9W3qSQ8P11;Initial Catalog=TEST_KIND;TrustServerCertificate=True'
          ,'MSSQL'
          ,0
          ,NULL
          ,'MONGO'
          ,NULL
          ,0
          ,'FS'
          ,'default'
          ,NULL
          ,'CMPS,IDP,RSMS,FMTC'
          ,NULL
          ,NULL
          ,NULL
          ,NULL
          ,NULL
          ,NULL
          ,NULL
          ,NULL
          ,NULL
          ,NULL
          ,NULL
          ,'642BF785-55B2-4A25-9080-25A860D31B89'
          ,NULL
          ,NULL
          ,NULL
          ,0)
END
GO
