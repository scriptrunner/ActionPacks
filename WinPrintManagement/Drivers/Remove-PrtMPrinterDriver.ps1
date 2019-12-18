#Requires -Version 4.0
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Deletes printer driver from the specified computer

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Module PrintManagement

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinPrintManagement/Drivers

.Parameter DriverName
    Specifies the name of the printer driver to remove

.Parameter ComputerName
    Specifies the name of the computer from which to remove the printer driver
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter RemoveFromDriverStore
    Specifies whether to remove the printer driver from the driver store
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$DriverName,
    [string]$ComputerName,
    [PSCredential]$AccessAccount,
    [switch]$RemoveFromDriverStore
)

Import-Module PrintManagement

$Script:Cim = $null
try{
    if([System.string]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName=[System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim = New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('RemoveFromDriverStore') -eq $true){
        $null = Remove-PrinterDriver -CimSession $Script:Cim -Name $DriverName -ComputerName $ComputerName -RemoveFromDriverStore -ErrorAction Stop
    }
    else {
        $null = Remove-PrinterDriver -CimSession $Script:Cim -Name $DriverName -ComputerName $ComputerName -ErrorAction Stop
    }
    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Printer driver $($DriverName) removed from $($ComputerName)"
    }
    else{
        Write-Output "Printer driver $($DriverName) removed from $($ComputerName)"
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