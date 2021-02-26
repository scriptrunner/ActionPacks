#Requires -Version 5.0

<#
    .SYNOPSIS
        Gets administrators configured for this site
    
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
        https://github.com/scriptrunner/ActionPacks/blob/master/Citrix/Administration
        
    .Parameter SiteServer
        [sr-en] Specifies the address of a XenDesktop controller. 
        This can be provided as a host name or an IP address
        [sr-de] Name oder IP Adresse des XenDesktop Controllers

    .Parameter Name
        [sr-en] Administrators with the specified name
        [sr-de] Name der Administratoren
        Dieser Parameter unterstützt Wildcards am Anfang und/oder am Ende des Namens

    .Parameter SID
        [sr-en] SID of the administrator
        [sr-de] SID des Administrators

    .Parameter Enabled
        [sr-en] Administrators active or not
        [sr-de] Aktivierte Administratoren J/N

    .Parameter UserIdentityType  
        [sr-en] Administrators with the specified UserIdentityType
        [sr-de] Administratoren dieses UserIdentityType

    .Parameter MaxRecordCount	
        [sr-en] Maximum number of records to return	
        [sr-de] Maximale Anzahl der Ergebnisse
        
    .Parameter Properties
        List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param(    
    [string]$SiteServer,
    [string]$Name,    
    [string]$SID,
    [bool]$Enabled,
    [ValidateSet('SID,''CitrixCloudIdentity','CitrixMultiTenantServiceIdentity')]
    [string]$UserIdentityType,
    [int]$MaxRecordCount = 250,
    [ValidateSet('*','Name','Enabled','SID','Rights','BuiltIn','UserIdentityType','UserIdentity')]
    [string[]]$Properties = @('Name','Enabled','SID','Rights','UserIdentityType')
)                                                            

try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'MaxRecordCount' = $MaxRecordCount
                            }    
    
    if($PSBoundParameters.ContainsKey('Name') -eq $true){
        $cmdArgs.Add('Name',$Name)
    }
    if($PSBoundParameters.ContainsKey('SID') -eq $true){
        $cmdArgs.Add('SID',$SID)
    }
    if($PSBoundParameters.ContainsKey('Enabled') -eq $true){
        $cmdArgs.Add('Enabled',$Enabled)
    }
    if($PSBoundParameters.ContainsKey('UserIdentityType') -eq $true){
        $cmdArgs.Add('UserIdentityType',$UserIdentityType)
    }
    
    $ret = Get-AdminAdministrator @cmdArgs | Select-Object $Properties
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