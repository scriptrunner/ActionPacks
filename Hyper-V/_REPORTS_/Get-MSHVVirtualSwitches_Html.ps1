﻿#Requires -Version 5.0
#Requires -Modules Hyper-V

<#
    .SYNOPSIS
        Generates a report with the virtual switches from the Hyper-V host
    
    .DESCRIPTION  
        Supports the execution on Windows Server 2016 / Windows 10 or newer

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module Hyper-V
        Requires Library Script ReportLibrary from the Action Pack Reporting\_LIB_

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/Hyper-V/_REPORTS_

    .Parameter HostName
        [sr-en] Name of the Hyper-V host

    .Parameter AccessAccount
        [sr-en] User account that have permission to perform this action

    .Parameter SwitchType
        [sr-en] Type of the virtual switches to be retrieved
#>

param(
    [string]$HostName,
    [PSCredential]$AccessAccount,    
    [ValidateSet('All','External','Internal','Private')]
    [string]$SwitchType = "All"
)

Import-Module Hyper-V

try {
    [string[]]$Properties = @('Name','ID','Notes','SwitchType','AllowManagementOS','IovEnabled','IsDeleted')
     
    if([System.String]::IsNullOrWhiteSpace($HostName)){
        $HostName = "."
    }

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}
    if($null -eq $AccessAccount){
        $cmdArgs.Add('ComputerName',$HostName)
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $HostName -Credential $AccessAccount
        $cmdArgs.Add('CimSession',$Script:Cim)
    }     
    if($SwitchType -ne 'All'){
        $cmdArgs.Add('SwitchType',$SwitchType)
    }    
    $output = Get-VMSwitch @cmdArgs | Select-Object $Properties

    ConvertTo-ResultHtml -Result $output
}
catch {
    throw
}
finally{
    if($null -ne $Script:Cim){
        Remove-CimSession $Script:Cim 
    }
}