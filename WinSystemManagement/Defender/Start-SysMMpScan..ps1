#Requires -Version 4.0

<#
.SYNOPSIS
    Starts a scan on a computer

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
    © AppSphere AG

.COMPONENT

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinClientManagement/Defender

.Parameter ScanPath
    Specifies a file or a folder path to scan

.Parameter ScanType
    Specifies the type of scan

.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.EXAMPLE

#>

[CmdLetBinding()]
Param(
    [string]$ScanPath,
    [ValidateSet("FullScan", "QuickScan", "CustomScan")]
    [string]$ScanType = "QuickScan",
    [string]$ComputerName,
    [PSCredential]$AccessAccount
)

$Script:Cim=$null
try{
    if([System.String]::IsNullOrWhiteSpace($ScanPath)){
        $ScanPath = "*"
    }
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName=[System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim = New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }
    $job = Start-MpScan -CimSession $Script:Cim -AsJob -ScanType $ScanType -ScanPath $ScanPath -ErrorAction Stop
    $res = Get-Job -Id $job.ID | Select-Object ID,Location,StatusMessage,JobStateInfo,PSBeginTime,PSEndTime
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $res
    }
    else{
        Write-Output $res
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