#Requires -Version 5.0

<#
    .SYNOPSIS
        Creates an access policy rule 
    
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

    .Parameter ExcludedClientIPFilterEnabled	
        [sr-en] Excluded client IP address filter is initially enabled
        [sr-de] Filter für ausgeschlossene IP Adressen aktiveren

    .Parameter ExcludedClientIPs
        [sr-en] IP addresses of user devices explicitly denied access to the new rule's desktop group
        [sr-de] Ausgeschlossene IP Adressen
    
    .Parameter ExcludedClientNameFilterEnabled
        [sr-en] Excluded client names filter is initially enabled
        [sr-de] Filter für ausgeschlossene Client Namen aktiveren

    .Parameter ExcludedClientNames
        [sr-en] Names of user devices explicitly denied access to the new rule's desktop group      
        [sr-de] Ausgeschlossene Client Namen
    
    .Parameter ExcludedSmartAccessFilterEnabled
        [sr-en] Excluded SmartAccess tags filter is initially enabled
        [sr-de] Filter für ausgeschlossene Tags aktiveren
    
    .Parameter ExcludedSmartAccessTags
        [sr-en] SmartAccess tags which explicitly deny access to the new rule's desktop group if any occur in those provided by Access Gateway with the user's connection
        [sr-de] Ausgeschlossene Tags

    .Parameter ExcludedUserFilterEnabled
        [sr-en] Excluded users filter is initially enabled
        [sr-de] Filter für ausgeschlossene Benutzer aktiveren

    .Parameter ExcludedUsers
        [sr-en] Users and groups who are explicitly denied access to the new rule's desktop group      
        [sr-de] Ausgeschlossene Benutzer

    .Parameter HdxSslEnabled
        [sr-en] TLS encryption is enabled for sessions delivered from the rule's desktop group
        [sr-de] TLS-Verschlüsselung ist für Sitzungen aktiviert, die von der Desktop-Gruppe der Regel übertragen werden

    .Parameter IncludedClientIPFilterEnabled
        [sr-en] Included client IP address filter is initially enabled
        [sr-de] Filter für IP Adressen aktiveren

    .Parameter IncludedClientIPs
        [sr-en] IP addresses of user devices allowed access to the new rule's desktop group      
        [sr-de] IP Adressen

    .Parameter IncludedClientNameFilterEnabled
        [sr-en] Included client name filter is initially enabled
        [sr-de] Filter für Client Namen aktiveren

    .Parameter IncludedClientNames	
        [sr-en] Names of user devices allowed access to the new rule's desktop group      
        [sr-de] Client Namen

    .Parameter IncludedSmartAccessFilterEnabled
        [sr-en] Included SmartAccess tags filter is initially enabled
        [sr-de] Filter für Tags aktiveren

    .Parameter IncludedSmartAccessTags
        [sr-en] SmartAccess tags which grant access to the new rule's desktop group if any occur in those provided by Access Gateway with the user's connection      
        [sr-de] Tags

    .Parameter IncludedUserFilterEnabled
        [sr-en] Included users filter is initially enabled
        [sr-de] Filter für Benutzer aktiveren
        
    .Parameter IncludedUsers
        [sr-en] Users and groups who are granted access to the new rule's desktop group        
        [sr-de] Benutzer

    .Parameter AllowedConnections	
        [sr-en] Connections must be local or via Access Gateway, and if so whether specified SmartAccess tags must be provided by Access Gateway with the connection
        [sr-de] Verbindungen müssen lokal oder über Access Gateway erfolgen
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$RuleName,
    [Parameter(Mandatory = $true)]
    [int]$DesktopGroupUid,
    [string]$SiteServer,
    [ValidateSet('Filtered','NotViaAG','ViaAG','AnyViaAG')]
    [string]$AllowedConnections = 'Filtered',
    [ValidateSet('HDX','RDP')]
    [string[]]$AllowedProtocols = @('HDX'),
    [ValidateSet('Filtered','AnyAuthenticated','Any','AnonymousOnly','FilteredOrAnonymous')]
    [string]$AllowedUsers = 'Filtered',
    [bool]$AllowRestart = $true,
    [string]$Description,
    [bool]$Enabled = $true,
    [bool]$ExcludedClientIPFilterEnabled,
    [string[]]$ExcludedClientIPs,    
    [bool]$ExcludedClientNameFilterEnabled,
    [string[]]$ExcludedClientNames,
    [bool]$ExcludedSmartAccessFilterEnabled,
    [string[]]$ExcludedSmartAccessTags,
    [bool]$ExcludedUserFilterEnabled,
    [string[]]$ExcludedUsers,
    [bool]$HdxSslEnabled,
    [bool]$IncludedClientIPFilterEnabled,
    [string[]]$IncludedClientIPs,    
    [bool]$IncludedClientNameFilterEnabled,
    [string[]]$IncludedClientNames,
    [bool]$IncludedSmartAccessFilterEnabled,
    [string[]]$IncludedSmartAccessTags,
    [bool]$IncludedUserFilterEnabled,
    [string[]]$IncludedUsers
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    [string[]]$Properties = @('Name','Description','DesktopGroupUid','Enabled','AllowedUsers','ExcludedUsers','IncludedUsers')
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    StartLogging -ServerAddress $SiteServer -LogText "Create Access rule $($RuleName)" -LoggingID ([ref]$LogID)
                      
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'DesktopGroupUid' = $DesktopGroupUid
                            'Name' = $RuleName
                            'AllowedConnections' = $AllowedConnections
                            'AllowedProtocols' = $AllowedProtocols
                            'AllowRestart' = $AllowRestart
                            'Enabled' = $Enabled
                            'AllowedUsers' = $AllowedUsers
                            'LoggingID' =$LogID
                            }    
    
    if($PSBoundParameters.ContainsKey('Description') -eq $true){
        $cmdArgs.Add('Description',$Description)
    }
    if($PSBoundParameters.ContainsKey('ExcludedClientIPFilterEnabled') -eq $true){
        $cmdArgs.Add('ExcludedClientIPFilterEnabled',$ExcludedClientIPFilterEnabled)
    }
    if($PSBoundParameters.ContainsKey('ExcludedClientIPs') -eq $true){
        $cmdArgs.Add('ExcludedClientIPs',$ExcludedClientIPs)
    }
    if($PSBoundParameters.ContainsKey('ExcludedClientNameFilterEnabled') -eq $true){
        $cmdArgs.Add('ExcludedClientNameFilterEnabled',$ExcludedClientNameFilterEnabled)
    }
    if($PSBoundParameters.ContainsKey('ExcludedClientNames') -eq $true){
        $cmdArgs.Add('ExcludedClientNames',$ExcludedClientNames)
    }
    if($PSBoundParameters.ContainsKey('ExcludedSmartAccessFilterEnabled') -eq $true){
        $cmdArgs.Add('ExcludedSmartAccessFilterEnabled',$ExcludedSmartAccessFilterEnabled)
    }
    if($PSBoundParameters.ContainsKey('ExcludedSmartAccessTags') -eq $true){
        $cmdArgs.Add('ExcludedSmartAccessTags',$ExcludedSmartAccessTags)
    }
    if($PSBoundParameters.ContainsKey('ExcludedUserFilterEnabled') -eq $true){
        $cmdArgs.Add('ExcludedUserFilterEnabled',$ExcludedUserFilterEnabled)
    }
    if($PSBoundParameters.ContainsKey('ExcludedUsers') -eq $true){
        $cmdArgs.Add('ExcludedUsers',$ExcludedUsers)
    }
    if($PSBoundParameters.ContainsKey('IncludedClientIPFilterEnabled') -eq $true){
        $cmdArgs.Add('IncludedClientIPFilterEnabled',$IncludedClientIPFilterEnabled)
    }
    if($PSBoundParameters.ContainsKey('IncludedClientIPs') -eq $true){
        $cmdArgs.Add('IncludedClientIPs',$IncludedClientIPs)
    }
    if($PSBoundParameters.ContainsKey('IncludedClientNameFilterEnabled') -eq $true){
        $cmdArgs.Add('IncludedClientNameFilterEnabled',$IncludedClientNameFilterEnabled)
    }
    if($PSBoundParameters.ContainsKey('IncludedClientNames') -eq $true){
        $cmdArgs.Add('IncludedClientNames',$IncludedClientNames)
    }
    if($PSBoundParameters.ContainsKey('IncludedSmartAccessFilterEnabled') -eq $true){
        $cmdArgs.Add('IncludedSmartAccessFilterEnabled',$IncludedSmartAccessFilterEnabled)
    }
    if($PSBoundParameters.ContainsKey('IncludedSmartAccessTags') -eq $true){
        $cmdArgs.Add('IncludedSmartAccessTags',$IncludedSmartAccessTags)
    }
    if($PSBoundParameters.ContainsKey('IncludedUserFilterEnabled') -eq $true){
        $cmdArgs.Add('IncludedUserFilterEnabled',$IncludedUserFilterEnabled)
    }
    if($PSBoundParameters.ContainsKey('IncludedUsers') -eq $true){
        $cmdArgs.Add('IncludedUsers',$IncludedUsers)
    }
    if($PSBoundParameters.ContainsKey('HdxSslEnabled') -eq $true){
        $cmdArgs.Add('HdxSslEnabled',$HdxSslEnabled)
    }

    $ret = New-BrokerAccessPolicyRule @cmdArgs | Select-Object $Properties
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