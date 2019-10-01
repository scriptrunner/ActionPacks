#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Retrieves and displays a list of all site script actions executed for a specified site design applied to a site
    
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

    .Parameter SiteDesignId
        The ID of a specific site design

    .Parameter WebUrl
        The Url of the site collection
#>

param(   
    [Parameter(Mandatory = $true)] 
    [string]$WebUrl,
    [string]$SiteDesignId
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'WebUrl' = $WebUrl
                            }
    
    if($PSBoundParameters.ContainsKey('SiteDesignId')){
        $cmdArgs.Add('SiteDesignId' , $SiteDesignId)
    }                            
    $myrun  = Get-SPOSiteDesignRun @cmdArgs
    $result = Get-SPOSiteDesignRunStatus -Run $myrun -ErrorAction Stop | Select-Object *
      
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