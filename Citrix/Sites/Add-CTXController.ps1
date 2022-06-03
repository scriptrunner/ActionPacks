#Requires -Version 5.0

<#
    .SYNOPSIS
        Adds a Delivery Controller to an existing Site
    
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
    
    .Parameter SiteControllerAddress
        [sr-en] Address of a Controller in the Site to which this Controller is to be joined 
        [sr-de] Adresse eines Controllers, mit dem dieser Controller verbunden werden soll
    
    .Parameter DBCredentials
        [sr-en] Credentials, that will be used to connect to the SQL Server
        [sr-de] Benutzerkonto des SQL Servers
    
    .Parameter SiteDatabaseCredentials
        [sr-en] Credentials, to connect to the SQL Server associated with the Configuration Site Database
        [sr-de] Benutzerkonto des SQL Servers der Site Datenbank
    
    .Parameter LoggingDatabaseCredentials
        [sr-en] Credentials, to connect to the SQL Server associated with the Configuration Logging Database
        [sr-de] Benutzerkonto des SQL Servers der Logging Datenbank
    
    .Parameter MonitorDatabaseCredentials
        [sr-en] Credentials, to connect to the SQL Server associated with the Configuration Monitor Database
        [sr-de] Benutzerkonto des SQL Servers der Monitor Datenbank

    .Parameter DoNotUpdateDatabaseServer
        [sr-en] Results in the permissions associated with the Controller not being automatically added to the Database
        [sr-de] Berechtigungen werden nicht automatisch zur Datenbank hinzugefügt 
#>

param(    
    [Parameter(Mandatory =$true, ParameterSetName = 'Default')]
    [Parameter(Mandatory =$true, ParameterSetName = 'WithCredentials')]
    [Parameter(Mandatory =$true, ParameterSetName = 'UniqueCredentials')]
    [string]$SiteControllerAddress,
    [Parameter(Mandatory =$true, ParameterSetName = 'WithCredentials')]
    [pscredential]$DBCredentials,    
    [Parameter(Mandatory =$true, ParameterSetName = 'UniqueCredentials')]
    [pscredential]$SiteDatabaseCredentials,    
    [Parameter(Mandatory =$true, ParameterSetName = 'UniqueCredentials')]
    [pscredential]$LoggingDatabaseCredentials,    
    [Parameter(Mandatory =$true, ParameterSetName = 'UniqueCredentials')]
    [pscredential]$MonitorDatabaseCredentials,    
    [Parameter(ParameterSetName = 'Default')]
    [Parameter(ParameterSetName = 'WithCredentials')]
    [Parameter(ParameterSetName = 'UniqueCredentials')]
    [string]$SiteServer,
    [Parameter(ParameterSetName = 'Default')]
    [switch]$DoNotUpdateDatabaseServer
)                                                            

try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'SiteControllerAddress' = $SiteControllerAddress
                            }    

    if($PSCmdlet.ParameterSetName -eq 'Default'){
        if($DoNotUpdateDatabaseServer.IsPresent -eq $true){
            $cmdArgs.Add('DoNotUpdateDatabaseServer',$DoNotUpdateDatabaseServer)
        }
    }
    elseif($PSCmdlet.ParameterSetName -eq 'WithCredentials'){
        $cmdArgs.Add('DatabaseCredentials',$DBCredentials)
    }
    elseif($PSCmdlet.ParameterSetName -eq 'UniqueCredentials'){
        $cmdArgs.Add('SiteDatabaseCredentials',$SiteDatabaseCredentials)
        $cmdArgs.Add('LoggingDatabaseCredentials',$LoggingDatabaseCredentials)
        $cmdArgs.Add('MonitorDatabaseCredentials',$MonitorDatabaseCredentials)
    }

    $null = Add-XDController @cmdArgs
    $ret = Get-BrokerController -AdminAddress $SiteServer
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