#Requires -Version 5.0
#Requires -Modules Az.Storage

<#
    .SYNOPSIS
        Downloads a storage blob, existing files are overwritten
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module Az.Storage

    .Parameter StorageAccountName 
        [sr-en] Specifies the name of the Storage account to get containers
        [sr-de] Name des Storage Accounts
        
    .Parameter ResourceGroupName
        [sr-en] Specifies the name of the resource group that contains the Storage containers to get
        [sr-de] Name der resource group die die Storage Container enthält

    .Parameter Container
        [sr-en] Specifies the name of the container
        [sr-de] Name des Containers

    .Parameter BlobNames
        [sr-en] Specifies the names of the blobs to be downloaded
        [sr-de] Namen der Dateien die heruntergeladen werden

    .Parameter CheckMd5 
        [sr-en] Specifies whether to check the Md5 sum for the downloaded file
        [sr-de] Überprüfen der Md5-Summe für die heruntergeladene Datei

    .Parameter ConcurrentTaskCount 
        [sr-en] Specifies the maximum concurrent network calls
        [sr-de] Maximale gleichzeitige Netzwerk calls

    .Parameter Destination 
        [sr-en] Specifies the location to store the downloaded file
        [sr-de] Ort an dem die Dateien abgelegt werden

    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$StorageAccountName,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$Container,
    [Parameter(Mandatory = $true)]
    [string[]]$BlobNames,
    [Parameter(Mandatory = $true)]
    [string]$Destination,
    [switch]$CheckMd5,
    [int]$ConcurrentTaskCount = 10,
    [ValidateSet('*','Name','IsDeleted','Length','LastModified','SnapshotTime','BlobType')]
    [string[]]$Properties = @('Name','IsDeleted','Length','LastModified','BlobType')
)

Import-Module Az.Storage

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    $azAccount = $null
    GetAzureStorageAccount -AccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -StorageAccount ([ref]$azAccount)
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Context' = $azAccount.Context
                            'Container' = $Container
                            'ConcurrentTaskCount' = $ConcurrentTaskCount
                            'CheckMd5' = $CheckMd5
                            'Destination' = $Destination
                            'Blob' = $null
                            'Force' = $null
                            'Confirm' = $false
    }
    $ret = @()
    foreach($name in $BlobNames){
        $cmdArgs['Blob'] = $name
        $ret += Get-AzStorageBlobContent @cmdArgs | Select-Object $Properties
    }

    Write-Output $ret
}
catch{
    throw
}
finally{
}