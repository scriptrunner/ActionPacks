#Requires -Version 5.0
#Requires -Modules Az.Sql

<#
    .SYNOPSIS
        Gets elastic pools and their property values in an Azure SQL Database
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module Az.Sql

    .Parameter PoolName
        [sr-en] Specifies the name of the elastic pool
        [sr-de] Name des elastic pools

    .Parameter ServerName
        [sr-en] Specifies the name of the server that contains the elastic pool
        [sr-de] Name des Servers auf dem sich der elastic pool befindet

    .Parameter ResourceGroupName
        [sr-en] Specifies the name of the resource group that contains the elastic pool 
        [sr-de] Name der resource group die den elastic pool enthält
        
    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param(    
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$ServerName,
    [string]$PoolName,
    [ValidateSet('*','ElasticPoolName','ResourceGroupName','ServerName','ResourceID','Location','State','Edition','Dtu','DatabaseDtuMax','DatabaseDtuMin','StorageMB','CreationDate','Tags')]
    [string[]]$Properties = @('ElasticPoolName','ResourceGroupName','ServerName','ResourceID','Location','State','Edition','Dtu','DatabaseDtuMax','DatabaseDtuMin','StorageMB','CreationDate','Tags')
)

Import-Module Az.Sql

try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'ServerName' = $ServerName
                            'ResourceGroupName' = $ResourceGroupName}
    
    if([System.String]::IsNullOrWhiteSpace($PoolName) -eq $false){
        $cmdArgs.Add('ElasticPoolName',$PoolName)
    }

    $ret = Get-AzSqlElasticPool @cmdArgs | Select-Object $Properties

    Write-Output $ret
}
catch{
    throw
}
finally{
}