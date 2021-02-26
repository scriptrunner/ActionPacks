#Requires -Version 5.0

<#
    .SYNOPSIS
        Determine whether the proposed Catalog Name is available for use
    
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

    .Parameter Names
        [sr-en] Catalog Names to be tested, comma separated
        [sr-de] Namen von Msachinen-Katalogen die überprüft werden, Komma getrennt
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$Names,
    [string]$SiteServer
)                                                            

try{ 
    StartCitrixSessionAdv -ServerName ([ref]$SiteServer)

    [string[]]$arrNames = $Names.Split(',')
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'AdminAddress' = $SiteServer
                            'Name' = $arrNames
                            }

    $ret = Test-BrokerCatalogNameAvailable @cmdArgs | Select-Object *    
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