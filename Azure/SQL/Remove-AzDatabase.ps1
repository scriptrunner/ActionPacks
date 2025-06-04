#Requires -Version 5.0
#Requires -Modules Az.Sql

<#
    .SYNOPSIS
        Removes an Azure SQL database
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module Az.Sql

    .Parameter DBName
        [sr-en] Specifies the name of the database to remove
        [sr-de] Name der Datenbank

    .Parameter ServerName
        [sr-en] Specifies the name of the server that hosts the database
        [sr-de] Name des Servers auf dem sich die Datenbank befindet

    .Parameter ResourceGroupName
        [sr-en] Specifies the name of the resource group to which the database server is assigned
        [sr-de] Name der resource group die die Datenbank enthält

#>

param(   
    [Parameter(Mandatory = $true)]
    [string]$DBName,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$ServerName
)

Import-Module Az.Sql

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Force' = $null
                            'Confirm' = $false
                            'DatabaseName' = $DBName
                            'ServerName' = $ServerName
                            'ResourceGroupName' = $ResourceGroupName}
    
    $null = Remove-AzSqlDatabase @cmdArgs 
    $ret = "Database $($DBName) removed"

    Write-Output $ret
}
catch{
    throw
}
finally{
}