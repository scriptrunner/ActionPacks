#Requires -Version 4.0

<#
.SYNOPSIS
    Creates a new event log and a new event source on the computer 

.DESCRIPTION
    When you create a new event log and a new event source, the system registers the new source for the new log, but the log is not created until the first entry is written to it

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

.Parameter SourceName
    Specifies the names of the event log sources, such as application programs that write to the event log

.Parameter ComputerName
    Specifies remote computer, the default is the local computer.

.Parameter CategoryResourceFile
    Specifies the path of the file that contains category strings for the source events

.Parameter MessageResourceFile
    Specifies the path of the file that contains message formatting strings for the source events

.Parameter ParameterResourceFile
    Specifies the path of the file that contains strings used for parameter substitutions in event descriptions
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$LogName,
    [Parameter(Mandatory = $true)]
    [string]$SourceName,
    [string]$ComputerName,
    [string]$CategoryResourceFile,
    [string]$MessageResourceFile,
    [string]$ParameterResourceFile
)

try{
    [string[]]$Properties = @('Log','LogDisplayName','MaximumKilobytes','OverflowAction','MinimumRetentionDays')
    
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName = "."
    }   
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'ComputerName' = $ComputerName 
                            'Source' = $SourceName
                            'LogName' = $LogName
                            }
    if(-not [System.String]::IsNullOrWhiteSpace($CategoryResourceFile)){
        $cmdArgs.Add('CategoryResourceFile', $CategoryResourceFile)
    }
    if(-not [System.String]::IsNullOrWhiteSpace($MessageResourceFile)){
        $cmdArgs.Add('MessageResourceFile', $MessageResourceFile)
    }
    if(-not [System.String]::IsNullOrWhiteSpace($ParameterResourceFile)){
        $cmdArgs.Add('ParameterResourceFile', $ParameterResourceFile)
    }
    $null = New-EventLog @cmdArgs

    $result = Get-EventLog -List -ComputerName $ComputerName | Where-Object -Property "Log" -eq $LogName  | Select-Object $Properties
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