#Requires -Version 5.0
#Requires -Modules SQLServer

<#
.SYNOPSIS
    Gets a SQL JobStep object for each step that is present in the target instance of SQL Agent Job

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
    Specifies the name of the Job object

.Parameter StepName
    Specifies the name of the JobStep object that this cmdlet gets

.Parameter ConnectionTimeout
    Specifies the time period to retry the command on the target server

.Parameter Properties
    List of properties to expand, comma separated e.g. Name,State. Use * for all properties
#>

[CmdLetBinding()]
Param(  
    [Parameter(Mandatory = $true)]   
    [string]$ServerInstance,    
    [pscredential]$ServerCredential,
    [string]$JobName,
    [string]$StepName,
    [int]$ConnectionTimeout = 30,
    [ValidateSet('*','Name','ID','State','Command','LastRunDate','LastRunDuration','LastRunDurationAsTimeSpan','OnFailAction','OnSuccessAction')]
    [string[]]$Properties = @('Name','ID','State','Command','LastRunDate','LastRunDuration','LastRunDurationAsTimeSpan','OnFailAction','OnSuccessAction')
)

Import-Module SQLServer

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'ServerInstance' = $ServerInstance
                            'ConnectionTimeout' = $ConnectionTimeout
                            }      
    if($null -ne $ServerCredential){
        $cmdArgs.Add('Credential', $ServerCredential)
    }                            

    [hashtable]$cmdJob = @{'ErrorAction' = 'Stop'}      
    [hashtable]$cmdStep = @{'ErrorAction' = 'Stop'}      
    if([System.String]::IsNullOrWhiteSpace($JobName) -eq $false){
        $cmdJob.Add('Name',$JobName)
    }
    if([System.String]::IsNullOrWhiteSpace($StepName) -eq $false){
        $cmdStep.Add('Name',$StepName)
    }
    $result = Get-SqlAgent @cmdArgs | Get-SqlAgentJob @cmdJob `
                | Get-SqlAgentJobStep @cmdStep | Select-Object $Properties
    
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