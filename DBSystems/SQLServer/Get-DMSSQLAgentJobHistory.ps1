#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    Gets the job history present in the target instance of SQL Agent

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

.Parameter JobName
    Specifies a job filter constraint that restricts the values returned to the job specified by the name of the job

.Parameter JobID
    Specifies a job filter constraint that restricts the values returned to the job specified by the job ID value

.Parameter StartRunDate
    Specifies a job filter constraint that restricts the values returned to the date the job started

.Parameter EndRunDate
    Specifies a job filter constraint that restricts the values returned to the date the job completed

.Parameter MinimumRunDurationInSeconds
    Specifies a job filter constraint that restricts the values returned to jobs that have completed in the minimum length of time specified, in seconds

.Parameter Since
    Specifies an abbreviation that you can instead of the StartRunDate parameter

.Parameter OldestFirst
    Indicates that this cmdlet lists jobs in oldest-first order. If you do not specify this parameter, the cmdlet uses newest-first order

.Parameter OutcomesType
    Specifies a job filter constraint that restricts the values returned to jobs that have the specified outcome at completion

.Parameter ConnectionTimeout
    Specifies the time period to retry the command on the target server
#>

[CmdLetBinding()]
Param(  
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [pscredential]$ServerCredential,
    [string]$JobName,
    [guid]$JobID,
    [Parameter(HelpMessage="ASRDisplay(Date)")]
    [datetime]$StartRunDate,
    [Parameter(HelpMessage="ASRDisplay(Date)")]
    [datetime]$EndRunDate,
    [int]$MinimumRunDurationInSeconds,
    [switch]$OldestFirst,
    [ValidateSet('Failed', 'Succeeded', 'Retry', 'Cancelled', 'InProgress', 'Unknown')]
    [string]$OutcomesType,
    [ValidateSet('Midnight', 'Yesterday', 'LastWeek', 'LastMonth')]
    [string]$Since,
    [int]$ConnectionTimeout = 30
)

Import-Module SQLServer

try{
    $instance = GetSQLServerInstance -ServerInstance $ServerInstance -ServerCredential $ServerCredential -ConnectionTimeout $ConnectionTimeout

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'OldestFirst' = $OldestFirst.ToBool()
                            }      
    if([System.String]::IsNullOrWhiteSpace($JobName) -eq $false){
        $cmdArgs.Add('JobName',$JobName)
    }
    if($null -ne $JobID){
        $cmdArgs.Add('JobID',$JobID)
    }
    if($MinimumRunDurationInSeconds-gt 0){
        $cmdArgs.Add('MinimumRunDurationInSeconds',$MinimumRunDurationInSeconds)
    }
    if(($null -eq $StartRunDate) -and ([System.String]::IsNullOrWhiteSpace($Since) -eq $false)){
        $cmdArgs.Add('Since',$Since)
    }
    if($null -ne $EndRunDate){
        $cmdArgs.Add('EndRunDate',$EndRunDate)
    }
    if($null -ne $StartRunDate){
        $cmdArgs.Add('StartRunDate',$StartRunDate)
    }
    if([System.String]::IsNullOrWhiteSpace($OutcomesType) -eq $false){
        $cmdArgs.Add('OutcomesType',$OutcomesType)
    }

    $result = Get-SqlAgent -InputObject $instance -ErrorAction Stop | Get-SqlAgentJobHistory @cmdArgs | Select-Object *
    
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