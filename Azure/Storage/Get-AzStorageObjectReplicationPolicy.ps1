#Requires -Version 5.0
#Requires -Modules Az.Storage

<#
    .SYNOPSIS
        Gets or lists object replication policy of a Storage account
    
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

    .Parameter PolicyId
        [sr-en] Object Replication Policy Id
        [sr-de] Replication Policy ID
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$StorageAccountName,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [string]$PolicyId
)

Import-Module Az.Storage

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'StorageAccountName' = $StorageAccountName
                            'ResourceGroupName' = $ResourceGroupName
    }
    if([System.String]::IsNullOrWhiteSpace($PolicyId) -eq $false){
        $cmdArgs.Add('PolicyId',$PolicyId)
    }
    $ret = Get-AzStorageObjectReplicationPolicy @cmdArgs | Select-Object *

    Write-Output $ret
}
catch{
    throw
}
finally{
}