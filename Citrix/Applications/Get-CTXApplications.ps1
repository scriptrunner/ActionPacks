#Requires -Version 5.0

<#
    .SYNOPSIS
        Get the applications published on this site
    
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
        [sr-en] Specifies the address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers

    .Parameter Uid
        [sr-en] Application with the Uid
        [sr-de] Anwendung mit dieser Uid

    .Parameter Name
        [sr-en] Only the applications matching the specified name
        [sr-de] Anwendungen, deren Name mit dem angegebenen Name übereinstimmt
        Dieser Parameter unterstützt Wildcards am Anfang und/oder am Ende des Namens

    .Parameter UserSID
        [sr-en] Applications with their accessibility restricted to include the specified user
        [sr-de] Anwendungen, deren Zugriff auf den angegebenen Benutzer beschränkt ist

    .Parameter Enabled	
        [sr-en] Applications which are currently enabled
        [sr-de] Anwendungsgruppen die aktiviert sind

    .Parameter Visible	
        [sr-en] Applications that have the specified value for whether it is visible to the users
        [sr-de] Anwendungen die sichtbar sind

    .Parameter ApplicationType
        [sr-en] Applications that match the type specified
        [sr-de] Anwendungen diesen Typs

    .Parameter AssociatedDesktopGroupUid
        [sr-en] Application groups which have been associated with the specified desktop group
        [sr-de] Anwendungsgruppen, die mit der angegebenen Desktop-Gruppe verbunden wurden

    .Parameter AssociatedApplicationGroupUid
        [sr-en] Applications that are members of the application group
        [sr-de] Anwendungsgruppen, die mit der angegebenen Anwendungsgruppe verbunden wurden

    .Parameter CpuPriorityLevel
        [sr-en] Applications that have the specified value for the CPU priority level
        [sr-de] Anwendungen denen dieser Cpu-Typ zugewiesen ist 

    .Parameter UserFilterEnabled	
        [sr-en] Applications whose user filter is in the specified state
        [sr-de] Anwendungen mit aktivierten Benutzerfilter J/N

    .Parameter MaxRecordCount	
        [sr-en] Maximum number of records to return	
        [sr-de] Maximale Anzahl der Ergebnisse

    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param( 
    [string]$SiteServer,
    [string]$Uid,
    [string]$Name,
    [string]$UserSID,
    [ValidateSet('HostedOnDesktop','InstalledOnClient','PublishedContent')]
    [string]$ApplicationType,
    [string]$AssociatedDesktopGroupUid,
    [string]$AssociatedApplicationGroupUid,
    [bool]$Enabled,
    [bool]$Visible,
    [ValidateSet('Low','BelowNormal','Normal','AboveNormal','High')]
    [string]$CpuPriorityLevel,    
    [bool]$UserFilterEnabled,
    [int]$MaxRecordCount = 250,
    [ValidateSet('*','Name','PublishedName','Description','Enabled','Visible','Uid','AdminFolderName','AdminFolderUid','ApplicationName','ApplicationType','BrowserName',
                'CommandLineExecutable','CpuPriorityLevel','HomeZoneName','SecureCmdLineArgumentsEnabled','ShortcutAddedToDesktop','StartMenuFolder','UserFilterEnabled','WaitForPrinterCreation','WorkingDirectory')]
    [string[]]$Properties = @('Name','PublishedName','Description','Enabled','Visible','Uid')
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
    
    if([System.String]::IsNullOrWhiteSpace($Uid) -eq $false){
        $cmdArgs.Add('Uid',$Uid)
    }
    if($PSBoundParameters.ContainsKey('Name') -eq $true){
        $cmdArgs.Add('Name',$Name)
    }
    
    if($PSBoundParameters.ContainsKey('AssociatedDesktopGroupUid') -eq $true){
        $cmdArgs.Add('AssociatedDesktopGroupUid',$AssociatedDesktopGroupUid)
    }
    if($PSBoundParameters.ContainsKey('AssociatedApplicationGroupUid') -eq $true){
        $cmdArgs.Add('AssociatedApplicationGroupUid',$AssociatedApplicationGroupUid)
    }
    if($PSBoundParameters.ContainsKey('Enabled') -eq $true){
        $cmdArgs.Add('Enabled',$Enabled)
    }
    if($PSBoundParameters.ContainsKey('Visible') -eq $true){
        $cmdArgs.Add('Visible',$Visible)
    }
    if($PSBoundParameters.ContainsKey('ApplicationType') -eq $true){
        $cmdArgs.Add('ApplicationType',$ApplicationType)
    }
    if($PSBoundParameters.ContainsKey('CpuPriorityLevel') -eq $true){
        $cmdArgs.Add('CpuPriorityLevel',$CpuPriorityLevel)
    }
    if($PSBoundParameters.ContainsKey('UserSID') -eq $true){
        $cmdArgs.Add('UserSID',$UserSID)
    }
    if($PSBoundParameters.ContainsKey('UserFilterEnabled') -eq $true){
        $cmdArgs.Add('UserFilterEnabled',$UserFilterEnabled)
    }

    $ret = Get-BrokerApplication @cmdArgs | Select-Object $Properties | Sort-Object Name

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