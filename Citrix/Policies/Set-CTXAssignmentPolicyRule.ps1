#Requires -Version 5.0

<#
    .SYNOPSIS
        Updates an assignment policy rule 
    
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

    .Parameter ColorDepth	
        [sr-en] Color depth of any desktop sessions to machines assigned by the new rule
        [sr-de] Farbtiefe aller Desktop-Sitzungen, die den durch die neue Regel zugewiesenen Rechnern zugeordnet sind

    .Parameter PublishedName
        [sr-en] Name of the new desktop session entitlement as seen by the user
        [sr-de] Name der Regel für Benutzer

    .Parameter Description	
        [sr-en] Description of the new rule
        [sr-de] Regel Beschreibung

    .Parameter Enabled
        [sr-en] New rule is initially enabled
        [sr-de] Aktivieren der Regel

    .Parameter ExcludedUserFilterEnabled
        [sr-en] Excluded users filter is initially enabled
        [sr-de] Filter für ausgeschlossene Benutzer aktiveren

    .Parameter ExcludedUsers
        [sr-en] Users and groups who are explicitly denied access to the new rule's desktop group      
        [sr-de] Ausgeschlossene Benutzer

    .Parameter IconUid
        [sr-en] ID of the icon used to display the desktop session entitlement to the user
        [sr-de] ID des Symbols, das verwendet wird, um dem Benutzer die Desktop-Sitzungsberechtigung anzuzeigen
        
    .Parameter IncludedUserFilterEnabled
        [sr-en] Included users filter is initially enabled
        [sr-de] Filter für Benutzer aktiveren
        
    .Parameter IncludedUsers
        [sr-en] Users and groups who are granted access to the new rule's desktop group        
        [sr-de] Benutzer

    .Parameter SecureIcaRequired
        [sr-en] New desktop rule requires the SecureICA protocol for desktop sessions launched using the entitlement
        [sr-de] Neue Desktop-Regel erfordert das SecureICA-Protokoll

    .Parameter MaxDesktops
        [sr-en] Number of machines from the rule's desktop group to which a user is entitled
        [sr-de] Anzahl der Rechner aus der Desktop-Gruppe der Regel, zu der ein Benutzer berechtigt ist
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$RuleName,
    [string]$SiteServer,
    [string]$Description,
    [string]$PublishedName,
    [bool]$Enabled,
    [bool]$ExcludedUserFilterEnabled,
    [string[]]$ExcludedUsers,
    [bool]$IncludedUserFilterEnabled,
    [string[]]$IncludedUsers,
    [bool]$SecureIcaRequired,
    [ValidateSet('FourBit','EightBit','SixteenBit','TwentyFourBit')]
    [string]$ColorDepth,
    [int]$IconUid,
    [int]$MaxDesktops
)                                                            

$LogID = $null
[bool]$success = $false
try{ 
    [string[]]$Properties = @('Name','PublishedName','Description','DesktopGroupUid','Enabled','ExcludedUsers','IncludedUsers')
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    StartLogging -ServerAddress $SiteServer -LogText "Change Assignment rule $($RuleName)" -LoggingID ([ref]$LogID)
                      
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'Name' = $RuleName
                            'LoggingID' =$LogID
                            'PassThru' = $null
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
    if($PSBoundParameters.ContainsKey('Enabled') -eq $true){
        $cmdArgs.Add('Enabled',$Enabled)
    }
    if($PSBoundParameters.ContainsKey('SecureIcaRequired') -eq $true){
        $cmdArgs.Add('SecureIcaRequired',$SecureIcaRequired)
    }
    if($IconUid -gt 0){
        $cmdArgs.Add('IconUid',$IconUid)
    }
    if($MaxDesktops -gt 0){
        $cmdArgs.Add('MaxDesktops',$MaxDesktops)
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

    $ret = Set-BrokerAssignmentPolicyRule @cmdArgs | Select-Object $Properties
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