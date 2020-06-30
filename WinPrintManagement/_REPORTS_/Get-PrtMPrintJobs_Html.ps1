#Requires -Version 4.0
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Generates a report with one or all print jobs on the specified printer

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

.Parameter PrinterName
    Specifies the name of the printer from which to retrieve the print job information

.Parameter JobID
    Specifies the ID of a print job to remove on the specified printer

.Parameter ComputerName
    Specifies the name of the computer from which to retrieve the print job information
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter Properties
    List of properties to expand, comma separated e.g. Name,Description. Use * for all properties
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$PrinterName,
    [int]$JobID,
    [string]$ComputerName,
    [PSCredential]$AccessAccount,
    [ValidateSet('*','ID','JobStatus','DocumentName','UserName','Position','Size','PagesPrinted','TotalPages','SubmittedTime','Priority')]
    [string[]]$Properties = @('ID','JobStatus','DocumentName','UserName','Priority')
)

Import-Module PrintManagement

$Script:Cim=$null
try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    else{
        if($null -eq ($Properties | Where-Object {$_ -like 'ID'})){
            $Properties += 'ID'
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
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'CimSession' = $Script:Cim
                            'ComputerName' = $ComputerName
                            'PrinterName' = $PrinterName
                            }
    if($JobID -gt 0){
        $cmdArgs.Add("ID", $JobID)
    }

    $jobs = Get-PrintJob @cmdArgs | Select-Object $Properties | Sort-Object ID
    ConvertTo-ResultHtml -Result $jobs
}
catch{
    throw
}
finally{
    if($null -ne $Script:Cim){
        Remove-CimSession $Script:Cim 
    }
}