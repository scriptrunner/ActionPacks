#Requires -Version 4.0
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Renames the specified printer

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
    Specifies the name of the printer to rename

.Parameter NewName
    Specifies the new name of the printer
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>
   
[CmdLetBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [string]$PrinterName,
    [Parameter(Mandatory=$true)]
    [string]$NewName,
    [PSCredential]$AccessAccount
)

$Script:Cim = $null
try{
    [string]$ComputerName = [System.Net.DNS]::GetHostByName('').HostName
    if($null -eq $AccessAccount){
        $Script:Cim =New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim =New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }
    $prn = Get-Printer -Name $PrinterName -ComputerName $ComputerName -CimSession $Script:Cim -ErrorAction Stop

    $null = Rename-Printer -CimSession $Script:Cim -InputObject $prn -NewName $NewName -ErrorAction Stop    
    if($SRXEnv) {
        $SRXEnv.ResultMessage ="Printer $($PrinterName) on $($ComputerName) renamed to $($NewName)"
    }
    else{
        Write-Output "Printer $($PrinterName) on $($ComputerName) renamed to $($NewName)"
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