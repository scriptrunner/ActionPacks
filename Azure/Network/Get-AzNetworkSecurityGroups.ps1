#Requires -Version 5.0
#Requires -Modules Az.Network

<#
    .SYNOPSIS
        Gets a network security group
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module Az.Network

    .Parameter Name
        [sr-en] Specifies the name of the network security group   
        [sr-de] Namen der Network Security Group

    .Parameter ResourceGroupName
        [sr-en] Specifies the name of the resource group that the network security group belongs to. 
        Mandatory when parameter name is set!
        [sr-de] Name der Resource Group
        Mandatory, wenn der Parameter Name angegeben wird
        
    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param( 
    [string]$Name,
    [string]$ResourceGroupName,
    [ValidateSet('*','Name','Location','ResourceGroupName','Id','Tags','Etag','ProvisioningState','Subnets','ResourceGuid')]
    [string[]]$Properties = @('Name','Location','ResourceGroupName','Id','Tags','Etag','ProvisioningState','Subnets','ResourceGuid')
)

Import-Module Az.Network

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}
    
    if([System.String]::IsNullOrWhiteSpace($Name) -eq $false){
        $cmdArgs.Add('Name',$Name)
    }    
    if([System.String]::IsNullOrWhiteSpace($ResourceGroupName) -eq $false){
        $cmdArgs.Add('ResourceGroupName',$ResourceGroupName)
    }

    $ret = Get-AzNetworkSecurityGroup @cmdArgs | Select-Object $Properties

    Write-Output $ret
}
catch{
    throw
}
finally{
}