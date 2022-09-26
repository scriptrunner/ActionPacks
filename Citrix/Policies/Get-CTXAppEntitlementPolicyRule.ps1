#Requires -Version 5.0

<#
    .SYNOPSIS
        Gets application rules from the site's entitlement policy
    
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
        [sr-en] Name of the rule
        [sr-de] Name der Regel
        
    .Parameter Properties
        List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param( 
    [string]$RuleName,
    [string]$SiteServer,    
    [ValidateSet('*','Description','DesktopGroupUid','Enabled','ExcludedUserFilterEnabled','ExcludedUsers',
                    'IncludedUserFilterEnabled','IncludedUsers','Name','LeasingBehavior','SessionReconnection','Uid')] 
    [string[]]$Properties = @('Name','Description','DesktopGroupUid','Enabled','ExcludedUsers','IncludedUsers')
)    

try{ 
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)
                      
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            }    
    
    if($PSBoundParameters.ContainsKey('RuleName') -eq $true){
        $cmdArgs.Add('Name',$RuleName)
    }
                                                
    $ret = Get-BrokerAppEntitlementPolicyRule @cmdArgs | Select-Object $Properties
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