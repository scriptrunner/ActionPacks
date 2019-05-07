#Requires -Version 5.0
#Requires -Modules Az.Sql

<#
    .SYNOPSIS
        Gets elastic pools and their property values in an Azure SQL Database
    
    .DESCRIPTION  
        
    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
        © AppSphere AG

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
        Specifies the name of the server that contains the elastic pool

    .Parameter ResourceGroupName
        Specifies the name of the resource group that contains the elastic pool 
        
    .Parameter Properties
        List of properties to expand, comma separated e.g. ElasticPoolName,Location. Use * for all properties
#>

param( 
    [Parameter(Mandatory = $true)]
    [pscredential]$AzureCredential,    
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$ServerName,
    [string]$PoolName,
    [string]$Properties = "ElasticPoolName,ResourceGroupName,ServerName,ResourceID,Location,State,Edition,Dtu,DatabaseDtuMax,DatabaseDtuMin,StorageMB,CreationDate,Tags",
    [string]$Tenant
)

Import-Module Az

try{
  #  ConnectAzure -AzureCredential $AzureCredential -Tenant $Tenant
    
    if([System.String]::IsNullOrWhiteSpace($Properties)){
        $Properties = '*'
    }

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'ServerName' = $ServerName
                            'ResourceGroupName' = $ResourceGroupName}
    
    if([System.String]::IsNullOrWhiteSpace($PoolName) -eq $false){
        $cmdArgs.Add('ElasticPoolName',$PoolName)
    }

    $ret = Get-AzSqlElasticPool @cmdArgs | Select-Object $Properties.Split(',')

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
 #   DisconnectAzure -Tenant $Tenant
}