#Requires -Version 5.0
#Requires -Modules Az.Sql

<#
    .SYNOPSIS
        Deletes an elastic database pool
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module Az.Sql

    .Parameter PoolName
        [sr-en] Specifies the name of the elastic pool to remove
        [sr-de] Name des elastic pools

    .Parameter ServerName
        [sr-en] Specifies the name of the server that hosts the elastic pool
        [sr-de] Name des Servers auf dem sich der elastic pool befindet

    .Parameter ResourceGroupName
        [sr-en] Specifies the name of the resource group to which the elastic pool is assigned
        [sr-de] Name der resource group die den elastic pool enthält

#>

param(  
    [Parameter(Mandatory = $true)]
    [string]$PoolName,
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
                            'ElasticPoolName' = $PoolName
                            'ServerName' = $ServerName
                            'ResourceGroupName' = $ResourceGroupName}
    
    $null = Remove-AzSqlElasticPool @cmdArgs 
    $ret = "Elastic pool $($PoolName) removed"

    Write-Output $ret
}
catch{
    throw
}
finally{
}