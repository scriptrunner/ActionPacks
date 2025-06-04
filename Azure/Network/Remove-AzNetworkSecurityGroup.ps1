#Requires -Version 5.0
#Requires -Modules Az.Network

<#
    .SYNOPSIS
        Removes a network security group
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module Az.Network

    .Parameter Name
        [sr-en] Specifies the name of the network security group to remove
        [sr-de] Namen der zu löschenden Network Security Group

    .Parameter ResourceGroupName        
        [sr-en] Specifies the name of a resource group that removes the network security group from
        [sr-de] Name der Resource Group
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName
)

Import-Module Az.Network

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Confirm' = $false
                            'Force' = $null
                            'Name' = $Name
                            'ResourceGroupName' = $ResourceGroupName
                            }

    $null = Remove-AzNetworkSecurityGroup @cmdArgs 
    $ret = "Network security group $($Name) removed"

    Write-Output $ret
}
catch{
    throw
}
finally{
}