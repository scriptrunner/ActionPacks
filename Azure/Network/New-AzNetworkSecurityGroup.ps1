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
        https://github.com/scriptrunner/ActionPacks/blob/master/Azure        

    .Parameter AzureCredential
        The PSCredential object provides the user ID and password for organizational ID credentials, or the application ID and secret for service principal credentials

    .Parameter Tenant
        Tenant name or ID

    .Parameter Name
        Specifies the name of the network security group to create   

    .Parameter ResourceGroupName
        Specifies the name of a resource group

    .Parameter Location
        Specifies the region for which to create a network security group
#>

param( 
    [Parameter(Mandatory = $true)]
    [pscredential]$AzureCredential,
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,    
    [Parameter(Mandatory = $true)]
    [string]$Location,
    [string]$Tenant
)

Import-Module Az

try{
    [string[]]$Properties = @('Name','Location','ResourceGroupName','Id','Tags','Etag','ProvisioningState','Subnets','ResourceGuid')

#    ConnectAzure -AzureCredential $AzureCredential -Tenant $Tenant

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
  #  DisconnectAzure -Tenant $Tenant
}