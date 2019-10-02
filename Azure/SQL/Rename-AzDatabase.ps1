#Requires -Version 5.0
#Requires -Modules Az.Sql

<#
    .SYNOPSIS
        Renames a database or an elastic database
    
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
        Specifies the name of resource group to which the server is assigned
        
    .Parameter NewDBName
        The new name to rename the database to
#>

param( 
    [Parameter(Mandatory = $true)]
    [pscredential]$AzureCredential,
    [Parameter(Mandatory = $true)]    
    [string]$DBName,
    [Parameter(Mandatory = $true)]    
    [string]$NewDBName,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory = $true)]
    [string]$ServerName,
    [string]$Tenant
)

Import-Module Az

try{
    [string[]]$Properties = @("DatabaseName","ResourceGroupName","ServerName","Location","DatabaseId","Edition","CollationName","Status","CreationDate","Tags")

   # ConnectAzure -AzureCredential $AzureCredential -Tenant $Tenant
        
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'DatabaseName' = $DBName
                            'NewName' = $NewDBName
                            'ServerName' = $ServerName
                            'ResourceGroupName' = $ResourceGroupName}
    
    $ret = Set-AzSqlDatabase @cmdArgs | Select-Object $Properties

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