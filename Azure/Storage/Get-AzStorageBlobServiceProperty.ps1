#Requires -Version 5.0
#Requires -Modules Az.Storage

<#
    .SYNOPSIS
        Gets service properties for Azure Storage Blob services
    
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
        [sr-en] Specifies the name of the Storage account
        [sr-de] Name des Storage Accounts
        
    .Parameter ResourceGroupName
        [sr-en] Specifies the name of the resource group
        [sr-de] Name der resource group

    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$StorageAccountName,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [ValidateSet('*','StorageAccountName','ResourceGroupName','DefaultServiceVersion','ChangeFeed','IsVersioningEnabled','DeleteRetentionPolicy.Enabled','DeleteRetentionPolicy.Days','RestorePolicy.Enabled','RestorePolicy.Days')]
    [string[]]$Properties = @('StorageAccountName','ResourceGroupName','DefaultServiceVersion','ChangeFeed','IsVersioningEnabled')
)

Import-Module Az.Storage

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'StorageAccountName' = $StorageAccountName
                            'ResourceGroupName' = $ResourceGroupName
    }

    $ret = Get-AzStorageBlobServiceProperty @cmdArgs | Select-Object $Properties

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