#Requires -Version 5.0

<#
    .SYNOPSIS
        Gets broker desktop groups
    
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
        [sr-en] Desktop groups with the specified value of Uid
        [sr-de] Desktop-Gruppen mit dieser Uid

    .Parameter Name
        [sr-en] Desktop groups whose name matches the supplied pattern
        [sr-de] Desktop-Gruppen, deren Name mit dem angegebenen Name übereinstimmt
        Dieser Parameter unterstützt Wildcards am Anfang und/oder am Ende des Namens

    .Parameter PublishedName
        [sr-en] Desktop groups whose published name matches the supplied pattern
        [sr-de] Desktop-Gruppen, deren veröffentlichter Name mit dem angegebenen Name übereinstimmt
        Dieser Parameter unterstützt Wildcards am Anfang und/oder am Ende des Namens

    .Parameter ColorDepth	
        [sr-en] Desktop groups with the specified color depth
        [sr-de] Desktop-Gruppen mit der angegebenen Farbtiefe

    .Parameter DeliveryType	
        [sr-en] Desktop groups according to their delivery type
        [sr-de] Desktop-Gruppen mit dieser Bereitstellungsart

    .Parameter Enabled	
        [sr-en] Desktop groups with the specified value
        [sr-de] Desktop-Gruppen mit der angegebenen Wert 

    .Parameter InMaintenanceMode	
        [sr-en] Desktop groups with the specified value
        [sr-de] Desktop-Gruppen mit der angegebenen Wert 

    .Parameter TenantId	
        [sr-en] Desktop groups associated with the specified tenant identity
        [sr-de] Desktop-Gruppen, des angegebenen Mandanten

    .Parameter UUID	
        [sr-en] Desktop groups with the specified value of UUID 
        [sr-de] Desktop-Gruppen mit dieser UUID

    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param( 
    [string]$SiteServer,
    [string]$Uid,
    [string]$Name,
    [string]$PublishedName,
    [ValidateSet('FourBit','EightBit','SixteenBit','TwentyFourBit')]
    [string]$ColorDepth,
    [Validateset('DesktopsOnly','AppsOnly','DesktopsAndApps')]
    [string]$DeliveryType,
    [bool]$Enabled,
    [bool]$InMaintenanceMode,
    [string]$TenantId,
    [string]$UUID,
    [ValidateSet('*','Name','PublishedName','Description','Enabled','InMaintenanceMode','DeliveryType','ColorDepth','MinimumFunctionalLevel','MachineLogOnType','Uid','SessionSupport','TimeZone','UUID','ZonePreferences')]
    [string[]]$Properties = @('Name','PublishedName','Description','Enabled','DeliveryType','MinimumFunctionalLevel','MachineLogOnType','Uid')
)                                                            

try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'Property' = $Properties
                            }
    
    if([System.String]::IsNullOrWhiteSpace($Uid) -eq $false){
        $cmdArgs.Add('Uid',$Uid)
    }
    if([System.String]::IsNullOrWhiteSpace($UUID) -eq $false){
        $cmdArgs.Add('UUID',$UUID)
    }
    if($PSBoundParameters.ContainsKey('Name') -eq $true){
        $cmdArgs.Add('Name',$Name)
    }
    if($PSBoundParameters.ContainsKey('PublishedName') -eq $true){
        $cmdArgs.Add('PublishedName',$PublishedName)
    }
    if($PSBoundParameters.ContainsKey('ColorDepth') -eq $true){
        $cmdArgs.Add('ColorDepth',$ColorDepth)
    }
    if($PSBoundParameters.ContainsKey('Enabled') -eq $true){
        $cmdArgs.Add('Enabled',$Enabled)
    }
    if($PSBoundParameters.ContainsKey('InMaintenanceMode') -eq $true){
        $cmdArgs.Add('InMaintenanceMode',$InMaintenanceMode)
    }
    if($PSBoundParameters.ContainsKey('DeliveryType') -eq $true){
        $cmdArgs.Add('DeliveryType',$DeliveryType)
    }
    if($PSBoundParameters.ContainsKey('TenantId') -eq $true){
        $cmdArgs.Add('TenantId',$TenantId)
    }

    $ret = Get-BrokerDesktopGroup @cmdArgs | Select-Object $Properties | Sort-Object Name

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