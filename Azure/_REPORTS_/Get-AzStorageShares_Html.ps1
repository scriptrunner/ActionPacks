#Requires -Version 5.0
#Requires -Modules Az.Storage

<#
    .SYNOPSIS
        Generates a report with a list of file shares
    
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
        [sr-en] Specifies the name of the Storage account
        [sr-de] Name des Storage Accounts
        
    .Parameter ResourceGroupName
        [sr-en] Specifies the name of the resource group
        [sr-de] Name der resource group
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$StorageAccountName,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName
)

Import-Module Az.Storage

try{
    [string[]]$Properties = @('Name','LastModified','IsSnapshot','SnapshotTime','Quota')
    
    $azAccount = $null
    GetAzureStorageAccount -AccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -StorageAccount ([ref]$azAccount)
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Context' = $azAccount.Context
                            'ConcurrentTaskCount' = $ConcurrentTaskCount
    }
        
    $ret = Get-AzStorageShare @cmdArgs | Select-Object $Properties

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