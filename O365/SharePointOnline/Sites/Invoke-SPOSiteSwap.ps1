#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Invokes a job to swap the location of a site with another site while archiving the original site
    
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

    .Parameter ArchiveUrl
        URL that the target site will be archived to

    .Parameter SourceUrl
        URL of the source site

    .Parameter TargetUrl
        URL of the target site that the source site will be swapped to
#>

param(        
    [Parameter(Mandatory = $true)]
    [string]$ArchiveUrl,
    [Parameter(Mandatory = $true)]
    [string]$SourceUrl,
    [Parameter(Mandatory = $true)]
    [string]$TargetUrl
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'ArchiveUrl' = $ArchiveUrl
                            'SourceUrl' = $SourceUrl
                            'TargetUrl' = $TargetUrl
                            }      
    
    $result = Invoke-SPOSiteSwap @cmdArgs | Select-Object *

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