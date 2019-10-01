#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Starts the upgrade process on a site collection
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module Microsoft.Online.SharePoint.PowerShell
        ScriptRunner Version 4.2.x or higher

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/SharePointOnline/Sites

    .Parameter Identity
        Specifies the SharePoint Online site collection to upgrade

    .Parameter NoEmail
        Specifies that the system not send the requester and site collection administrators a notification e-mail message at the end of the upgrade process

    .Parameter QueueOnly
        Adds the site collection to the upgrade queue. The upgrade does not occur immediately

    .Parameter VersionUpgrade
        Specifies whether to perform a version-to-version upgrade on the site collection
#>

param(        
    [Parameter(Mandatory=$true)]
    [string]$Identity,
    [switch]$NoEmail,
    [switch]$QueueOnly,
    [switch]$VersionUpgrade
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Identity' = $Identity
                            'NoEmail' = $NoEmail
                            'QueueOnly' = $QueueOnly
                            'VersionUpgrade' = $VersionUpgrade
                            'Confirm' = $false
                            }      
       
    $result = Upgrade-SPOSite @cmdArgs | Select-Object *

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $result
    }
    else {
        Write-Output $result 
    }    
}
catch{
    throw
}
finally{
}