#Requires -Version 5.0
#Requires -Modules Az.Sql

<#
    .SYNOPSIS
        Renames a database or an elastic database
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module Az.Sql

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
    [string]$ServerName
)

Import-Module Az.Sql

try{
    [string[]]$Properties = @('DatabaseName','ResourceGroupName','ServerName','Location','DatabaseId','Edition','CollationName','Status','CreationDate','Tags')

   # ConnectAzure -AzureCredential $AzureCredential -Tenant $Tenant
        
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'DatabaseName' = $DBName
                            'NewName' = $NewDBName
                            'ServerName' = $ServerName
                            'ResourceGroupName' = $ResourceGroupName}
    
    $ret = Set-AzSqlDatabase @cmdArgs | Select-Object $Properties

    Write-Output $ret
}
catch{
    throw
}
finally{
   # DisconnectAzure -Tenant $Tenant
}