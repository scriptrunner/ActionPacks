#Requires -Version 4.0
#Requires -Modules Hyper-V

<#
    .SYNOPSIS
        Generates a report with the virtual network adapters
    
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
        Specifies the name of the Hyper-V host

    .Parameter AccessAccount
        Specifies the user account that have permission to perform this action

    .Parameter All
        Specifies all virtual network adapters in the system

    .Parameter IncludeVlanProperties
        Specifies show the Vlan properties of the adapters
#>

param(
    [string]$HostName,
    [PSCredential]$AccessAccount,
    [switch]$All,
    [switch]$IncludeVlanProperties
)

Import-Module Hyper-V

try {
    [string[]]$Properties = @('Name','SwitchName','IsManagementOs','MacAddress','Status','IsExternalAdapter','IsDeleted')
    $Script:output = @()
    $Script:adapters = @()
    
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
    if($true -eq $All){
        $cmdArgs.Add('All',$null)
    }
    else {        
        $cmdArgs.Add('ManagementOS',$null)
    }
    $null = Get-VMNetworkAdapter @cmdArgs | Select-Object $Properties | ForEach-Object{
        [string]$status = ''
        if(($null -ne $_.Status) -and ($_.Status.Length -gt 0)){
            $status = $_.Status
        }
        $Script:adapters += [PSCustomObject]@{
            'Name' = $_.Name;
            'SwitchName' = $_.SwitchName;
            'IsManagementOs' = $_.IsManagementOs;
            'MacAddress' = $_.MacAddress;           
            'Status' = $status;
            'IsExternalAdapter' = $_.IsExternalAdapter;
            'IsDeleted' = $_.IsDeleted;
        }
    }
    if($null -ne $Script:adapters){
        if($true -eq $IncludeVlanProperties){
            ForEach($ada in $Script:adapters){
                $Script:output += $ada
                if($ada.IsManagementOs -eq $true){
                    if($null -eq $AccessAccount){
                        $tmp = Get-VMNetworkAdapter -Name $ada.name -ManagementOS
                    }
                    else {
                        $tmp = Get-VMNetworkAdapter -CimSession $Script:Cim -Name $ada.name -ManagementOS
                    }
                    $Script:output += Get-VMNetworkAdapterVlan -VMNetworkAdapter $tmp | Select-Object * -ExcludeProperty "ParentAdapter"
               }
            }
        }
        else {
            $Script:output = $Script:adapters
        }      
    }
    
    ConvertTo-ResultHtml -Result $Script:output
}
catch {
    throw
}
finally{
    if($null -ne $Script:Cim){
        Remove-CimSession $Script:Cim 
    }
}