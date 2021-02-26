#Requires -Version 5.0

<#
    .SYNOPSIS
        Creates or updates metadata for desktop group
    
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
        https://github.com/scriptrunner/ActionPacks/blob/master/Citrix/Applications
        
    .Parameter SiteServer
        [sr-en] Address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers

    .Parameter GroupName
        [sr-en] Name of the desktop group
        [sr-de] Name des Desktop-Gruppe

    .Parameter GroupUid
        [sr-en] Uid of the desktop group
        [sr-de] Uid des Desktop-Gruppe

    .Parameter PropertyName	
        [sr-en] Name of the metadata to be created/updated
        [sr-de] Name für die Eigenschaft die erstellt oder aktualisiert wird

    .Parameter PropertyValue	
        [sr-en] Value for the property
        [sr-de] Eigenschaftswert
#>

param( 
    [Parameter(Mandatory = $true,ParameterSetName = 'ByName')]
    [string]$GroupName,
    [Parameter(Mandatory = $true,ParameterSetName = 'ById')]
    [string]$GroupUid,
    [Parameter(Mandatory = $true,ParameterSetName = 'ByName')]
    [Parameter(Mandatory = $true,ParameterSetName = 'ById')]
    [string]$PropertyName,
    [Parameter(Mandatory = $true,ParameterSetName = 'ByName')]
    [Parameter(Mandatory = $true,ParameterSetName = 'ById')]
    [string]$PropertyValue,
    [string]$SiteServer
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                        }

    if($PSCmdlet.ParameterSetName -eq 'ByName'){
        $cmdArgs.Add('Name',$GroupName)
    }   
    else{
        $cmdArgs.Add('Uid',$GroupUid)
    }                     
    $group = Get-BrokerDesktopGroup @cmdArgs

    StartLogging -ServerAddress $SiteServer -LogText "Set desktop group metadata $($PropertyName)" -LoggingID ([ref]$LogID)
    $cmdArgs = @{'ErrorAction' = 'Stop'
                'AdminAddress' = $SiteServer
                'DesktopGroupId' = $group.Uid
                'PassThru' = $null
                'Name' = $PropertyName
                'Value' = $PropertyValue
                'LoggingId' = $LogID
                }
    
    $ret = Set-BrokerDesktopGroupMetadata @cmdArgs | Select-Object -ExpandProperty MetadataMap
    $success = $true
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
    StopLogging -LoggingID $LogID -ServerAddress $SiteServer -IsSuccessful $success
    CloseCitrixSession
}