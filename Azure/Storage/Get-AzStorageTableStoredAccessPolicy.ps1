#Requires -Version 5.0
#Requires -Modules Az.Storage

<#
    .SYNOPSIS
        Gets the stored access policy or policies for an Azure storage table
    
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

    .Parameter Table
        [sr-en] Specifies the Azure storage table name
        [sr-de] Name der Tabelle

    .Parameter Policy
        [sr-en] Specifies a stored access policy
        [sr-de] Name der Policy
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$StorageAccountName,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$Table,
    [string]$Policy
)

Import-Module Az.Storage

try{
    $azAccount = $null
    GetAzureStorageAccount -AccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -StorageAccount ([ref]$azAccount)
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Context' = $azAccount.Context
                            'Table' = $Table
    }
    if([System.String]::IsNullOrWhiteSpace($Policy) -eq $false){
        $cmdArgs.Add('Policy',$Policy)
    }
    $ret = Get-AzStorageTableStoredAccessPolicy @cmdArgs | Select-Object *

    Write-Output $ret
}
catch{
    throw
}
finally{
}