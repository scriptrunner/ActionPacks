#Requires -Version 5.0

<#
    .SYNOPSIS
        Changes a desktop rule from the site's entitlement policy

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
        https://github.com/scriptrunner/ActionPacks/blob/master/Citrix/Policies
        
    .Parameter SiteServer
        [sr-en] Specifies the address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers

    .Parameter RuleName
        [sr-en] Name of the new rule
        [sr-de] Name der neuen Regel

    .Parameter DesktopGroupUid
        [sr-en] Uid of the desktop group to which the new rule applies
        [sr-de] Uid der Bereitstellungsgruppe

    .Parameter Description	
        [sr-en] Description of the new rule
        [sr-de] Regel Beschreibung

    .Parameter Enabled
        [sr-en] New rule is initially enabled
        [sr-de] Aktivieren der Regel

    .Parameter ColorDepth	
        [sr-en] Color depth of any desktop sessions launched by a user from this entitlement
        [sr-de] Farbtiefe aller Desktop-Sitzungen, die von einem Benutzer mit dieser Berechtigung gestartet werden 		

    .Parameter ExcludedUserFilterEnabled
        [sr-en] Excluded users filter is initially enabled
        [sr-de] Filter für ausgeschlossene Benutzer aktiveren

    .Parameter ExcludedUsers
        [sr-en] Users and groups who are explicitly denied access to the new rule's desktop group      
        [sr-de] Ausgeschlossene Benutzer

    .Parameter IncludedUserFilterEnabled
        [sr-en] Included users filter is initially enabled
        [sr-de] Filter für Benutzer aktiveren
        
    .Parameter IncludedUsers
        [sr-en] Users and groups who are granted access to the new rule's desktop group        
        [sr-de] Benutzer
        
    .Parameter IconUid
        [sr-en] ID of the icon used to display the desktop session entitlement to the user
        [sr-de] ID des Symbols, das verwendet wird, um dem Benutzer die Desktop-Sitzungsberechtigung anzuzeigen
        
    .Parameter LeasingBehavior
        [sr-en] Desired connection leasing behavior applied to sessions launched using this entitlement
        [sr-de] Verhalten beim Verbindungsleasing für Sitzungen, die mit dieser Berechtigung gestartet werden

    .Parameter MaxPerEntitlementInstances
        [sr-en] Maximum allowed concurrently running instances of the desktop associated with this entitlement in the site
        [sr-de] Maximal zulässige, gleichzeitig laufende Instanzen des Desktops, der mit dieser Berechtigung in der Site verbunden ist
        
    .Parameter PublishedName
        [sr-en] Name of the new desktop session entitlement as seen by the user
        [sr-de] Name der Regel für Benutzer

    .Parameter SecureIcaRequired
        [sr-en] New desktop rule requires the SecureICA protocol for desktop sessions launched using the entitlement
        [sr-de] Neue Desktop-Regel erfordert das SecureICA-Protokoll

    .Parameter SessionReconnection
        [sr-en] Defines reconnection (roaming) behavior for sessions launched using this rule
        [sr-de] Definiert das Wiederverbindungsverhalten (Roaming) für Sitzungen, die mit dieser Regel gestartet wurden

    .Parameter RestrictToTag
        [sr-en] Tag that may be used further to restrict which machines may be made accessible to a user by an entitlement policy rule
        [sr-de] Tag, das weiter verwendet werden kann, um einzuschränken, welche Rechner für einen Benutzer durch eine Berechtigungsregel zugänglich gemacht werden können
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$RuleName,
    [Parameter(Mandatory = $true)]
    [int]$DesktopGroupUid,
    [string]$SiteServer,
    [string]$Description,
    [bool]$Enabled,
    [bool]$SecureIcaRequired,
    [bool]$ExcludedUserFilterEnabled,
    [string[]]$ExcludedUsers,
    [bool]$IncludedUserFilterEnabled,
    [string[]]$IncludedUsers,
    [ValidateSet('FourBit','EightBit','SixteenBit','TwentyFourBit')]
    [string]$ColorDepth,
    [int]$IconUid,
    [ValidateSet('Allowed','Disallowed')]
    [string]$LeasingBehavior,
    [int]$MaxPerEntitlementInstances,
    [string]$PublishedName,
    [ValidateSet('Always','DisconnectedOnly','SameEndpointOnly')]
    [string]$SessionReconnection,
    [string]$RestrictToTag
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    [string[]]$Properties = @('Name','Description','DesktopGroupUid','Enabled','ExcludedUsers','IncludedUsers','PublishedName')
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    StartLogging -ServerAddress $SiteServer -LogText "Change Entitlement rule $($RuleName)" -LoggingID ([ref]$LogID)
                      
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'PassThru' = $null
                            'Name' = $RuleName
                            'LoggingID' =$LogID
                            }    
    
    if($PSBoundParameters.ContainsKey('Enabled') -eq $true){
        $cmdArgs.Add('Enabled',$Enabled)
    }
    if($PSBoundParameters.ContainsKey('SecureIcaRequired') -eq $true){
        $cmdArgs.Add('SecureIcaRequired',$SecureIcaRequired)
    }
    if($PSBoundParameters.ContainsKey('PublishedName') -eq $true){
        $cmdArgs.Add('PublishedName',$PublishedName)
    }
    if($PSBoundParameters.ContainsKey('Description') -eq $true){
        $cmdArgs.Add('Description',$Description)
    }
    if($PSBoundParameters.ContainsKey('ColorDepth') -eq $true){
        $cmdArgs.Add('ColorDepth',$ColorDepth)
    }
    if($PSBoundParameters.ContainsKey('LeasingBehavior') -eq $true){
        $cmdArgs.Add('LeasingBehavior',$LeasingBehavior)
    }
    if($IconUid -gt 0){
        $cmdArgs.Add('IconUid',$IconUid)
    }
    if($MaxPerEntitlementInstances -gt 0){
        $cmdArgs.Add('MaxPerEntitlementInstances',$MaxPerEntitlementInstances)
    }
    if($PSBoundParameters.ContainsKey('ExcludedUserFilterEnabled') -eq $true){
        $cmdArgs.Add('ExcludedUserFilterEnabled',$ExcludedUserFilterEnabled)
    }
    if($PSBoundParameters.ContainsKey('ExcludedUsers') -eq $true){
        $cmdArgs.Add('ExcludedUsers',$ExcludedUsers)
    }
    if($PSBoundParameters.ContainsKey('IncludedUserFilterEnabled') -eq $true){
        $cmdArgs.Add('IncludedUserFilterEnabled',$IncludedUserFilterEnabled)
    }
    if($PSBoundParameters.ContainsKey('IncludedUsers') -eq $true){
        $cmdArgs.Add('IncludedUsers',$IncludedUsers)
    }
    if($PSBoundParameters.ContainsKey('SessionReconnection') -eq $true){
        $cmdArgs.Add('SessionReconnection',$SessionReconnection)
    }
    if($PSBoundParameters.ContainsKey('RestrictToTag') -eq $true){
        $cmdArgs.Add('RestrictToTag',$RestrictToTag)
    }

    $ret = Set-BrokerEntitlementPolicyRule @cmdArgs | Select-Object $Properties
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