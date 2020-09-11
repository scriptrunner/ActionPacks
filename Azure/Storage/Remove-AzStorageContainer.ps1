#Requires -Version 5.0
#Requires -Modules Az.Storage

<#
    .SYNOPSIS
        Removes the specified storage container
    
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
        [sr-en] Specifies the name of the container to remove
        [sr-de] Name des zu löschenden Containers
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$StorageAccountName,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$Name
)

Import-Module Az.Storage

try{
    $azAccount = $null
    GetAzureStorageAccount -AccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -StorageAccount ([ref]$azAccount)
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Context' = $azAccount.Context
                            'Confirm' = $false
                            'Force' = $null
                            'Name' = $Name
    }
    $null = Remove-AzStorageContainer @cmdArgs

    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Storage container $($Name) removed"
    }
    else{
        Write-Output = "Storage container $($Name) removed"
    }
}
catch{
    throw
}
finally{
}