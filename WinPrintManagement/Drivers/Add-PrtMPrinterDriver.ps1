#Requires -Version 4.0
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Installs a printer driver on the specified computer

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
    Specifies the name of the printer driver

.Parameter ComputerName
    Specifies the name of the computer on which to install the printer driver
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter InfFilePath
    Specifies the path of the printer driver INF file in the driver store. INF files contain information about the printer and the printer driver.
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$DriverName,
    [string]$ComputerName,
    [PSCredential]$AccessAccount,
    [string]$InfFilePath
)

Import-Module PrintManagement

$Script:Cim = $null
try{
    [string[]]$Properties = @('Name','Description','InfPath','ConfigFile','MajorVersion','PrinterEnvironment','PrintProcessor') 
    if([System.string]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName = [System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim = New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('InfFilePath') -eq $true){
        Add-PrinterDriver -CimSession $Script:Cim -Name $DriverName -ComputerName $ComputerName -InfPath $InfFilePath -ErrorAction Stop
    }
    else {
        Add-PrinterDriver -CimSession $Script:Cim -Name $DriverName -ComputerName $ComputerName -ErrorAction Stop
    }
    
    $driver = Get-PrinterDriver -CimSession $Script:Cim -Name $DriverName -ComputerName $ComputerName -ErrorAction Stop  `
                        | Select-Object $Properties
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $driver
    }
    else{
        Write-Output $driver
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