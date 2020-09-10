#Requires -Version 5.0
#Requires -Modules Az.Sql

<#
    .SYNOPSIS
        Renames a database or an elastic database
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module Az
        Requires Library script AzureAzLibrary.ps1

    .LINK
        https://github.com/scriptrunner/ActionPacks/blob/master/Azure/SQL

    .Parameter DBName
        [sr-en] Specifies the name of the database
        [sr-de] Name der Datenbank

    .Parameter ServerName
        [sr-en] Specifies the name of the server that hosts the database
        [sr-de] Name des Servers auf dem sich die Datenbank befindet

    .Parameter ResourceGroupName
        [sr-en] Specifies the name of resource group to which the server is assigned
        [sr-de] Name der resource group die die Datenbank enthält
        
    .Parameter NewDBName
        [sr-en] The new name to rename the database to
        [sr-de] Neuer Datenbankname
#>

param( 
    [Parameter(Mandatory = $true)]    
    [string]$DBName,
    [Parameter(Mandatory = $true)]    
    [string]$NewDBName,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$ServerName,
    [string]$Tenant
)

Import-Module Az

try{
    [string[]]$Properties = @('DatabaseName','ResourceGroupName','ServerName','Location','DatabaseId','Edition','CollationName','Status','CreationDate','Tags')

   # ConnectAzure -AzureCredential $AzureCredential -Tenant $Tenant
        
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'DatabaseName' = $DBName
                            'NewName' = $NewDBName
                            'ServerName' = $ServerName
                            'ResourceGroupName' = $ResourceGroupName}
    
    $ret = Set-AzSqlDatabase @cmdArgs | Select-Object $Properties

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
   # DisconnectAzure -Tenant $Tenant
}