#Requires -Version 5.0
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Gets the configuration information of a printer

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinPrintManagement/Printers

.Parameter PrinterName
    [sr-en] Name of the printer from which to retrieve the configuration information

.Parameter ComputerName
    [sr-en] Name of the computer from which to retrieve the printer configuration information
    
.Parameter AccessAccount
    [sr-en] User account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>
   
[CmdLetBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [string]$PrinterName,
    [string]$ComputerName,
    [PSCredential]$AccessAccount
)

Import-Module PrintManagement

$Script:Cim = $null
try{
    if([System.string]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName = [System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim = New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }
    
    $conf = Invoke-CimMethod -ClassName MSFT_PrinterConfiguration -Namespace 'ROOT/StandardCimv2' -MethodName GetByPrinterName -Arguments @{'PrinterName'=$PrinterName} | foreach-object cmdletOutput | Format-List

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $conf
    }
    else{
        Write-Output $conf
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