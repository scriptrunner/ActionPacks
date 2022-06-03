#Requires -Version 5.0

<#
    .SYNOPSIS
        Gets the SQL scripts used to create and manage the Database
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires the library script CitrixLibrary.ps1
        Requires PSSnapIn Citrix*

    .LINK
        https://github.com/scriptrunner/ActionPacks/blob/master/Citrix/Sites
        
    .Parameter SiteServer
        [sr-en] Specifies the address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers
    
    .Parameter SiteName
        [sr-en] Name of the site  
        [sr-de] Name der Site 
    
    .Parameter DatabaseServer
        [sr-en] Name of the SQL Server
        [sr-de] Name des SQL-Servers
    
    .Parameter DataStore
        [sr-en] Datastore type of the script to be generated
        [sr-de] Datastore-Typ der Scripte
    
    .Parameter ScriptType
        [sr-en] Type of SQL script to be generated
        [sr-de] Typ der SQL Scripte
    
    .Parameter ExportPath
        [sr-en] Path for the files 
        [sr-de] Pfad für die Dateien
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$SiteName, 
    [Parameter(Mandatory = $true)]
    [string]$DatabaseServer, 
    [Parameter(Mandatory = $true)]
    [string]$ExportPath,
    [ValidateSet('All','Site','Logging','Monitor')]
    [string]$DataStore = 'All', 
    [ValidateSet('AddController','FullDatabase','RemoveController','AddDatabaseLogOn')]
    [string]$ScriptType = 'FullDatabase',
    [string]$SiteServer
)                                                            

try{ 
    if($ExportPath.EndsWith('\') -eq $false){
        $ExportPath += '\'
    }
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'SiteName' = $SiteName
                            'DatabaseServer' = $DatabaseServer
                            'ScriptType' = $ScriptType
                            }    

    [string[]]$store = @()
    if($DataStore -eq 'All'){
        $store = @('Site','Logging','Monitor')
    }
    else{
        $store = @($DataStore)
    }
    foreach($itm in $store){
        $sqlCmd = Get-XDDatabaseSchema @cmdArgs -DataStore $itm
        Set-Content -Path "$($ExportPath)dbschema_$($itm).sql" -Value $sqlCmd -Force -Confirm:$false
    }

    $ret = 'Schemas exported'
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
    CloseCitrixSession
}