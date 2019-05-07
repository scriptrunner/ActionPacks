#Requires -Version 5.0
#Requires -Modules Az.Network

<#
    .SYNOPSIS
        Gets a network security group
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
        © AppSphere AG

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
        Specifies the name of the network security group   

    .Parameter ResourceGroupName
        Specifies the name of the resource group that the network security group belongs to. 
        Mandatory when parameter name is set!
        
    .Parameter Properties
        List of properties to expand, comma separated e.g. Name,Location. Use * for all properties
#>

param( 
    [Parameter(Mandatory = $true)]
    [pscredential]$AzureCredential,
    [string]$Name,
    [string]$ResourceGroupName,
    [string]$Properties = "Name,Location,ResourceGroupName,Id,Tags,Etag,ProvisioningState,Subnets,ResourceGuid",
    [string]$Tenant
)

Import-Module Az

try{
  #  ConnectAzure -AzureCredential $AzureCredential -Tenant $Tenant

    if([System.String]::IsNullOrWhiteSpace($Properties)){
        $Properties = '*'
    }
    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}
    
    if([System.String]::IsNullOrWhiteSpace($Name) -eq $false){
        $cmdArgs.Add('Name',$Name)
    }    
    if([System.String]::IsNullOrWhiteSpace($ResourceGroupName) -eq $false){
        $cmdArgs.Add('ResourceGroupName',$ResourceGroupName)
    }

    $ret = Get-AzNetworkSecurityGroup @cmdArgs | Select-Object $Properties.Split(',')

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