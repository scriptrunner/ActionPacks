#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
       Designates a library to be used as a central location for organization assets across the tenant
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/SharePointOnline/Common

    .Parameter CdnType
        Specifies the CDN type

    .Parameter LibraryUrl
        Indicates the absolute URL of the library to be designated as a central location for organization assets

    .Parameter OrgAssetType
        Indicates the type of content in this library

    .Parameter ThumbnailUrl
        Indicates the URL of the background image used when the library is publicly displayed
#>

param(        
    [Parameter(Mandatory=$true)]
    [ValidateSet('Public', 'Private')]
    [string]$LibraryUrl,
    [string]$CdnType, 
    [ValidateSet('ImageDocumentLibrary')]
    [string]$OrgAssetType,
    [string]$ThumbnailUrl
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Confirm' = $false
                            'LibraryUrl' = $LibraryUrl
                            }      
    
    if($PSBoundParameters.ContainsKey('CdnType')){
        $cmdArgs.Add('CdnType',$CdnType)
    }
    if($PSBoundParameters.ContainsKey('OrgAssetType')){
        $cmdArgs.Add('OrgAssetType',$OrgAssetType)
    }
    if($PSBoundParameters.ContainsKey('ThumbnailUrl')){
        $cmdArgs.Add('ThumbnailUrl',$ThumbnailUrl)
    }
    
    $result = Add-SPOOrgAssetsLibrary @cmdArgs | Select-Object *

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