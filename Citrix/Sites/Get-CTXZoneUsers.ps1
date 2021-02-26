#Requires -Version 5.0

<#
    .SYNOPSIS
        Gets user/group accounts with zone preferences configured for this site
    
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
        [sr-en] User/group accounts with a home zone preference and the specified SAM name (domain\user)
        [sr-de] Benutzer oder Gruppe der Zone (domain\account)

    .Parameter FullName
        [sr-en] User/group accounts with a home zone preference and the specified full name
        [sr-de] Vollständiger Name des Benutzers oder der Gruppe in der Zone

    .Parameter UPN
        [sr-en] User/group accounts with a home zone preference and the specified UPN (user@domain)
        [sr-de] Benutzer oder Gruppe der Zone (user@domain)

    .Parameter HomeZoneName
        [sr-en] User/group accounts having a home zone preference with the specified name
        [sr-de] Benutzer oder Gruppen der definierten Zone (Name)

    .Parameter HomeZoneUid
        [sr-en] User/group accounts having a home zone preference with the specified UID
        [sr-de] Benutzer oder Gruppen der definierten Zone (Uid)

    .Parameter MaxRecordCount	
        [sr-en] Maximum number of records to return	
        [sr-de] Maximale Anzahl der Ergebnisse

    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param( 
    [string]$SiteServer,
    [string]$Name,
    [string]$FullName,
    [string]$UPN,
    [string]$HomeZoneName,
    [string]$HomeZoneUid,
    [int]$MaxRecordCount = 250,
    [ValidateSet('*','Name','FullName','HomeZoneName','HomeZoneUid','IdentityClaims','PrimaryClaim','SID','UPN')]
    [string[]]$Properties = @('Name','FullName','HomeZoneName','SID')
)                                                            

try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    if($Properties -contains '*'){
        $Properties = @('*')
    }
                      
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'MaxRecordCount' = $MaxRecordCount
                            }    
    
    if($PSBoundParameters.ContainsKey('Name') -eq $true){
        $cmdArgs.Add('Name',$Name)
    }   
    if($PSBoundParameters.ContainsKey('FullName') -eq $true){
        $cmdArgs.Add('FullName',$FullName)
    }
    if($PSBoundParameters.ContainsKey('UPN') -eq $true){
        $cmdArgs.Add('UPN',$UPN)
    }
    if($PSBoundParameters.ContainsKey('IsPrimary') -eq $true){
        $cmdArgs.Add('IsPrimary',$IsPrimary)
    }
    if($PSBoundParameters.ContainsKey('HomeZoneName') -eq $true){
        $cmdArgs.Add('HomeZoneName',$HomeZoneName)
    }
    if($PSBoundParameters.ContainsKey('HomeZoneUid') -eq $true){
        $cmdArgs.Add('HomeZoneUid',$HomeZoneUid)
    }

    $ret = Get-BrokerUserZonePreference @cmdArgs | Select-Object $Properties
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