#Requires -Version 5.0

<#
    .SYNOPSIS
        Creates a zone preference for a user/group account in this site
    
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

    .Parameter Name
        [sr-en] Name of the user/group account with which the new home zone preference is to be associated (domain\account)
        [sr-de] Name des Benutzers oder der Gruppe die der Zone zugewiesen werden soll (domain\account)

    .Parameter SID
        [sr-en] SID of the user/group account with which the new home zone preference is to be associated
        [sr-de] SID des Benutzers oder der Gruppe die der Zone zugewiesen werden soll

    .Parameter HomeZoneUid
        [sr-en] Home zone preference to be associated with the user/group account
        [sr-de] Uid der Zone, der der Benutzer oder die Gruppe zugewiesen werden soll
#>

param( 
    [Parameter(Mandatory = $true, ParameterSetName = 'ByName')]
    [string]$Name,
    [Parameter(Mandatory = $true, ParameterSetName = 'BySID')]
    [string]$SID,
    [Parameter(Mandatory = $true, ParameterSetName = 'ByName')]
    [Parameter(Mandatory = $true, ParameterSetName = 'BySID')]
    [string]$HomeZoneUid,
    [Parameter(ParameterSetName = 'ByName')]
    [Parameter(ParameterSetName = 'BySID')]
    [string]$SiteServer    
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    [string[]]$Properties = @('Name','FullName','HomeZoneName','SID')
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    StartLogging -ServerAddress $SiteServer -LogText "Add Account to Zone" -LoggingID ([ref]$LogID)
                      
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'HomeZoneUid' = $HomeZoneUid
                            'LoggingId' = $LogID
                            }    
    
    if($PSCmdlet.ParameterSetName -eq 'ByName'){
        $cmdArgs.Add('Name',$Name)
    }   
    else{
        $cmdArgs.Add('SID',$SID)
    }

    $null = New-BrokerUserZonePreference @cmdArgs 
    $ret = Get-BrokerUserZonePreference -HomeZoneUid $HomeZoneUid -AdminAddress $SiteServer -ErrorAction Stop | Select-Object $Properties
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