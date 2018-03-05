#Requires -Version 4.0
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Get local printers from the specified computer

.DESCRIPTION
    
.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
    © AppSphere AG

.COMPONENT
    Requires Module PrintManagement

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinPrintManagement/_QUERY_

.Parameter ComputerName
    Specifies the name of the computer from which to retrieve the printer information
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter PrinterName
    Specifies the name of the printers
#>

[CmdLetBinding()]
Param(
    [string]$ComputerName,
    [PSCredential]$AccessAccount,
    [string]$PrinterName
)

Import-Module PrintManagement

$Script:Cim=$null
try{
    if([System.string]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName=[System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim =New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim =New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }
    [string]$filter ="*"
    if(-not [System.String]::IsNullOrWhiteSpace($PrinterName)){
        $filter ="*$($PrinterName)*"
    }
    if($SRXEnv) {
        $SRXEnv.ResultList =@()
        $SRXEnv.ResultList2 =@()
    }
    $Script:Printers=Get-Printer -Full -CimSession $Script:Cim -ComputerName $ComputerName | Where-Object {$_.Type -eq 'Local'} `
        | Select-Object Name,DriverName,PortName,Shared,Sharename,Comment,Location,Datatype,PrintProcessor,RenderingMode `
        | Where-Object {$_.Name -like $filter} `
        | Sort-Object Name
    foreach($item in $Script:Printers)
    {
        if($SRXEnv) {
            $SRXEnv.ResultList += $item.Name
            $SRXEnv.ResultList2 += $item.Name
        }
        else{
            Write-Output $item.name
        }
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