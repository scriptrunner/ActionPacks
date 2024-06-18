#Requires -Version 5.0

<#
.SYNOPSIS
    Gets the events in an event log

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

.Parameter EntryType
    [sr-en] Entry type of the events

.Parameter Index
    [sr-en] Index values

.Parameter InstanceId
    [sr-en] Instance IDs

.Parameter MaximumItems
    [sr-en] Maximum number of events, beginning with the newest event in the log.

.Parameter Message
    [sr-en] String in the event message. 
    You can use this property to search for messages that contain certain words or phrases. Wildcards are permitted

.Parameter Properties
    [sr-en] List of properties to expand, comma separated e.g. EventID,Index. Use * for all properties
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "Classic event logs")]
    [ValidateSet("Application","HardwareEvents","Internet Explorer","Key Management Service","Security","System","Windows PowerShell")]
    [string]$LogName,
    [Parameter(Mandatory = $true, ParameterSetName = "Custom event log")]
    [string]$CustomLogName,
    [Parameter(ParameterSetName = "Classic event logs")]
    [Parameter(ParameterSetName = "Custom event log")]
    [string]$ComputerName,
    [ValidateSet("All","Error", "Information", "FailureAudit", "SuccessAudit", "Warning")]
    [string]$EntryType = "All",
    [int32]$Index,
    [int64]$InstanceId,
    [int32]$MaximumItems=100,
    [string]$Message,
    [ValidateSet('*','EventID','Index','EntryType','InstanceId','TimeGenerated','UserName')]
    [string[]]$Properties = @('EventID','Index','EntryType','InstanceId','TimeGenerated','UserName')
)

try{
    $Script:output
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName = "."
    }  
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    else{
        if($null -eq ($Properties | Where-Object {$_ -like 'TimeWritten'})){
            $Properties += "TimeWritten"
        }
    }

    if($PSCmdlet.ParameterSetName  -eq "Classic event logs"){
        $CustomLogName = $LogName
    }    
    if($EntryType -eq "All"){
        if([System.String]::IsNullOrWhiteSpace($Message)){
            $Script:items = Get-EventLog -LogName $CustomLogName -ComputerName $ComputerName | Select-Object *
        }
        else {
            $Script:items = Get-EventLog -LogName $CustomLogName -ComputerName $ComputerName -Message $Message | Select-Object *
        }
    }
    else {
        if([System.String]::IsNullOrWhiteSpace($Message)){
            $Script:items = Get-EventLog -LogName $CustomLogName -ComputerName $ComputerName -EntryType $EntryType | Select-Object *
        }
        else {
            $Script:items = Get-EventLog -LogName $CustomLogName -ComputerName $ComputerName -EntryType $EntryType -Message $Message | Select-Object *
        }
    }
    if($PSBoundParameters.ContainsKey('Index') -eq $true ){
        $Script:items = $Script:items | Where-Object -Property Index -eq $Index
    }
    if($PSBoundParameters.ContainsKey('InstanceId') -eq $true ){
        $Script:items = $Script:items | Where-Object -Property InstanceId -eq $InstanceId
    }
    if(($null -ne $Script:items) -and ($Script:items.length -gt 0)){
        $Script:output = $Script:items[0..$MaximumItems] | Select-Object $Properties `
                | Sort-Object TimeWritten | Format-List
    }

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:output
    }
    else{
        Write-Output $Script:output
    }
}
catch{
    throw
}
finally{
}