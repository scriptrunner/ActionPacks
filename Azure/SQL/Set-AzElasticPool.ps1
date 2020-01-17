#Requires -Version 5.0
#Requires -Modules Az.Sql

<#
    .SYNOPSIS
        Modifies properties of an elastic database pool in Azure SQL Database
    
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
        https://github.com/scriptrunner/ActionPacks/blob/master/Azure        

    .Parameter AzureCredential
        The PSCredential object provides the user ID and password for organizational ID credentials, or the application ID and secret for service principal credentials

    .Parameter Tenant
        Tenant name or ID

    .Parameter PoolName
        Specifies the name of the elastic pool

    .Parameter ServerName
        Specifies the name of the server that hosts the elastic pool

    .Parameter ResourceGroupName
        Specifies the name of the resource group to which assigns the elastic pool

    .Parameter Edition
        Specifies the edition of the Azure SQL Database used for the elastic pool

    .Parameter LicenseType
        The license type for the Azure Sql database

    .Parameter StorageMB
        Specifies the storage limit, in megabytes, for the elastic pool

    .Parameter Dtu
        Specifies the total number of shared DTUs for the elastic pool

    .Parameter DatabaseDtuMax
        Specifies the maximum number of Database Throughput Units (DTUs) that any single database in the pool can consume

    .Parameter DatabaseDtuMin
        Specifies the minimum number of DTUs that the elastic pool guarantees to all the databases in the pool

    .Parameter ZoneRedundant
        The zone redundancy to associate with the Azure Sql Elastic Pool
#>

param( 
    [Parameter(Mandatory = $true)]
    [pscredential]$AzureCredential,    
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
    [switch]$ZoneRedundant,
    [string]$Tenant
)

Import-Module Az

try{
    [string[]]$Properties = @'ElasticPoolName','ResourceGroupName','ServerName','State','Edition','Dtu','DatabaseDtuMax','DatabaseDtuMin','StorageMB','CreationDate','Tags')

 #   ConnectAzure -AzureCredential $AzureCredential -Tenant $Tenant
    
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

    $ret = Set-AzSqlElasticPool @cmdArgs | Select-Object $Properties

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