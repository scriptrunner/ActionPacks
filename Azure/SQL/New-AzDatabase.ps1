#Requires -Version 5.0
#Requires -Modules Az.Sql

<#
    .SYNOPSIS
        Creates a database or an elastic database
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

    .COMPONENT
        Requires Module Az.Sql

    .Parameter ServerName
        [sr-en] Specifies the name of the server to which the database is assigned
        [sr-de] Name des Servers auf dem sich die Datenbank befindet

    .Parameter ResourceGroupName
        [sr-en] Specifies the name of the resource group to which the database server is assigned 
        [sr-de] Name der resource group die die Datenbank enthält
        
    .Parameter CollationName
        [sr-en] Specifies the name of the SQL database collation
        [sr-de] Name der SQL-Datenbanksortierung

    .Parameter Edition
        [sr-en] Specifies the edition for the database
        [sr-de] Edition der Datenbank

    .Parameter ElasticPoolName
        [sr-en] Specifies name of the elastic pool in which to move the database
        [sr-de] Namen des Pools für elastische Datenbanken

    .Parameter LicenseType
        [sr-en] The license type for the Azure Sql database
        [sr-de] Lizenztyp für die Azure Sql-Datenbank

    .Parameter MaxSizeBytes
        [sr-en] The maximum size of the Azure SQL Database in bytes
        [sr-de] Maximale Größe der Azure SQL-Datenbank in Bytes

    .Parameter ReadScale
        [sr-en] The read scale option to assign to the Azure SQL Database
        [sr-de] Verbindungen, deren Anwendungsabsicht in ihrer Verbindungszeichenfolge schreibgeschützt ist, an ein schreibgeschütztes sekundäres Replikat weiterleiten

    .Parameter RequestedServiceObjectiveName
        [sr-en] Specifies the name of the service objective to assign to the database
        [sr-de] Namen des Dienstobjekts, dem der Datenbank zugewiesen werden soll

    .Parameter SampleName
        [sr-en] The name of the sample schema to apply when creating this database
        [sr-de] Name des Beispielschemas, das beim Erstellen dieser Datenbank angewendet werden soll

    .Parameter ZoneRedundant
        [sr-en] The zone redundancy to associate with the Azure Sql Database
        [sr-de] Zonenredundanz, die der Azure Sql-Datenbank zugeordnet werden soll
#>

param(     
    [Parameter(Mandatory = $true)]
    [string]$DBName,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$ServerName,
    [string]$CollationName,
    [ValidateSet('Basic','Standard','Premium','DataWarehouse','Free','Stretch','GeneralPurpose','BusinessCritical')]
    [string]$Edition ,
    [string]$ElasticPoolName,
    [ValidateSet('BasePrice','LicenseIncluded')]
    [string]$LicenseType,
    [int64]$MaxSizeBytes,
    [ValidateSet('Enabled','Disabled')]
    [string]$ReadScale,
    [string]$RequestedServiceObjectiveName,
    [string]$SampleName,
    [switch]$ZoneRedundant
)

Import-Module Az.Sql

try{
    [string[]]$Properties = @('ResourceGroupName','ServerName','DatabaseName','Location','DatabaseId','Edition','CollationName','Status','CreationDate','Tags')
    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Confirm' = $false
                            'ServerName' = $ServerName
                            'ResourceGroupName' = $ResourceGroupName
                            'DatabaseName' = $DBName
                            'ZoneRedundant' = $ZoneRedundant}
    
    if([System.String]::IsNullOrWhiteSpace($CollationName) -eq $false){
        $cmdArgs.Add('CollationName',$CollationName)
    }
    if([System.String]::IsNullOrWhiteSpace($Edition) -eq $false){
        $cmdArgs.Add('Edition',$Edition)
    }
    if([System.String]::IsNullOrWhiteSpace($ElasticPoolName) -eq $false){
        $cmdArgs.Add('ElasticPoolName',$ElasticPoolName)
    }
    if([System.String]::IsNullOrWhiteSpace($LicenseType) -eq $false){
        $cmdArgs.Add('LicenseType',$LicenseType)
    }
    if([System.String]::IsNullOrWhiteSpace($ReadScale) -eq $false){
        $cmdArgs.Add('ReadScale',$ReadScale)
    }
    if([System.String]::IsNullOrWhiteSpace($RequestedServiceObjectiveName) -eq $false){
        $cmdArgs.Add('RequestedServiceObjectiveName',$RequestedServiceObjectiveName)
    }
    if([System.String]::IsNullOrWhiteSpace($SampleName) -eq $false){
        $cmdArgs.Add('SampleName',$SampleName)
    }
    if($MaxSizeBytes -gt 0){
        $cmdArgs.Add('MaxSizeBytes',$MaxSizeBytes)
    }

    $ret = New-AzSqlDatabase @cmdArgs | Select-Object $Properties

    Write-Output $ret
}
catch{
    throw
}
finally{
}