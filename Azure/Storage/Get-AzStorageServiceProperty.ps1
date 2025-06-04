#Requires -Version 5.0
#Requires -Modules Az.Storage

<#
    .SYNOPSIS
        Gets properties for Azure Storage services
    
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
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$StorageAccountName,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [ValidateSet('Blob','Table','Queue','File')]
    [string]$ServiceType
)

Import-Module Az.Storage

try{
    $azAccount = $null
    GetAzureStorageAccount -AccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -StorageAccount ([ref]$azAccount)
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Context' = $azAccount.Context
                            'ServiceType' = $ServiceType
    }

    $ret = @()
    $null = Get-AzStorageServiceProperty @cmdArgs | Select-Object * | ForEach-Object{
        $ret += [PSCustomObject] @{
            'DefaultServiceVersion' = $_.DefaultServiceVersion
            'StaticWebsite' = $_.StaticWebsite
            'HourMetrics' = (Select-Object -ExpandProperty $_.HourMetrics)            
            'MinuteMetrics' = (Select-Object -ExpandProperty $_.MinuteMetrics)
            'Logging' = (Select-Object -ExpandProperty $_.Logging)
        }
    }

    Write-Output $ret
}
catch{
    throw
}
finally{
}