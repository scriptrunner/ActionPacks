#Requires -Version 4.0

<#
.SYNOPSIS
    Removes exclusions or default actions

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/Defender

.Parameter ExclusionExtension    
    Specifies, comma separated, file name extensions, such as obj or lib, to exclude from scheduled, custom, and real-time scanning

.Parameter ExclusionPath
    Specifies, comma separated, file paths to exclude from scheduled and real-time scanning. 
    You can specify a folder to exclude all the files under the folder

.Parameter HighThreatDefaultAction
    Removes the automatic remediation action specified for the high threat alert level
    
.Parameter LowThreatDefaultAction
    Removes the automatic remediation action specified for the low threat alert level
    
.Parameter ModerateThreatDefaultAction
    Removes the automatic remediation action specified for the moderate threat alert level

.Parameter SevereThreatDefaultAction
    Removes the automatic remediation action specified for the severe threat alert level

.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [string]$ExclusionExtension,
    [string]$ExclusionPath,
    [switch]$HighThreatDefaultAction,
    [switch]$LowThreatDefaultAction,
    [switch]$ModerateThreatDefaultAction,
    [switch]$SevereThreatDefaultAction,
    [string]$ComputerName,
    [PSCredential]$AccessAccount
)

$Script:Cim = $null
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
    if($PSBoundParameters.ContainsKey('ExclusionExtension') -eq $true ){
        $null = Remove-MpPreference -CimSession $Script:Cim -ExclusionExtension $ExclusionExtension.Split(",") -Force -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('ExclusionPath') -eq $true ){
        $null = Remove-MpPreference -CimSession $Script:Cim -ExclusionPath $ExclusionPath.Split(",") -Force -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('HighThreatDefaultAction') -eq $true ){
        $null = Remove-MpPreference -CimSession $Script:Cim  -HighThreatDefaultAction:$HighThreatDefaultAction -Force -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('LowThreatDefaultAction') -eq $true ){
        $null = Remove-MpPreference -CimSession $Script:Cim  -LowThreatDefaultAction:$LowThreatDefaultAction -Force -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('ModerateThreatDefaultAction') -eq $true ){
        $null = Remove-MpPreference -CimSession $Script:Cim  -ModerateThreatDefaultAction:$ModerateThreatDefaultAction -Force -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('SevereThreatDefaultAction') -eq $true ){
        $null = Remove-MpPreference -CimSession $Script:Cim -SevereThreatDefaultAction:$SevereThreatDefaultAction -Force -ErrorAction Stop
    }

    $refs = Get-MpPreference -CimSession $Script:Cim -ErrorAction Stop    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $refs
    }
    else{
        Write-Output $refs
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