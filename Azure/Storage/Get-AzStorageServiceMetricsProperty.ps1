#Requires -Version 5.0
#Requires -Modules Az.Storage

<#
    .SYNOPSIS
        Gets metrics properties for the Azure Storage service
    
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

    .Parameter ServiceType
        [sr-en] Specifies the Azure Storage service type
        [sr-de] Azure Storage Service Typ

    .Parameter MetricsType
        [sr-en] Specifies a metrics type
        [sr-de] Metric Typ
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$StorageAccountName,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [ValidateSet('Blob','Table','Queue','File')]
    [string]$ServiceType,
    [Parameter(Mandatory = $true)]
    [ValidateSet('Hour','Minute')]
    [string]$MetricsType = 'Hour'
)

Import-Module Az.Storage

try{
    $azAccount = $null
    GetAzureStorageAccount -AccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -StorageAccount ([ref]$azAccount)
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Context' = $azAccount.Context
                            'ServiceType' = $ServiceType
                            'MetricsType' = $MetricsType
    }

    $ret = Get-AzStorageServiceMetricsProperty @cmdArgs | Select-Object *

    Write-Output $ret
}
catch{
    throw
}
finally{
}