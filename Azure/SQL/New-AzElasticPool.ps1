#Requires -Version 5.0
#Requires -Modules Az.Sql

<#
    .SYNOPSIS
        Creates an elastic database pool for a SQL Database
    
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

    .Parameter Edition
        [sr-en] Specifies the edition of the Azure SQL Database used for the elastic pool 
        [sr-de] Edition der Azure SQL-Datenbank

    .Parameter LicenseType
        [sr-en] The license type for the Azure Sql database 
        [sr-de] Lizenz Type der Datenbank

    .Parameter StorageMB
        [sr-en] Specifies the storage limit, in megabytes, for the elastic pool 
        [sr-de] Speichergrenzwert in Megabyte

    .Parameter Dtu
        [sr-en] Specifies the total number of shared DTUs for the elastic pool 
        [sr-de] Gesamtzahl der freigegebenen DTUs

    .Parameter DatabaseDtuMax
        [sr-en] Specifies the maximum number of Database Throughput Units (DTUs) that any single database in the pool can consume 
        [sr-de] Maximale Anzahl von DTUs 

    .Parameter DatabaseDtuMin
        [sr-en] Specifies the minimum number of DTUs that the elastic pool guarantees to all the databases in the pool 
        [sr-de] Mindestanzahl von DTUs 

    .Parameter ZoneRedundant
        [sr-en] The zone redundancy to associate with the Azure Sql Elastic Pool 
        [sr-de] Zonenredundanz, die dem Azure Sql Elastic Pool zugeordnet werden soll
#>

param(   
    [Parameter(Mandatory = $true)]
    [string]$PoolName,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$ServerName,
    [ValidateSet('Basic','Standard','Premium','DataWarehouse','Free','Stretch','GeneralPurpose','BusinessCritical')]
    [string]$Edition ,
    [string]$LicenseType,
    [int]$StorageMB,  
    [int]$Dtu,
    [int]$DatabaseDtuMax,
    [int]$DatabaseDtuMin,
    [switch]$ZoneRedundant
)

Import-Module Az.Sql

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Confirm' = $false
                            'ServerName' = $ServerName
                            'ResourceGroupName' = $ResourceGroupName
                            'ElasticPoolName' = $PoolName
                            'ZoneRedundant' = $ZoneRedundant}
    
    if([System.String]::IsNullOrWhiteSpace($Edition) -eq $false){
        $cmdArgs.Add('Edition',$Edition)
    }
    if([System.String]::IsNullOrWhiteSpace($LicenseType) -eq $false){
        $cmdArgs.Add('LicenseType',$LicenseType)
    }
    if($StorageMB -gt 0){
        $cmdArgs.Add('StorageMB',$StorageMB)
    }    
    if($Dtu -gt 0){
        $cmdArgs.Add('Dtu',$Dtu)
    }    
    if($DatabaseDtuMax -gt 0){
        $cmdArgs.Add('DatabaseDtuMax',$DatabaseDtuMax)
    }    
    if($DatabaseDtuMin -gt 0){
        $cmdArgs.Add('DatabaseDtuMin',$DatabaseDtuMin)
    }

    $ret = New-AzSqlElasticPool @cmdArgs

    Write-Output $ret
}
catch{
    throw
}
finally{
}