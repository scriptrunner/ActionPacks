#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Configures a new origin to public or private content delivery network (CDN)
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/SharePointOnline/Tenant

    .Parameter CdnType
        Specifies the CDN type

    .Parameter OriginUrl
        Specifies a path to the doc library to be configured, e.g. /sites/site/subfolder
#>

param(            
    [Parameter(Mandatory = $true)]
    [ValidateSet('Public','Private')]
    [string]$CdnType,
    [Parameter(Mandatory = $true)]
    [string]$OriginUrl
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'OriginUrl' = $OriginUrl
                            'CdnType' = $CdnType
                            'Confirm' = $false
                            }      

    $result = Add-SPOTenantCdnOrigin @cmdArgs | Select-Object *
      
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