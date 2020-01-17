#Requires -Version 5.0
#Requires -Modules Az.Sql

<#
    .SYNOPSIS
        Creates a database or an elastic database
    
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

    .Parameter DBName
        Specifies the name of the database

    .Parameter ServerName
        Specifies the name of the server that hosts the database

    .Parameter ResourceGroupName
        Specifies the name of the resource group to which assigns the database
        
    .Parameter CollationName
        Specifies the name of the SQL database collation

    .Parameter Edition
        Specifies the edition to assign to the database

    .Parameter ElasticPoolName
        Specifies the name of the elastic pool in which to put the database

    .Parameter LicenseType
        The license type for the Azure Sql database

    .Parameter MaxSizeBytes
        Specifies the maximum size of the database in bytes

    .Parameter ReadScale
        The read scale option to assign to the Azure SQL Database

    .Parameter RequestedServiceObjectiveName
        Specifies the name of the service objective to assign to the database

    .Parameter SampleName
        The name of the sample schema to apply when creating this database

    .Parameter ZoneRedundant
        The zone redundancy to associate with the Azure Sql Database
#>

param( 
    [Parameter(Mandatory = $true)]
    [pscredential]$AzureCredential,    
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
    [switch]$ZoneRedundant,
    [string]$Tenant
)

Import-Module Az

try{
    [string[]]$Properties = @('ResourceGroupName','ServerName','DatabaseName','Location','DatabaseId','Edition','CollationName','Status','CreationDate','Tags')
    
 #   ConnectAzure -AzureCredential $AzureCredential -Tenant $Tenant
    
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
  #  DisconnectAzure -Tenant $Tenant
}