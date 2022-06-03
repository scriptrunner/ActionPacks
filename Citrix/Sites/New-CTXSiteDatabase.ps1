#Requires -Version 5.0

<#
    .SYNOPSIS
        Creates the specified Database or all Databases
    
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
        [sr-en] Datastore type that is to be created
        [sr-de] Datastore-Typ der Datenbank 

    .Parameter DBCredentials
        [sr-en] Credentials, that will be used to connect to the SQL Server
        [sr-de] Benutzerkonto des SQL Servers 

    .Parameter DatabaseNamePrefix	
        [sr-en] Name prefix was applied to the database names during the original creation of the databases
        [sr-de] Prefix für die Datenbanknamen
#>

param( 
    [Parameter(Mandatory = $true,ParameterSetName = 'All')]
    [Parameter(Mandatory = $true,ParameterSetName = 'DataStore')]
    [string]$SiteName, 
    [Parameter(Mandatory = $true,ParameterSetName = 'All')]
    [Parameter(Mandatory = $true,ParameterSetName = 'DataStore')]
    [string]$DatabaseServer, 
    [Parameter(Mandatory = $true,ParameterSetName = 'DataStore')]
    [ValidateSet('Site','Logging','Monitor')]
    [string]$DataStore, 
    [Parameter(ParameterSetName = 'All')]
    [Parameter(ParameterSetName = 'DataStore')]
    [pscredential]$DBCredentials,
    [Parameter(ParameterSetName = 'All')]
    [Parameter(ParameterSetName = 'DataStore')]
    [string]$SiteServer,
    [Parameter(ParameterSetName = 'DataStore')]
    [string]$DatabaseName,
    [Parameter(ParameterSetName = 'All')]
    [string]$DatabaseNamePrefix
)                                                            

try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
                      
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'SiteName' = $SiteName
                            'DatabaseServer' = $DatabaseServer
                        }    
    
    if($PScmdlet.ParameterSetName -eq 'All'){
        $cmdArgs.Add('AllDefaultDatabases',$null)
        if($PSBoundParameters.ContainsKey('DatabaseNamePrefix') -eq $true){
            $cmdArgs.Add('DatabaseNamePrefix',$DatabaseNamePrefix)
        }
    }
    else{
        $cmdArgs.Add('DataStore',$DataStore)
        if($PSBoundParameters.ContainsKey('DatabaseName') -eq $true){
            $cmdArgs.Add('DatabaseName',$DatabaseName)
        }
    }
    if($PSBoundParameters.ContainsKey('DBCredentials') -eq $true){
        $cmdArgs.Add('DatabaseCredentials',$DBCredentials)
    }

    $ret = New-XDDatabase @cmdArgs # create DB
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