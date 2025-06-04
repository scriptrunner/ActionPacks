#Requires -Version 5.0
#Requires -Modules Az.Storage

<#
    .SYNOPSIS
        Gets service properties for Azure Storage Blob services
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module Az.Storage

    .Parameter StorageAccountName 
        [sr-en] Specifies the name of the Storage account
        [sr-de] Name des Storage Accounts
        
    .Parameter ResourceGroupName
        [sr-en] Specifies the name of the resource group
        [sr-de] Name der resource group

    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$StorageAccountName,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [ValidateSet('*','StorageAccountName','ResourceGroupName','DefaultServiceVersion','ChangeFeed','IsVersioningEnabled','DeleteRetentionPolicy.Enabled','DeleteRetentionPolicy.Days','RestorePolicy.Enabled','RestorePolicy.Days')]
    [string[]]$Properties = @('StorageAccountName','ResourceGroupName','DefaultServiceVersion','ChangeFeed','IsVersioningEnabled')
)

Import-Module Az.Storage

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'StorageAccountName' = $StorageAccountName
                            'ResourceGroupName' = $ResourceGroupName
    }

    $ret = Get-AzStorageBlobServiceProperty @cmdArgs | Select-Object $Properties

    Write-Output $ret
}
catch{
    throw
}
finally{
}