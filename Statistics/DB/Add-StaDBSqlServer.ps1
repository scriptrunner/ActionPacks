#Requires -Version 5.0

<#
    .SYNOPSIS
        Creates the database, tables, storded procedures in the MS Sql Server
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
    
    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/Statistics/DB
        
    .Parameter SQLServer
        [sr-en] Name of the database server
        [sr-de] Name des SQL Servers ggf. mit Instanz Namen
        
    .Parameter DBName
        [sr-en] Name of the database
        [sr-de] Name der Datenbank
        
    .Parameter SqlServerVersion
        [sr-en] Version of the Sql Server
        [sr-de] Version des SQL Servers
        
    .Parameter SqlExpress
        [sr-en] Sql Server is a express installation
        [sr-de] Es handelt sich um eine SQL Express Installation
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$SQLServer,
    [string]$DBName = 'SRStatistics',
    [ValidateSet('2019','2017','2016','2014')]
    [string]$SqlServerVersion = '2019',
    [switch]$SqlExpress
)

try{
    function CreateDB(){
        <#
            .SYNOPSIS
                Function creates the database

            .DESCRIPTION

            .NOTES
                This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
                The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
                The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
                the use and the consequences of the use of this freely available script.
                PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
                © ScriptRunner Software GmbH

            .COMPONENT            

            .LINK
                https://github.com/scriptrunner/ActionPacks/tree/master/Statistics/DB
        #>

        [string]$srvExtension = 'MSSQLSERVER'
        [string]$Script:sqlVersion = ''

        switch ($SqlServerVersion) {
            "2019" { $Script:sqlVersion = '15' }
            "2017" { $Script:sqlVersion = '14' }
            "2016" { $Script:sqlVersion = '13' }
            "2014" { $Script:sqlVersion = '12' }
        }
        if($SqlExpress.IsPresent -eq $true)
        {
            $srvExtension = 'SQLEXPRESS'
        }

        $scon = New-Object System.Data.SqlClient.SqlConnection
        $scon.ConnectionString = "Data Source=$($SQLServer);Integrated Security=true"
        $null = $scon.Open()

        [string]$command = "CREATE DATABASE [SRStatistics]
                CONTAINMENT = NONE
                ON  PRIMARY 
                ( NAME = N'SRStatistics', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL$($Script:sqlVersion).$($srvExtension)\MSSQL\DATA\SRStatistics.mdf' , SIZE = 51200KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
                LOG ON 
                ( NAME = N'SRStatistics_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL$($Script:sqlVersion).$($srvExtension)\MSSQL\DATA\SRStatistics_log.ldf' , SIZE = 2048KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
                ALTER DATABASE [SRStatistics] SET COMPATIBILITY_LEVEL = 120

                IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
                begin
                    EXEC [SRStatistics].[dbo].[sp_fulltext_database] @action = 'enable'
                end
                ALTER DATABASE [SRStatistics] SET ANSI_NULL_DEFAULT OFF 
                ALTER DATABASE [SRStatistics] SET ANSI_NULLS OFF 
                ALTER DATABASE [SRStatistics] SET ANSI_PADDING OFF
                ALTER DATABASE [SRStatistics] SET ANSI_WARNINGS OFF
                ALTER DATABASE [SRStatistics] SET ARITHABORT OFF 
                ALTER DATABASE [SRStatistics] SET AUTO_CLOSE OFF 
                ALTER DATABASE [SRStatistics] SET AUTO_SHRINK OFF
                ALTER DATABASE [SRStatistics] SET AUTO_UPDATE_STATISTICS ON 
                ALTER DATABASE [SRStatistics] SET CURSOR_CLOSE_ON_COMMIT OFF
                ALTER DATABASE [SRStatistics] SET CURSOR_DEFAULT  GLOBAL 
                ALTER DATABASE [SRStatistics] SET CONCAT_NULL_YIELDS_NULL OFF 
                ALTER DATABASE [SRStatistics] SET NUMERIC_ROUNDABORT OFF 
                ALTER DATABASE [SRStatistics] SET QUOTED_IDENTIFIER OFF 
                ALTER DATABASE [SRStatistics] SET RECURSIVE_TRIGGERS OFF
                ALTER DATABASE [SRStatistics] SET  DISABLE_BROKER 
                ALTER DATABASE [SRStatistics] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
                ALTER DATABASE [SRStatistics] SET DATE_CORRELATION_OPTIMIZATION OFF
                ALTER DATABASE [SRStatistics] SET TRUSTWORTHY OFF 
                ALTER DATABASE [SRStatistics] SET ALLOW_SNAPSHOT_ISOLATION OFF 
                ALTER DATABASE [SRStatistics] SET PARAMETERIZATION SIMPLE 
                ALTER DATABASE [SRStatistics] SET READ_COMMITTED_SNAPSHOT OFF 
                ALTER DATABASE [SRStatistics] SET HONOR_BROKER_PRIORITY OFF 
                ALTER DATABASE [SRStatistics] SET RECOVERY FULL 
                ALTER DATABASE [SRStatistics] SET  MULTI_USER 
                ALTER DATABASE [SRStatistics] SET PAGE_VERIFY CHECKSUM  
                ALTER DATABASE [SRStatistics] SET DB_CHAINING OFF 
                ALTER DATABASE [SRStatistics] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
                ALTER DATABASE [SRStatistics] SET TARGET_RECOVERY_TIME = 0 SECONDS 
                ALTER DATABASE [SRStatistics] SET DELAYED_DURABILITY = DISABLED 
                ALTER DATABASE [SRStatistics] SET  READ_WRITE"
            
        $command = $command.Replace('SRStatistics',$DBName)
        # create db
        $scmd = New-Object System.Data.SqlClient.SqlCommand
        try{
            $scmd.CommandType = [System.Data.CommandType]::Text
            $scmd.CommandText = $command
            $scmd.Connection = $scon            
            $null = $scmd.ExecuteScalar()
            Write-Output "Database $($DBname) created on server $($SQLServer)"
        }
        catch{
            throw
        }
        finally{                
            $null = $scmd.Dispose()
            $scon.Close()
            $scon.Dispose()
        }
    }
    function CreateTables(){
        <#
            .SYNOPSIS
                Function creates tables in the database

            .DESCRIPTION

            .NOTES
                This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
                The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
                The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
                the use and the consequences of the use of this freely available script.
                PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
                © ScriptRunner Software GmbH

            .COMPONENT            

            .LINK
                https://github.com/scriptrunner/ActionPacks/tree/master/Statistics/DB

            .Parameter Connection
                Connection object
        #>

        param(
            [Parameter(Mandatory = $true)]
            $Connection
        )

        [string]$command = "
            SET ANSI_NULLS ON            
            SET QUOTED_IDENTIFIER ON
        
            /****** Object:  Table [dbo].[Actions] ******/
            CREATE TABLE [dbo].[Actions](
                [ActionIdentifier] [uniqueidentifier] NOT NULL,
                [ActionName] [nvarchar](150) NOT NULL,
                [ScriptRunnerID] [int] NULL,
                [Script] [nvarchar](250) NULL,
            CONSTRAINT [PK_Actions] PRIMARY KEY CLUSTERED 
            (
                [ActionIdentifier] ASC
            )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
            ) ON [PRIMARY]

            /****** Object:  Table [dbo].[Targets] ******/
            CREATE TABLE [dbo].[Targets](
                [TargetIdentifier] [uniqueidentifier] NOT NULL,
                [TargetName] [nvarchar](300) NOT NULL,
            CONSTRAINT [PK_Targets] PRIMARY KEY CLUSTERED 
            (
                [TargetIdentifier] ASC
            )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
            ) ON [PRIMARY]

            ALTER TABLE [dbo].[Targets] ADD  CONSTRAINT [DF_Targets_TargetIdentifier]  DEFAULT (newid()) FOR [TargetIdentifier]

            /****** Object:  Table [dbo].[ActionExecutions] ******/
            CREATE TABLE [dbo].[ActionExecutions](
                [ItemID] [uniqueidentifier] NOT NULL,
                [Started] [bigint] NOT NULL,
                [Ended] [bigint] NOT NULL,
                [Duration] [int] NOT NULL,
                [CostReduction] [int] NOT NULL,
                [StartedBy] [nvarchar](250) NOT NULL,
                [Reason] [nvarchar](500) NULL,
                [Action] [uniqueidentifier] NOT NULL,
                [Target] [uniqueidentifier] NOT NULL,
            CONSTRAINT [PK_ActionExecutions] PRIMARY KEY CLUSTERED 
            (
                [ItemID] ASC
            )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
            ) ON [PRIMARY]

            ALTER TABLE [dbo].[ActionExecutions] ADD  CONSTRAINT [DF_ActionExecutions_ItemID]  DEFAULT (newid()) FOR [ItemID]"
                
            # create tables
            $scmd = New-Object System.Data.SqlClient.SqlCommand
            try{
                $scmd.CommandType = [System.Data.CommandType]::Text
                $scmd.CommandText = $command
                $scmd.Connection = $Connection
                $null = $scmd.ExecuteScalar()
                Write-Output "Tables created on database $($DBname) - $($SQLServer)"
            }
            catch{
                throw
            }
            finally{                
                $null = $scmd.Dispose()
            }
    }
    function CreateSPs(){
        <#
            .SYNOPSIS
                Function creates stored procedures in the database

            .DESCRIPTION

            .NOTES
                This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
                The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
                The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
                the use and the consequences of the use of this freely available script.
                PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
                © ScriptRunner Software GmbH

            .COMPONENT            

            .LINK
                https://github.com/scriptrunner/ActionPacks/tree/master/Statistics/DB

            .Parameter Connection
                Connection object
            #>

            param(
                [Parameter(Mandatory = $true)]
                $Connection
            )

            [string[]]$commands = "
            CREATE PROCEDURE [dbo].[DeleteExecutions]	
                @TimeStamp bigint
            AS
            BEGIN	
                if(@TimeStamp > 0)
                BEGIN
                    DELETE FROM [dbo].[ActionExecutions]
                    WHERE [dbo].[ActionExecutions].[Started] < @TimeStamp
                END
            END", `
            "CREATE PROCEDURE [dbo].[RegisterExecution]	
                @Started bigint,
                @Ended bigint,
                @Duration int,
                @StartedBy nvarchar(max),
                @Savings int,
                @Reason nvarchar(max) = '',
                @Target nvarchar(max),
                @Action nvarchar(max),
                @ActionID int = 0,
                @ScriptName nvarchar(max),
                @DeleteOlderExecutions bigint = 0
            AS
            BEGIN	
                DECLARE @tID uniqueidentifier
                -- search target
                SELECT @tID = [dbo].[Targets].[TargetIdentifier] FROM [dbo].[Targets] WHERE [dbo].[Targets].[TargetName] = @Target
                IF(@tID IS NULL)
                BEGIN
                    SET @tID = NEWID()
                    INSERT INTO [dbo].[Targets]
                    ([dbo].[Targets].[TargetIdentifier],[dbo].[Targets].[TargetName])
                    VALUES
                    (@tID,@Target)
                END
                -- search action
                DECLARE @aID uniqueidentifier
                IF(@ActionID = 0)
                    BEGIN
                        SELECT @aID = [dbo].[Actions].[ActionIdentifier] FROM [dbo].[Actions] WHERE [dbo].[Actions].[ActionName] = @Action		
                    END
                ELSE
                    BEGIN
                        SELECT @aID = [dbo].[Actions].[ActionIdentifier] FROM [dbo].[Actions] WHERE [dbo].[Actions].[ScriptRunnerID] = @ActionID
                    END
            
                IF(@aID IS NULL)
                BEGIN
                    SET @aID = NEWID()
                    INSERT INTO [dbo].[Actions]
                    ([dbo].[Actions].[ActionIdentifier],[dbo].[Actions].[ActionName],[dbo].[Actions].[Script],[dbo].[Actions].[ScriptRunnerID])
                    VALUES
                    (@aID,@Action,@ScriptName,@ActionID)
                END
            
                -- insert execution in table
                INSERT INTO [dbo].[ActionExecutions]
                ([dbo].[ActionExecutions].[Started],[dbo].[ActionExecutions].[Ended],[dbo].[ActionExecutions].[StartedBy],[dbo].[ActionExecutions].[Action],
                    [dbo].[ActionExecutions].[Duration],[dbo].[ActionExecutions].[CostReduction],[dbo].[ActionExecutions].[Target],[dbo].[ActionExecutions].[Reason])
                Values
                (@Started,@Ended,@StartedBy,@aID,@Duration,@Savings,@tID,@Reason)
            
                Exec [dbo].[DeleteExecutions] @DeleteOlderExecutions
            END", `
            "CREATE PROCEDURE [dbo].[GetActions]
            AS
            BEGIN
                    SELECT * FROM [dbo].[Actions]
                    ORDER BY [dbo].[Actions].[ActionName]
            END", `
            "CREATE PROCEDURE [dbo].[GetTargets]
            AS
            BEGIN
                    SELECT * FROM [dbo].[Targets]
                    ORDER BY [dbo].[Targets].[TargetName]
            END", `
            "CREATE PROCEDURE [dbo].[GetExecutions]
                    @StartDate bigint,
                    @EndDate bigint,
                    @Action nvarchar(max) = NULL,
                    @Target nvarchar(max) = NULL
            AS
            BEGIN
                    DECLARE @Execstatement nvarchar(max)
                    
                    SET @Execstatement = '
                        SELECT [dbo].[ActionExecutions].*,
                        [dbo].[Actions].[ActionName],[dbo].[Targets].[TargetName]
                        FROM [dbo].[ActionExecutions] LEFT JOIN [dbo].[Actions] ON
                        [dbo].[ActionExecutions].[Action] = [dbo].[Actions].[ActionIdentifier]
                        LEFT JOIN [dbo].[Targets] ON
                        [dbo].[ActionExecutions].[Target] = [dbo].[Targets].[TargetIdentifier]
                        WHERE ([dbo].[ActionExecutions].[Started] >= ' + Convert(varchar(40),@StartDate) +
                        ' AND [dbo].[ActionExecutions].[Ended] <= ' + Convert(varchar(40),@EndDate) + ')'
                
                    -- filter specific action
                    if(@Action IS NOT NULL) 
                    BEGIN
                        SET @Execstatement += ' AND [dbo].[Actions].[ActionName] = ''' + @Action + ''''
                    END
                    -- filter specific target
                    if(@Target IS NOT NULL) 
                    BEGIN
                        SET @Execstatement += ' AND [dbo].[Targets].[TargetName] = ''' + @Target + ''''
                    END
                
                    SET @Execstatement += ' ORDER BY [dbo].[ActionExecutions].[Started] DESC'
                    --print @Execstatement
                    EXEC(@Execstatement)
            END"
            
            # create stored procedures
            $scmd = New-Object System.Data.SqlClient.SqlCommand
            try{
                $scmd.CommandType = [System.Data.CommandType]::Text
                $scmd.Connection = $Connection
                foreach($sp in $commands){                        
                    $scmd.CommandText = $sp
                    $null = $scmd.ExecuteScalar()
                }
                Write-Output "Stored procedures created on database $($DBname) - $($SQLServer)"
            }
            catch{
                throw
            }
            finally{                
                $null = $scmd.Dispose()
            }
    }

    CreateDB
    # open connection to the new database
    $con = New-Object System.Data.SqlClient.SqlConnection
    try{
        $con.ConnectionString = "Data Source=$($SQLServer);Initial Catalog=$($DBName);Integrated Security=true"
        $null = $con.Open()
        CreateTables -Connection $con
        CreateSPs -Connection $con
    }
    finally{
        if($con.State -eq [System.Data.ConnectionState]::Open){
            $null = $con.Close()
        }
        $null = $con.Dispose()
    }
}
catch{
    throw 
}
finally{
}