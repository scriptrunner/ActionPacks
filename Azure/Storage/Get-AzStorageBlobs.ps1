#Requires -Version 5.0
#Requires -Modules Az.Storage

<#
    .SYNOPSIS
        Lists blobs in a container
    
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

    .Parameter BlobName 
        [sr-en] Specifies a name or name pattern, which can be used for a wildcard search
        [sr-de] Name oder Pattern des Blobs 

    .Parameter IncludeDeleted 
        [sr-en] Include Deleted Blob, by default get blob won't include deleted blob
        [sr-de] Gelöschte Blobs anzeigen 

    .Parameter ConcurrentTaskCount 
        [sr-en] Specifies the maximum concurrent network calls
        [sr-de] Maximale gleichzeitige Netzwerk calls

    .Parameter Prefix 
        [sr-en] Specifies a prefix for the blob names that you want to get. 
        You can use this to find all containers that start with the same string, parameter BlobName is ignored
        [sr-de] Präfix für die Blob-Namen. 
        Alle Container, die mit der gleichen Zeichenfolge beginnen, der Parameter BlobName wird ignoriert

    .Parameter MaxCount 
        [sr-en] Specifies the maximum number of objects that this cmdlet returns
        [sr-de] Maximale Anzahl der Objekte

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
    [string]$BlobName,
    [switch]$IncludeDeleted,
    [int]$ConcurrentTaskCount = 10,
    [string]$Prefix,
    [int]$MaxCount = 25,
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
                            'IncludeDeleted' = $IncludeDeleted
                            'MaxCount' = $MaxCount
    }
    if([System.String]::IsNullOrWhiteSpace($Prefix) -eq $false){
        $cmdArgs.Add('Prefix',$Prefix)
    }
    elseif([System.String]::IsNullOrWhiteSpace($BlobName) -eq $false){
        $cmdArgs.Add('Blob',$BlobName)
    }
    $ret = Get-AzStorageBlob @cmdArgs | Select-Object $Properties

    Write-Output $ret
}
catch{
    throw
}
finally{
}