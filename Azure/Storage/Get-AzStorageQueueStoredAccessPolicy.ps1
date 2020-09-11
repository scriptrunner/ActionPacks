#Requires -Version 5.0
#Requires -Modules Az.Storage

<#
    .SYNOPSIS
        Gets the stored access policy or policies for an Azure storage queue
    
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

    .Parameter Queue
        [sr-en] Specifies the name of the queue
        [sr-de] Name der Queue

    .Parameter Policy 
        [sr-en] Specifies a stored access policy
        [sr-de] Name der Policy
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$StorageAccountName,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [string]$Queue,
    [string]$Policy
)

Import-Module Az.Storage

try{
    $azAccount = $null
    GetAzureStorageAccount -AccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -StorageAccount ([ref]$azAccount)
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Context' = $azAccount.Context
                            'Queue' = $Queue
    }
    if([System.String]::IsNullOrWhiteSpace($Policy) -eq $false){
        $cmdArgs.Add('Policy',$Policy)
    }
    
    $ret = Get-AzStorageQueueStoredAccessPolicy @cmdArgs | Select-Object *

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