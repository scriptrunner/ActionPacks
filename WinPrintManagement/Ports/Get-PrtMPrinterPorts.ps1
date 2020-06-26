#Requires -Version 4.0
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Retrieves a list of printer ports installed on the specified computer

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinPrintManagement/Ports

.Parameter ComputerName
    Specifies the name of the computer from which to retrieve the printer ports
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter Properties
    List of properties to expand, comma separated e.g. Name,Description. Use * for all properties
#>

[CmdLetBinding()]
Param(
    [string]$ComputerName,
    [PSCredential]$AccessAccount,
    [ValidateSet('*','Caption','Name','Description','Status')]
    [string[]]$Properties = @('Caption','Name','Description','Status')
)

Import-Module PrintManagement

$Script:Cim = $null
try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    else{
        if($null -eq ($Properties | Where-Object {$_ -like 'Name'})){
            $Properties += 'Name'
        }
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
    $ports = Get-PrinterPort -CimSession $Script:Cim -ComputerName $ComputerName -ErrorAction Stop  `
                                    | Select-Object $Properties | Sort-Object Name | Format-List    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $ports 
    }
    else{
        Write-Output $ports
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