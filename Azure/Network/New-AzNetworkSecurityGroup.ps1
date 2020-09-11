#Requires -Version 5.0
#Requires -Modules Az.Network

<#
    .SYNOPSIS
        Creates a network security group
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module Az
        Requires Library script AzureAzLibrary.ps1

    .LINK
        https://github.com/scriptrunner/ActionPacks/blob/master/Azure/Network

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

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $ret 
    }
    else{
        Write-Output $ret
    }
}
catch{
    throw
}
finally{
}