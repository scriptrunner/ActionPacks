#Requires -Version 5.0
#Requires -Modules Az.Storage

<#
    .SYNOPSIS
        Gets the storage containers
    
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
        https://github.com/scriptrunner/ActionPacks/blob/master/Azure/_QUERY_   

    .Parameter StorageAccountName 
        [sr-en] Specifies the name of the Storage account to get containers
        [sr-de] Name des Storage Accounts
        
    .Parameter ResourceGroupName
        [sr-en] Specifies the name of the resource group that contains the Storage containers to get
        [sr-de] Name der resource group die die Storage Container enthält
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$StorageAccountName,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName
)

Import-Module Az.Storage

try{
    $azAccount = $null
    GetAzureStorageAccount -AccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -StorageAccount ([ref]$azAccount)
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Context' = $azAccount.Context
    }
    $result = Get-AzStorageContainer @cmdArgs | Select-Object 'Name'

    foreach($itm in $result){
        if($SRXEnv) {
            $null = $SRXEnv.ResultList.Add($itm.Name) # Value
            $null = $SRXEnv.ResultList2.Add($itm.Name) # Display
        }
        else{
            Write-Output $itm.Name
        }
    }
}
catch{
    throw
}
finally{
}