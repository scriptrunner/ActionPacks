#Requires -Version 5.0

<#
    .SYNOPSIS
        Gets details of configured application groups
    
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
        [sr-en] Application group with the Uid
        [sr-de] Anwendungsgruppe mit dieser Uid

    .Parameter Name
        [sr-en] Application groups whose name matches the supplied pattern
        [sr-de] Anwendungsgruppe, deren Name mit dem angegebenen Name übereinstimmt
        Dieser Parameter unterstützt Wildcards am Anfang und/oder am Ende des Namens

    .Parameter AssociatedDesktopGroupUid
        [sr-en] Application groups which have been associated with the specified desktop group
        [sr-de] Anwendungsgruppen, die mit der angegebenen Desktop-Gruppe verbunden wurden

    .Parameter Enabled	
        [sr-en] Application groups which are currently enabled.
        [sr-de] Anwendungsgruppen die aktiviert sind

    .Parameter SessionSharingEnabled
        [sr-en] Application groups for which session sharing is enabled
        [sr-de] Anwendungsgruppen für die Session Sharing aktiviert ist 

    .Parameter ApplicationUid	
        [sr-en] Application groups to which the given application has been added
        [sr-de] Anwendungsgruppen, mit denen die Anwendung verbunden wurde

    .Parameter DesktopGroupUid	
        [sr-en] Application groups which have been added to the specified desktop group
        [sr-de] Anwendungsgruppen, die mit der Desktop-Gruppe verbunden wurden

    .Parameter MaxRecordCount	
        [sr-en] Maximum number of records to return	
        [sr-de] Maximale Anzahl der Ergebnisse

    .Parameter TenantId	
        [sr-en] Application groups associated with the specified tenant identity
        [sr-de] Anwendungsgruppen, des angegebenen Mandanten

    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param( 
    [string]$SiteServer,
    [string]$Uid,
    [string]$Name,
    [string]$AssociatedDesktopGroupUid,
    [bool]$Enabled,
    [bool]$SessionSharingEnabled,
    [string]$ApplicationUid,
    [string]$DesktopGroupUid,
    [int]$MaxRecordCount = 250,
    [string]$TenantId,
    [ValidateSet('*','Name','Description','Enabled','UserFilterEnabled','AssociatedDesktopGroupUids','AssociatedUserNames','SessionSharingEnabled','SingleAppPerSession','TotalApplications','TotalMachines','AssociatedDesktopGroupUUIDs','Uid','UUID','TenantId')]
    [string[]]$Properties = @('Name','Description','Enabled','UserFilterEnabled','TotalApplications','TotalMachines','AssociatedUserNames','SessionSharingEnabled','Uid')
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
    if($PSBoundParameters.ContainsKey('Enabled') -eq $true){
        $cmdArgs.Add('Enabled',$Enabled)
    }
    if($PSBoundParameters.ContainsKey('SessionSharingEnabled') -eq $true){
        $cmdArgs.Add('SessionSharingEnabled',$SessionSharingEnabled)
    }
    if($PSBoundParameters.ContainsKey('ApplicationUid') -eq $true){
        $cmdArgs.Add('ApplicationUid',$ApplicationUid)
    }
    if($PSBoundParameters.ContainsKey('DesktopGroupUid') -eq $true){
        $cmdArgs.Add('DesktopGroupUid',$DesktopGroupUid)
    }
    if($PSBoundParameters.ContainsKey('TenantId') -eq $true){
        $cmdArgs.Add('TenantId',$TenantId)
    }

    $ret = Get-BrokerApplicationGroup @cmdArgs | Select-Object $Properties | Sort-Object Name

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