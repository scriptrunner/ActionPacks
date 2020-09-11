#Requires -Version 5.0
#Requires -Modules Az.Storage

<#
    .SYNOPSIS
        Creates an Azure storage container
    
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
        https://github.com/scriptrunner/ActionPacks/blob/master/Azure/Storage  

    .Parameter StorageAccountName 
        [sr-en] Specifies the name of the Storage account to get containers
        [sr-de] Name des Storage Accounts
        
    .Parameter ResourceGroupName
        [sr-en] Specifies the name of the resource group that contains the Storage containers to get
        [sr-de] Name der resource group die die Storage Container enthält

    .Parameter Name 
        [sr-en] Specifies a name for the new container
        [sr-de] Name des neuen Containers

    .Parameter Permission 
        [sr-en] Specifies the level of public access to this container
        [sr-de] Grad des öffentlichen Zugangs zu diesem Container

    .Parameter ConcurrentTaskCount 
        [sr-en] Specifies the maximum concurrent network calls
        [sr-de] Maximale gleichzeitige Netzwerk calls
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$StorageAccountName,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [ValidateSet('Off','Container','Blob')]
    [string]$Permission = 'Off',
    [int]$ConcurrentTaskCount = 10
)

Import-Module Az.Storage

try{
    [string[]]$Properties = @('Name','LastModified','PublicAccess')

    $azAccount = $null
    GetAzureStorageAccount -AccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -StorageAccount ([ref]$azAccount)
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Context' = $azAccount.Context
                            'Name' = $Name
                            'Permission' = $Permission
                            'ConcurrentTaskCount' = $ConcurrentTaskCount
    }
    
    $ret = New-AzStorageContainer @cmdArgs | Select-Object $Properties

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $ret 
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