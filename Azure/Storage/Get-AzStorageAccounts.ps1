#Requires -Version 5.0
#Requires -Modules Az.Storage

<#
    .SYNOPSIS
        Gets the storage accounts
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module Az.Storage

    .Parameter Name
        [sr-en] Specifies the name of the Storage account
        [sr-de] Name des Storage Accounts
        
    .Parameter ResourceGroupName
        [sr-en] Specifies the name of the resource group that contains the Storage accounts
        [sr-de] Name der resource group die die Storage Accounts enthält

    .Parameter IncludeGeoReplicationStats
        [sr-en] Get the GeoReplicationStats of the Storage account
        [sr-de] Gibt die Geo-Replikations-Statistiken mit zurück

    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param( 
    [Parameter(Mandatory = $true,ParameterSetName = "ByName")]
    [string]$Name,
    [Parameter(ParameterSetName = "ByResourceGroup")]
    [Parameter(Mandatory = $true,ParameterSetName = "ByName")]
    [string]$ResourceGroupName,
    [Parameter(ParameterSetName = "ByName")]
    [switch]$IncludeGeoReplicationStats,
    [ValidateSet('*','ResourceGroupName','StorageAccountName','Location','StatusOfPrimary','Id','CreationTime','ProvisioningState','PrimaryLocation','EnableHttpsTrafficOnly')]
    [string[]]$Properties = @('ResourceGroupName','StorageAccountName','Location','Id')
)

Import-Module Az.Storage

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}
    
    if([System.String]::IsNullOrWhiteSpace($ResourceGroupName) -eq $false){
        $cmdArgs.Add('ResourceGroupName',$ResourceGroupName)
    }
    if($PSCmdlet.ParameterSetName -eq 'ByName'){
        $cmdArgs.Add('Name',$Name)
        $cmdArgs.Add('IncludeGeoReplicationStats',$IncludeGeoReplicationStats)
    }

    $ret = Get-AzStorageAccount @cmdArgs | Select-Object $Properties

    Write-Output $ret
}
catch{
    throw
}
finally{
}