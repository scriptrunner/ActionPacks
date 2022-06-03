#Requires -Version 5.0

<#
    .SYNOPSIS
        Creates a XenDesktop broker site
    
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
        [sr-en] Name of the SQL Server for the databases
        [sr-de] Name des SQL-Servers für die Datenbanken
    
    .Parameter SiteDatabaseName
        [sr-en] Name of the site database 
        [sr-de] Name der Site Datenbank
    
    .Parameter MonitorDatabaseName
        [sr-en] Name of the monitor database
        [sr-de] Name der Monitor Datenbank
    
    .Parameter LoggingDatabaseName
        [sr-en] Name of the logging database
        [sr-de] Name der Logging Datenbank
    
    .Parameter SiteDatabaseServer
        [sr-en] Name of the SQL Server for the site database 
        [sr-de] Name des SQL-Servers für die Site Datenbank
    
    .Parameter MonitorDatabaseServer
        [sr-en] Name of the SQL Server for the monitor database
        [sr-de] Name des SQL-Servers für die Monitor Datenbank
    
    .Parameter LoggingDatabaseServer
        [sr-en] Name of the SQL Server for the logging database
        [sr-de] Name des SQL-Servers für die Logging Datenbank
    
    .Parameter DatabaseMirrorServer
        [sr-en] Name of the SQL Server for the database mirrors
        [sr-de] Name des SQL-Servers für die Spiegelung der Datenbanken
    
    .Parameter SiteDatabaseMirrorServer
        [sr-en] Name of the SQL Server for the site database mirror
        [sr-de] Name des SQL-Servers für die Spiegelung der Site Datenbank
    
    .Parameter LoggingDatabaseMirrorServer
        [sr-en] Name of the SQL Server for the logging database mirror
        [sr-de] Name des SQL-Servers für die Spiegelung der Logging Datenbank
    
    .Parameter MonitorDatabaseMirrorServer
        [sr-en] Name of the SQL Server for the monitor database mirror
        [sr-de] Name des SQL-Servers für die Spiegelung der Monitor Datenbank
    
    .Parameter DatabaseNamePrefix
        [sr-en] Name prefix was applied to the default database names during the original creation of the databases
        [sr-de] Prefix für die Standarddatenbanknamen
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = 'Default')]
    [Parameter(Mandatory = $true,ParameterSetName = 'SingleServer')]
    [Parameter(Mandatory = $true,ParameterSetName = 'MultiServers')]
    [string]$SiteName, 
    [Parameter(Mandatory = $true,ParameterSetName = 'Default')]
    [Parameter(Mandatory = $true,ParameterSetName = 'SingleServer')]
    [string]$DatabaseServer, 
    [Parameter(Mandatory = $true,ParameterSetName = 'SingleServer')]
    [Parameter(Mandatory = $true,ParameterSetName = 'MultiServers')]
    [string]$SiteDatabaseName, 
    [Parameter(Mandatory = $true,ParameterSetName = 'SingleServer')]
    [Parameter(Mandatory = $true,ParameterSetName = 'MultiServers')]
    [string]$MonitorDatabaseName, 
    [Parameter(Mandatory = $true,ParameterSetName = 'SingleServer')]
    [Parameter(Mandatory = $true,ParameterSetName = 'MultiServers')]
    [string]$LoggingDatabaseName, 
    [Parameter(Mandatory = $true,ParameterSetName = 'MultiServers')]
    [string]$SiteDatabaseServer, 
    [Parameter(Mandatory = $true,ParameterSetName = 'MultiServers')]
    [string]$MonitorDatabaseServer, 
    [Parameter(Mandatory = $true,ParameterSetName = 'MultiServers')]
    [string]$LoggingDatabaseServer, 
    [Parameter(ParameterSetName = 'Default')]
    [Parameter(ParameterSetName = 'SingleServer')]
    [Parameter(ParameterSetName = 'MultiServers')]
    [string]$SiteServer,
    [Parameter(ParameterSetName = 'Default')]
    [Parameter(ParameterSetName = 'SingleServer')]
    [string]$DatabaseMirrorServer, 
    [Parameter(ParameterSetName = 'MultiServers')]
    [string]$SiteDatabaseMirrorServer, 
    [Parameter(ParameterSetName = 'MultiServers')]
    [string]$MonitorDatabaseMirrorServer, 
    [Parameter(ParameterSetName = 'MultiServers')]
    [string]$LoggingDatabaseMirrorServer, 
    [Parameter(ParameterSetName = 'Default')]
    [string]$DatabaseNamePrefix
)                                                            

try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'SiteName' = $SiteName
                            }    
    if($PSCmdlet.ParameterSetName -eq 'Default'){
        $cmdArgs.Add('AllDefaultDatabases',$null)
        $cmdArgs.Add('DatabaseServer',$DatabaseServer)
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'SingleServer') {
        $cmdArgs.Add('SiteDatabaseName',$SiteDatabaseName)
        $cmdArgs.Add('LoggingDatabaseName',$LoggingDatabaseName)
        $cmdArgs.Add('MonitorDatabaseName',$MonitorDatabaseName)
        $cmdArgs.Add('DatabaseServer',$DatabaseServer)
    }    
    elseif ($PSCmdlet.ParameterSetName -eq 'MultiServers') {
        $cmdArgs.Add('SiteDatabaseName',$SiteDatabaseName)
        $cmdArgs.Add('LoggingDatabaseName',$LoggingDatabaseName)
        $cmdArgs.Add('MonitorDatabaseName',$MonitorDatabaseName)
        $cmdArgs.Add('SiteDatabaseServer',$SiteDatabaseServer)
        $cmdArgs.Add('LoggingDatabaseServer',$LoggingDatabaseServer)
        $cmdArgs.Add('MonitorDatabaseServer',$MonitorDatabaseServer)
        if($PSBoundParameters.ContainsKey('SiteDatabaseMirrorServer') -eq $true){
            $cmdArgs.Add('SiteDatabaseMirrorServer',$SiteDatabaseMirrorServer)
        }
        if($PSBoundParameters.ContainsKey('LoggingDatabaseMirrorServer') -eq $true){
            $cmdArgs.Add('LoggingDatabaseMirrorServer',$LoggingDatabaseMirrorServer)
        }
        if($PSBoundParameters.ContainsKey('MonitorDatabaseMirrorServer') -eq $true){
            $cmdArgs.Add('MonitorDatabaseMirrorServer',$MonitorDatabaseMirrorServer)
        }
    }
    if($PSBoundParameters.ContainsKey('DatabaseMirrorServer') -eq $true){
        $cmdArgs.Add('DatabaseMirrorServer',$DatabaseMirrorServer)
    }
    if($PSBoundParameters.ContainsKey('DatabaseNamePrefix') -eq $true){
        $cmdArgs.Add('DatabaseNamePrefix',$DatabaseNamePrefix)
    }

    $ret = New-XDSite @cmdArgs | Select-Object *
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