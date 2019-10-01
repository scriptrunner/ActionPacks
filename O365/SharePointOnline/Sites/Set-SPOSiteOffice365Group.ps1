#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Connects a top-level SPO site collection to a new Office 365 Group
    
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

    .Parameter Site
        The site collection being connected to new Office 365 Group

    .Parameter Alias
        Specifies the email alias for the new Office 365 Group that will be created

    .Parameter DisplayName
        Specifies the name of the new Office 365 Group that will be created

    .Parameter Classification
        Specifies the classification value, if classifications are set for the organization

    .Parameter Description
        Specifies the group’s description

    .Parameter IsPublic
        Determines the Office 365 Group’s privacy setting

    .Parameter KeepOldHomepage
        For sites that already have a modern page set as homepage, you can specify whether you want to keep it as the homepage
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Site, 
    [Parameter(Mandatory = $true)]
    [string]$DisplayName,
    [Parameter(Mandatory = $true)]
    [string]$Alias,
    [string]$Classification,
    [string]$Description,
    [switch]$IsPublic,
    [switch]$KeepOldHomepage
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Site' = $Site
                            'DisplayName' = $DisplayName
                            'Alias' = $Alias
                            'IsPublic' = $IsPublic
                            'KeepOldHomepage' = $KeepOldHomepage
                            }      
    
    If($PSBoundParameters.ContainsKey('Classification')){
        $cmdArgs.Add('Classification',$Classification)
    }
    If($PSBoundParameters.ContainsKey('Description')){
        $cmdArgs.Add('Description',$Description)
    }

    $result = Set-SPOSiteOffice365Group @cmdArgs | Select-Object *

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