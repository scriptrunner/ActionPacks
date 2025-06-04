#Requires -Version 5.0
#Requires -Modules Az.Sql

<#
    .SYNOPSIS
        Gets the status of operations on an elastic pool
    
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

    .Parameter OperationId
        [sr-en] The ID of the operation to retrieve
        [sr-de] ID der Operation
#>

param(  
    [Parameter(Mandatory = $true)]
    [string]$PoolName,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$ServerName,
    [guid]$OperationId = [guid]::Empty
)

Import-Module Az.Sql

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Confirm' = $false
                            'ElasticPoolName' = $PoolName
                            'ServerName' = $ServerName
                            'ResourceGroupName' = $ResourceGroupName}
    
    if([guid]::Empty -ne $OperationId){
        $cmdArgs.Add('OperationId',$OperationId)
    }
    $ret = Get-AzSqlElasticPoolActivity @cmdArgs

    Write-Output $ret
}
catch{
    throw
}
finally{
}