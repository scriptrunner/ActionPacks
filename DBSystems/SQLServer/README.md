# Action Pack for SQL Server

> Note: The use of the scripts requires the PowerShell Module SQLServer.

+ [Add-DMSSQLDatabaseRoleMembers.ps1](./Add-DMSSQLDatabaseRoleMembers.ps1)

    Adds members to a specific Role of a specific database

+ [Add-DMSSQLFirewallRule.ps1](./Add-DMSSQLFirewallRule.ps1)

    Adds a Windows Firewall rule to allow connections to a specific instance of SQL Server

+ [Add-DMSSQLInstanceRoleMembers.ps1](./Add-DMSSQLInstanceRoleMembers.ps1)

    Adds members to a specific Role of the SQL Instance object

+ [Backup-DMSSQLASDatabase.ps1](./Backup-DMSASSQLDatabase.ps1)

    Enables a database administrator to take the backup of Analysis Service Database to a file

+ [Backup-DMSSQLDatabase.ps1](./Backup-DMSSQLDatabase.ps1)

    Backs up SQL Server database objects 

+ [Get-DMSSQLAgent.ps1](./Get-DMSSQLAgent.ps1)    

    Gets a SQL Agent object that is present in the target instance of SQL Server

+ [Get-DMSSQLAgentJob.ps1](./Get-DMSSQLAgentJob.ps1)    

    Gets a SQL Agent Job object for each job that is present in the target instance of SQL Agent

+ [Get-DMSSQLAgentJobHistory.ps1](./Get-DMSSQLAgentJobHistory.ps1)    

    Gets the job history present in the target instance of SQL Agent

+ [Get-DMSSQLAgentJobStep.ps1](./Get-DMSSQLAgentJobStep.ps1)    

    Gets a SQL JobStep object for each step that is present in the target instance of SQL Agent Job

+ [Get-DMSSQLAgentJobSchedule.ps1](./Get-DMSSQLAgentJobSchedule.ps1)    

    Gets a job schedule object for each schedule that is present in the target instance of SQL Agent Job

+ [Get-DMSSQLAgentSchedule.ps1](./Get-DMSSQLAgentSchedule.ps1)    

    Gets a SQL job schedule object for each schedule that is present in the target instance of SQL Agent

+ [Get-DMSSQLBackupHistory.ps1](./Get-DMSSQLBackupHistory.ps1)

    Gets backup information about databases and returns SMO BackupSet objects for each Backup record found based on the parameters specified to this cmdlet

+ [Get-DMSSQLColumnEncryptionKey.ps1](./Get-DMSSQLColumnEncryptionKey.ps1)

    Gets all column encryption key objects defined in the database

+ [Get-DMSSQLColumnMasterKey.ps1](./Get-DMSSQLColumnMasterKey.ps1)

    Gets the column master key objects defined in the database

+ [Get-DMSSQLCredential.ps1](./Get-DMSSQLCredential.ps1)

    Gets a SQL credential object

+ [Get-DMSSQLDatabase.ps1](./Get-DMSSQLDatabase.ps1)

    Gets a SQL database object for each database that is present in the target instance of SQL Server

+ [Get-DMSSQLDatabaseRoles.ps1](./Get-DMSSQLDatabaseRoles.ps1)

    Gets the roles and there mmembers from the SQL database object

+ [Get-DMSSQLErrorLog.ps1](./Get-DMSSQLErrorLog.ps1)

    Gets the SQL Server error logs

+ [Get-DMSSQLInstance.ps1](./Get-DMSSQLInstance.ps1)

    Gets a SQL Instance object

+ [Get-DMSSQLInstanceRoles.ps1](./Get-DMSSQLInstanceRoles.ps1)

    Gets the roles and there mmembers from the SQL Instance object

+ [Get-DMSSQLLogin.ps1](./Get-DMSSQLLogin.ps1)

    Returns Login objects in an instance of SQL Server

+ [Get-DMSSQLSmartAdmin.ps1](./Get-DMSSQLSmartAdmin.ps1)

    Gets the SQL Smart Admin object and its properties

+ [Invoke-DMSSQLAlwaysOnCommand.ps1](./Invoke-DMSSQLAlwaysOnCommand.ps1)

    Enables or disables the Always On availability groups feature for a server

+ [Invoke-DMSSQLCmd.ps1](./Invoke-DMSSQLCmd.ps1)

    Runs a script containing statements supported by the SQL Server SQLCMD utility

+ [Invoke-DMSSQLInstanceCommand.ps1](./Invoke-DMSSQLInstanceCommand.ps1)

    Starts or stops a SQL Instance object

+ [New-DMSSQLColumnEncryptionKey.ps1](./New-DMSSQLColumnEncryptionKey.ps1)

    Creates a column encryption key object in the database

+ [New-DMSSQLColumnMasterKey.ps1](./New-DMSSQLColumnMasterKey.ps1)

    Creates a column master key object in the database

+ [New-DMSSQLCredential.ps1](./New-DMSSQLCredential.ps1)

    Creates a SQL Server credential object

+ [New-DMSSQLLogin.ps1](./New-DMSSQLLogin.ps1)

    Creates a Login object in an instance of SQL Server

+ [Read-DMSSQLData.ps1](./Read-DMSSQLData.ps1)

    Reads data from a table or a view of a SQL database

+ [Remove-DMSSQLColumnEncryptionKey.ps1](./Remove-DMSSQLColumnEncryptionKey.ps1)

    Removes the column encryption key object from the database

+ [Remove-DMSSQLColumnMasterKey.ps1](./Remove-DMSSQLColumnMasterKey.ps1)

    Removes the column master key object from the database

+ [Remove-DMSSQLCredential.ps1](./Remove-DMSSQLCredential.ps1)

    Removes the SQL credential object

+ [Remove-DMSSQLDatabaseRoleMembers.ps1](./Remove-DMSSQLDatabaseRoleMembers.ps1)

    Removes members from a specific Role of a specific database

+ [Remove-DMSSQLFirewallRule.ps1](./Remove-DMSSQLFirewallRule.ps1)

    Disables the Windows Firewall rule that allows connections to a specific instance of SQL Server

+ [Remove-DMSSQLInstanceRoleMembers.ps1](./Remove-DMSSQLInstanceRoleMembers.ps1)

    Removes members from a specific Role of the SQL Instance object

+ [Remove-DMSSQLLogin.ps1](./Remove-DMSSQLLogin.ps1)

    Removes Login object from an instance of SQL Server

+ [Restore-DMSSQLASDatabase.ps1](./Restore-DMSSQLASDatabase.ps1)

    Restores a specified Analysis Service database from a backup file

+ [Restore-DMSSQLDatabase.ps1](./Restore-DMSSQLDatabase.ps1)

    Restores a database from a backup or transaction log records

+ [Save-DMSSQLMigrationReport.ps1](./Save-DMSSQLMigrationReport.ps1)

    Generates In-Memory OLTP Migration Checklist

+ [Set-DMSSQLAuthenticationMode.ps1](./Set-DMSSQLAuthenticationMode.ps1)

    Configures the authentication mode of the target instance of SQL Server

+ [Set-DMSSQLColumnEncryption.ps1](./Set-DMSSQLColumnEncryption.ps1)

    Encrypts, decrypts, or re-encrypts specified columns in the database

+ [Set-DMSSQLCredential.ps1](./Set-DMSSQLCredential.ps1)

    Sets the properties for the SQL Credential object

+ [Set-DMSSQLErrorLog.ps1](./Set-DMSSQLErrorLog.ps1)

    Sets or resets the maximum number of error log files before they are recycled

+ [Set-DMSSQLNetworkConfiguration.ps1](./Set-DMSSQLNetworkConfiguration.ps1)

    Sets the network configuration of the target instance of SQL Server

+ [Set-DMSSQLSmartAdmin.ps1](./Set-DMSSQLSmartAdmin.ps1)

    Configures or modifies backup retention and storage settings

+ [Test-DMSSQLSmartAdmin.ps1](./Test-DMSSQLSmartAdmin.ps1)

    Tests the health of Smart Admin by evaluating SQL Server policy based management (PBM) policies

+ [Write-DMSSQLTableData.ps1](./Write-DMSSQLTableData.ps1)

    Writes data to a table of a SQL database