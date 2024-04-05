#Requires -Version 5.0

<#
.SYNOPSIS
    Writes an event to an event log

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/EventLogs

.Parameter LogName
    [sr-en] Event log

.Parameter CustomLogName
    [sr-en] Name of the custom event log, enter the log name (not the LogDisplayName)

.Parameter ComputerName
    [sr-en] Remote computer, the default is the local computer.

.Parameter EventID
    [sr-en] Event identifier. The maximum value for the EventId parameter is 65535

.Parameter Message 
    [sr-en] Event message

.Parameter Source
    [sr-en] Event source, which is typically the name of the application that is writing the event to the log

.Parameter SourceName
    [sr-en] Event source, which is typically the name of the application that is writing the event to the log

.Parameter EntryType
    [sr-en] Entry type of the event

.Parameter Category
    [sr-en] Task category for the event
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "Classic event logs")]
    [ValidateSet("Application","HardwareEvents","Internet Explorer","Key Management Service","Security","System","Windows PowerShell")]
    [string]$LogName,
    [Parameter(Mandatory = $true, ParameterSetName = "Custom event log")]
    [string]$CustomLogName,
    [Parameter(Mandatory = $true, ParameterSetName = "Classic event logs")]
    [Parameter(Mandatory = $true, ParameterSetName = "Custom event log")]
    [int32]$EventID,    
    [Parameter(Mandatory = $true, ParameterSetName = "Classic event logs")]
    [Parameter(Mandatory = $true, ParameterSetName = "Custom event log")]
    [string]$Message,
    [Parameter(ParameterSetName = "Classic event logs")]
    [Parameter(ParameterSetName = "Custom event log")]
    [string]$ComputerName,
    [Parameter(Mandatory = $true, ParameterSetName = "Classic event logs")]
    [string]$Source,    
    [Parameter(Mandatory = $true, ParameterSetName = "Custom event log")]
    [string]$SourceName,
    [Parameter(ParameterSetName = "Classic event logs")]
    [Parameter(ParameterSetName = "Custom event log")]
    [ValidateSet("Error", "Information", "FailureAudit", "SuccessAudit", "Warning")]
    [string]$EntryType = "Information",
    [Parameter(ParameterSetName = "Classic event logs")]
    [Parameter(ParameterSetName = "Custom event log")]
    [int16]$Category
)

try{
    [string[]]$Properties = @('EventID','Index','EntryType','InstanceId','TimeGenerated','UserName')
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName = "."
    } 
    if($PSCmdlet.ParameterSetName -eq "Classic event logs"){
        $CustomLogName = $LogName
        $SourceName = $Source
    }
    $null = Write-EventLog -ComputerName $ComputerName -LogName $CustomLogName -Source $SourceName -Message $Message -EventId $EventID -EntryType $EntryType -Category $Category -ErrorAction Stop

    $result = Get-EventLog -LogName $CustomLogName -ComputerName $ComputerName -Newest 3 | Select-Object $Properties
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