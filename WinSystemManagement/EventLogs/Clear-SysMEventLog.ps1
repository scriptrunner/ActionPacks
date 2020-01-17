#Requires -Version 4.0

<#
.SYNOPSIS
    Clears all entries from specified event log

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
    Specifies the event log

.Parameter CustomLogName
    Specifies the name of the custom event log, enter the log name (not the LogDisplayName)

.Parameter ComputerName
    Specifies remote computer, the default is the local computer.
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
    [string]$ComputerName
)

try{
    [string[]]$Properties = @('Log','LogDisplayName','MaximumKilobytes','OverflowAction','MinimumRetentionDays')
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName = "."
    } 
    if($PSCmdlet.ParameterSetName  -eq "Classic event logs"){
        $CustomLogName = $LogName
    }
    Clear-EventLog -ComputerName $ComputerName -LogName $CustomLogName -Confirm:$false -ErrorAction Stop

    $result = Get-EventLog -List -ComputerName $ComputerName | Where-Object -Property "Log" -eq $CustomLogName  | Select-Object $Properties
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