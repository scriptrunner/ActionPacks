#Requires -Version 5.0
#Requires -Modules Az.Storage

<#
    .SYNOPSIS
        Generates a report with the storage containers
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module Az.Storage

    .LINK
        https://github.com/scriptrunner/ActionPacks/blob/master/Azure/_REPORTS_   

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
        Specifies the maximum number of objects that this cmdlet returns
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

    if($SRXEnv) {
        ConvertTo-ResultHtml -Result $ret
    }
    else{
        Write-Output $ret
    }
}
catch{
    throw
}
finally{
}