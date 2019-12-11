#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    Encrypts, decrypts, or re-encrypts specified columns in the database

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Module SQLServer
    Requires the library script DMSSqlServer.ps1
    
.LINK
    https://github.com/scriptrunner/ActionPacks/blob/master/DBSystems/SQLServer
 
.Parameter ServerInstance
    Specifies the name of the target computer including the instance name, e.g. MyServer\Instance 

.Parameter ServerCredential
    Specifies a PSCredential object for the connection to the SQL Server. ServerCredential is ONLY used for SQL Logins. 
    When you are using Windows Authentication you don't specify -Credential. It is picked up from your current login.

.Parameter DatabaseName
    Specifies the SQL database object, for runs the operation

.Parameter SettingsCsvFile
    Csv file with the encryption settings of the columns, see ColumnEncryption.csv
    Column name e.g. Table01.DisplayName, EncryptionType Deterministic, Randomized or Plaintext

.Parameter KeepCheckForeignKeyConstraints
    If set, check semantics (CHECK or NOCHECK) of foreign key constraints are preserved

.Parameter LogFileDirectory
    If set, the cmdlet will create a log file in the specified directory
        
.Parameter MaxDivergingIterations
    Specifies the maximum number of consecutive catch-up iterations, where the number of processed rows increases. 
    Must be less than the value of MaxIterations

.Parameter MaxDowntimeInSeconds
    Specifies the maximum time (in seconds), during which the source table will not be available for reads and writes

.Parameter MaxIterationDurationInDays
    Specifies the maximum time (in days) of seeding or a single catch-up iteration

.Parameter MaxIterations
    Specifies the maximum number of iterations in the catch-up phase

.Parameter UseOnlineApproach
    If set, the cmdlet will use the online approach, to ensure the database is available to other applications for both reads and writes for most of the duration of the operation.
    Otherwise, the cmdlet will lock the impacted tables, making them unavailable for updates for the entire operation. The tables will be available for reads    
    
.Parameter CsvDelimiter
    Specifies the delimiter that separates the property values in the CSV file

.Parameter FileEncoding
    Specifies the type of character encoding that was used in the CSV file

.Parameter ConnectionTimeout
    Specifies the time period to retry the command on the target server
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,     
    [Parameter(Mandatory = $true)]   
    [string]$DatabaseName,    
    [Parameter(Mandatory = $true)]   
    [string]$SettingsCsvFile,
    [pscredential]$ServerCredential,
    [switch]$KeepCheckForeignKeyConstraints,
    [string]$LogFileDirectory,
    [int]$MaxDivergingIterations,
    [int]$MaxDowntimeInSeconds,
    [int]$MaxIterationDurationInDays,
    [int]$MaxIterations,
    [switch]$UseOnlineApproach,
    [string]$CsvDelimiter= ';',
    [ValidateSet('Unicode','UTF7','UTF8','ASCII','UTF32','BigEndianUnicode','Default','OEM')]
    [string]$FileEncoding = 'UTF8',
    [int]$ConnectionTimeout = 30
)

Import-Module SQLServer

try{
    $instance = GetSQLServerInstance -ServerInstance $ServerInstance -ServerCredential $ServerCredential -ConnectionTimeout $ConnectionTimeout

    if((Test-Path -Path $SettingsCsvFile) -eq $false){
        throw "Csv file: $($SettingsCsvFile) not found"
    }
    $settings = Import-Csv -Path $SettingsCsvFile -Delimiter $CsvDelimiter -Encoding $FileEncoding `
            -Header @('ColumnName', 'EncryptionType', 'EncryptionKey') -ErrorAction Stop
    $colEncry = @()
    foreach($item in $settings){
        if($item.EncryptionType -eq 'EncryptionType'){
            continue
        }
        if($item.EncryptionType -eq 'Plaintext'){
            $colEncry += New-SqlColumnEncryptionSettings -ColumnName $item.ColumnName -EncryptionType $item.EncryptionType
        }
        else {
            $colEncry += New-SqlColumnEncryptionSettings -ColumnName $item.ColumnName -EncryptionType $item.EncryptionType -EncryptionKey $item.EncryptionKey
        }
    }
    
    $dbInstance = GetSqlDatabase -DatabaseName $DatabaseName -ServerInstance $instance

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'ColumnEncryptionSettings' = $colEncry
                            'InputObject' = $dbInstance                            
                            }    
    if([System.String]::IsNullOrWhiteSpace($LogFileDirectory) -eq $false){
        $cmdArgs.Add('LogFileDirectory',$LogFileDirectory)
    }
    if($UseOnlineApproach){
        $cmdArgs.Add('UseOnlineApproach',$UseOnlineApproach.ToBool())
        $cmdArgs.Add('KeepCheckForeignKeyConstraints', $KeepCheckForeignKeyConstraints.ToBool())
        if($MaxIterations -gt 0){
            $cmdArgs.Add('MaxIterations',$MaxIterations)
        }
        if($MaxDowntimeInSeconds -gt 0){
            $cmdArgs.Add('MaxDowntimeInSeconds',$MaxDowntimeInSeconds)
        }
        if($MaxIterationDurationInDays -gt 0){
            $cmdArgs.Add('MaxIterationDurationInDays',$MaxIterationDurationInDays)
        }
        if(($MaxDivergingIterations -gt 0) -and ($MaxDivergingIterations -lt $MaxIterations)){
            $cmdArgs.Add('MaxDivergingIterations',$MaxDivergingIterations)
        }
    }

    $result = Set-SqlColumnEncryption @cmdArgs | Select-Object *    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $result
    }
    else{
        Write-Output $result
    }
}
catch{
    throw
}
finally{
}