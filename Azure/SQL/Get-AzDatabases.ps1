#Requires -Version 5.0
#Requires -Modules Az.Sql

<#
    .SYNOPSIS
        Gets one or more databases
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module Az.Sql

    .Parameter DBName
        [sr-en] Specifies the name of the database to retrieve
        [sr-de] Name der Datenbank

    .Parameter ServerName
        [sr-en] Specifies the name of the server to which the database is assigned
        [sr-de] Name des Servers auf dem sich die Datenbank befindet

    .Parameter ResourceGroupName
        [sr-en] Specifies the name of the resource group to which the database server is assigned 
        [sr-de] Name der resource group die die Datenbank enthält
        
    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param(   
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$ServerName,
    [string]$DBName,
    [ValidateSet('*','ResourceGroupName','ServerName','DatabaseName','Location','DatabaseId','Edition','CollationName','Status','CreationDate','Tags')]
    [string[]]$Properties = @('ResourceGroupName','ServerName','DatabaseName','Location','DatabaseId','Edition','CollationName','Status','CreationDate','Tags')
)

Import-Module Az.Sql

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'ServerName' = $ServerName
                            'ResourceGroupName' = $ResourceGroupName}
    
    if([System.String]::IsNullOrWhiteSpace($DBName) -eq $false){
        $cmdArgs.Add('DatabaseName',$DBName)
    }

    $ret = Get-AzSqlDatabase @cmdArgs | Select-Object $Properties

    Write-Output $ret
}
catch{
    throw
}
finally{
}