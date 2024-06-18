#Requires -Version 5.0

<#
.SYNOPSIS
    Export the event log on the computer

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

.Parameter AccessAccount
    [sr-en] User account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter BackupPath
    [sr-en] Path on the computer to save the backup

.EXAMPLE
    Export-CltMEventLog -LogName Security -BackupPath C:\Temp
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
    [string]$BackupPath,
    [Parameter(ParameterSetName = "Classic event logs")]
    [Parameter(ParameterSetName = "Custom event log")]
    [string]$ComputerName,
    [Parameter(ParameterSetName = "Classic event logs")]
    [Parameter(ParameterSetName = "Custom event log")]
    [PSCredential]$AccessAccount
)

try{
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName = [System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim = New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }
    if($PSCmdlet.ParameterSetName  -eq "Classic event logs"){
        $CustomLogName = $LogName
    }
    $quy = [System.String]::Format("SELECT * FROM Win32_NTEventLogFile WHERE Filename = '{0}'",$CustomLogName)
    $cimcl = Get-CimInstance -CimSession $Script:Cim -Query $quy
    $buFile = $BackupPath + "\$($CustomLogName).evtx"

    $null = Invoke-CimMethod -InputObject $cimcl -MethodName BackupEventlog -Arguments @{ ArchiveFileName = $buFile } -ErrorAction Stop
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Event log: $($CustomLogName) successfully exported"
    }
    else{
        Write-Output "Event log: $($CustomLogName) successfully exported"
    }
}
catch{
    throw
}
finally{
    if($null -ne $Script:Cim){
        Remove-CimSession $Script:Cim 
    }
}