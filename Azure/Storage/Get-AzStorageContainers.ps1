#Requires -Version 5.0
#Requires -Modules Az.Storage

<#
    .SYNOPSIS
        Gets the storage containers
    
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

    .Parameter Name 
        [sr-en] Specifies the container name
        [sr-de] Name des Containers

    .Parameter Prefix 
        [sr-en] Specifies a prefix used in the name of the container or containers you want to get. 
        You can use this to find all containers that start with the same string, parameter Name is ignored
        [sr-de] Präfix für den Container-Namen. 
        Alle Container, die mit der gleichen Zeichenfolge beginnen, der Parameter Name wird ignoriert

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
    [string]$Name,
    [string]$Prefix,
    [int]$MaxCount = 25,
    [ValidateSet('*','Name','LastModified','PublicAccess')]
    [string[]]$Properties = @('Name','LastModified','PublicAccess')
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
                            'MaxCount' = $MaxCount
    }
    if([System.String]::IsNullOrWhiteSpace($Prefix) -eq $false){
        $cmdArgs.Add('Prefix',$Prefix)
    }
    elseif([System.String]::IsNullOrWhiteSpace($Name) -eq $false){
        $cmdArgs.Add('Name',$Name)
    }
    $ret = Get-AzStorageContainer @cmdArgs | Select-Object $Properties

    Write-Output $ret
}
catch{
    throw
}
finally{
}