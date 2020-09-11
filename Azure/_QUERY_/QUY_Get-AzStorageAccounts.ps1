#Requires -Version 5.0
#Requires -Modules Az.Storage

<#
    .SYNOPSIS
        Gets the storage accounts
    
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
#>

param( 
)

Import-Module Az.Storage

$VerbosePreference = 'SilentlyContinue'

try{
    $result = Get-AzStorageAccount -ErrorAction Stop | Select-Object @('StorageAccountName')  | Sort-Object StorageAccountName

    foreach($itm in $result){
        if($SRXEnv) {
            $null = $SRXEnv.ResultList.Add($itm.StorageAccountName) # Value
            $null = $SRXEnv.ResultList2.Add($itm.StorageAccountName) # Display
        }
        else{
            Write-Output $itm.StorageAccountName
        }
    }
}
catch{
    throw
}
finally{
}