#Requires -Version 4.0

<#
.SYNOPSIS
    Sets the event log properties that limit the size of the event log and the age of its entries

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
    Specifies the event log, enter the log name (not the LogDisplayName)

.Parameter CustomLogName
    Specifies the name of the custom event log, enter the log name (not the LogDisplayName)

.Parameter ComputerName
    Specifies remote computer, the default is the local computer.
    
.Parameter MaximumSize
    Specifies the maximum size of the event logs in bytes. The value must be divisible by 64 KB (65536).
    
.Parameter OverflowAction
    Specifies what happens when the event log reaches its maximum size

.Parameter RetentionDays
    Specifies the minimum number of days that an event must remain in the event log
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
    [Parameter(ParameterSetName = "Classic event logs")]
    [Parameter(ParameterSetName = "Custom event log")]
    [int64]$MaximumSize,
    [Parameter(ParameterSetName = "Classic event logs")]
    [Parameter(ParameterSetName = "Custom event log")]
    [ValidateSet("OverwriteOlder", "OverwriteAsNeeded", "DoNotOverwrite")]
    [string]$OverflowAction,
    [Parameter(ParameterSetName = "Classic event logs")]
    [Parameter(ParameterSetName = "Custom event log")]
    [int32]$RetentionDays
)

try{
    [string[]]$Properties = @('Log','LogDisplayName','MaximumKilobytes','OverflowAction','MinimumRetentionDays')
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName = "."
    }
    if($PSCmdlet.ParameterSetName  -eq "Classic event logs"){
        $CustomLogName = $LogName
    }
    $Script:Log = Get-EventLog -List -ComputerName $ComputerName | Where-Object -Property "Log" -eq $CustomLogName
    if($null -ne $Script:Log){
        if($PSBoundParameters.ContainsKey('MaximumSize') -eq $true ){
            Limit-EventLog -LogName $CustomLogName -ComputerName $ComputerName -Confirm:$false -MaximumSize $MaximumSize -ErrorAction Stop
        }
        if($PSBoundParameters.ContainsKey('OverflowAction') -eq $true ){
            if($OverflowAction -eq "OverwriteOlder"){
                Limit-EventLog -LogName $CustomLogName -ComputerName $ComputerName -Confirm:$false -OverflowAction $OverflowAction -RetentionDays 7 -ErrorAction Stop
            }
            else {
                Limit-EventLog -LogName $CustomLogName -ComputerName $ComputerName -Confirm:$false -OverflowAction $OverflowAction -ErrorAction Stop
            }
        }
        if(($PSBoundParameters.ContainsKey('RetentionDays') -eq $true) -and `
            (($OverflowAction -eq "OverwriteOlder") -or ([System.String]::IsNullOrWhiteSpace($OverflowAction) -eq $true))){
            Limit-EventLog -LogName $CustomLogName -ComputerName $ComputerName -Confirm:$false -RetentionDays $RetentionDays -ErrorAction Stop
        }
        $Script:output = Get-EventLog -List -ComputerName $ComputerName | Where-Object -Property "Log" -eq $CustomLogName | Select-Object $Properties
    }
    else{
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "Log $($CustomLogName) not found"
        } 
        Throw  "Log $($CustomLogName) not found"
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