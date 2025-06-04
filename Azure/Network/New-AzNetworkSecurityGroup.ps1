#Requires -Version 5.0
#Requires -Modules Az.Network

<#
    .SYNOPSIS
        Creates a network security group
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module Az.Network

    .Parameter Name
        [sr-en] Specifies the name of the network security group to create
        [sr-de] Namen der zu erstellenden Network Security Group   

    .Parameter ResourceGroupName
        [sr-en] Specifies the name of a resource group
        [sr-de] Name der Resource Group

    .Parameter Location
        [sr-en] Specifies the region for which to create a network security group
        [sr-de] Gibt die Location an, für die eine Network Security Group erstellt wird
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,    
    [Parameter(Mandatory = $true)]
    [string]$Location
)

Import-Module Az.Network

try{
    [string[]]$Properties = @('Name','Location','ResourceGroupName','Id','Tags','Etag','ProvisioningState','Subnets','ResourceGuid')

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Confirm' = $false
                            'Force' = $null
                            'Name' = $Name
                            'ResourceGroupName' = $ResourceGroupName
                            'Location' =$Location
                            }

    $ret = New-AzNetworkSecurityGroup @cmdArgs | Select-Object $Properties

    Write-Output $ret
}
catch{
    throw
}
finally{
}