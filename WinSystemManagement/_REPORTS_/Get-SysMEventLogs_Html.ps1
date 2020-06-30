#Requires -Version 4.0

<#
.SYNOPSIS
    Generates a report with event logs

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Library Script ReportLibrary from the Action Pack Reporting\_LIB_

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/_REPORTS_ 

.Parameter LogName
    Specifies the event log

.Parameter LogType
    Specifies the entry type of the events that this cmdlet gets
    
.Parameter MaxItems
    Specifies the number of the newest events
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("Application","HardwareEvents","Internet Explorer","Key Management Service","Security","System","Windows PowerShell")]
    [string]$LogName = 'Application',
    [Validateset('Error','Warning','Information','FailureAudit','SuccessAudit')]
    [string[]]$LogType = @('Error','Warning'),
    [int]$MaxItems = 50
)

try{
    [string[]]$Properties = @('TimeWritten','EntryType','Source','Message')
    [string] $ComputerName = "."

    $output = Get-EventLog  -ComputerName $ComputerName -LogName $LogName -Newest $MaxItems -EntryType $LogType -ErrorAction Stop  | Select-Object $Properties
    
    ConvertTo-ResultHtml -Result $output
}
catch{
    throw
}
finally{
}