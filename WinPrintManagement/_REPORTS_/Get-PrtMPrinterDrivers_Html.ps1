#Requires -Version 4.0
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Generates a report with one or all printer drivers from the computer

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
    Requires Library Script ReportLibrary from the Action Pack Reporting\_LIB_

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinPrintManagement/_REPORTS_ 
    
.Parameter DriverName
    Specifies the name of the printer driver to retrieve

.Parameter ComputerName
    Specifies the name of the computer from which to retrieve the printer driver
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter Properties
    List of properties to expand. Use * for all properties
#>

[CmdLetBinding()]
Param(
    [string]$DriverName,
    [string]$ComputerName,
    [PSCredential]$AccessAccount,
    [ValidateSet('*','Name','Description','InfPath','ConfigFile', 'MajorVersion','PrinterEnvironment','PrintProcessor')]
    [string[]]$Properties = @('Name','InfPath','ConfigFile','MajorVersion','PrinterEnvironment','PrintProcessor')
)

Import-Module PrintManagement

$Script:Cim = $null
try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName = [System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim = New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'CimSession' = $Script:Cim
                            'ComputerName' = $ComputerName
                            }
    if([System.String]::IsNullOrWhiteSpace($DriverName) -eq $false){
        $cmdArgs.Add("Name",$DriverName)
    }
    $drivers = Get-PrinterDriver @cmdArgs | Select-Object $Properties | Sort-Object Name    
    ConvertTo-ResultHtml -Result $drivers
}
catch{
    throw
}
finally{
    if($null -ne $Script:Cim){
        Remove-CimSession $Script:Cim 
    }
}