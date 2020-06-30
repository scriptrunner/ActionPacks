#Requires -Version 4.0

<#
.SYNOPSIS
    Generates a report with the permissions of one or all shares

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT 
    Requires Library Script ReportLibrary from the Action Pack Reporting\_LIB_

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinFileManagement/_REPORTS_

.Parameter ShareName
    Specifies the name of the share

.Parameter ComputerName
    Specifies the name of the computer from which to retrieve the share permissions
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [string]$ComputerName,
    [PSCredential]$AccessAccount,
    [string]$ShareName
)

$Script:Cim = $null
[string[]]$Script:Properties = @("Name","AccessControlType","AccessRight","AccountName")
try{
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName = [System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim =New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim =New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'CimSession' = $Script:Cim
                            'ComputerName' = $ComputerName
                            }
    if([System.String]::IsNullOrWhiteSpace($ShareName) -eq $false){
        $cmdArgs.Add('Name',$ShareName)
    }
    $objShare = Get-SmbShare @cmdArgs | Get-SmbShareAccess |  Sort-Object Name,AccountName | Select-Object $Script:Properties 

    ConvertTo-ResultHtml -Result $objShare
}
catch{
    throw
}
finally{
    if($null -ne $Script:Cim){
        Remove-CimSession $Script:Cim 
    }
}