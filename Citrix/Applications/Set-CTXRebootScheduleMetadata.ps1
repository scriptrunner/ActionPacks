#Requires -Version 5.0

<#
    .SYNOPSIS
        Creates or updates metadata for Reboot Schedule
    
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
        [sr-de] Name des Desktop-Gruppe

    .Parameter RebootScheduleUid
        [sr-en] Uid of the Reboot Schedule
        [sr-de] Uid des Neustartzeitplans

    .Parameter PropertyName	
        [sr-en] Name of the metadata to be created/updated
        [sr-de] Name für die Eigenschaft die erstellt oder aktualisiert wird

    .Parameter PropertyValue	
        [sr-en] Value for the property
        [sr-de] Eigenschaftswert
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$RebootScheduleUid,
    [Parameter(Mandatory = $true)]
    [string]$PropertyName,
    [Parameter(Mandatory = $true)]
    [string]$PropertyValue,
    [string]$SiteServer
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)

    StartLogging -ServerAddress $SiteServer -LogText "Set reboot schedule metadata $($PropertyName)" -LoggingID ([ref]$LogID)
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                'AdminAddress' = $SiteServer
                'RebootScheduleV2Id' = $RebootScheduleUid
                'PassThru' = $null
                'Name' = $PropertyName
                'Value' = $PropertyValue
                'LoggingId' = $LogID
                }
    
    $ret = Set-BrokerRebootScheduleV2Metadata @cmdArgs | Select-Object -ExpandProperty MetadataMap
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