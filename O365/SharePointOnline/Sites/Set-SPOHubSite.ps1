#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Sets the hub site information such as name, logo, and description
    
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
        URL of the hub site

    .Parameter Description
        A description of the hub site

    .Parameter LogoUrl
        The URL of a logo to use in the hub navigation

    .Parameter RequiresJoinApproval
        Determines if joining a Hub site requires approval

    .Parameter SiteDesignId
        Site Design ID, for example db752673-18fd-44db-865a-aa3e0b28698e

    .Parameter Title
        The display name of the hub
#>

param(        
    [Parameter(Mandatory=$true)]
    [string]$Site,
    [string]$Title,
    [string]$Description,
    [string]$LogoUrl,
    [bool]$RequiresJoinApproval,
    [string]$SiteDesignId
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Identity' = $Site
                            }      
         
    if([System.String]::IsNullOrWhiteSpace($Title) -eq $false){
        $cmdArgs.Add('Title',$Title)
    }
    if([System.String]::IsNullOrWhiteSpace($Description) -eq $false){
        $cmdArgs.Add('Description',$Description)
    }
    if([System.String]::IsNullOrWhiteSpace($LogoUrl) -eq $false){
        $cmdArgs.Add('LogoUrl',$LogoUrl)
    }
    if([System.String]::IsNullOrWhiteSpace($SiteDesignId) -eq $false){
        $cmdArgs.Add('SiteDesignId',$SiteDesignId)
    }
    if($PSBoundParameters.ContainsKey('RequiresJoinApproval')){
        $cmdArgs.Add('RequiresJoinApproval' , $RequiresJoinApproval)
    }

    $null = Set-SPOHubSite @cmdArgs 
    $result = Get-SPOHubSite -Identity $Site -ErrorAction Stop | Select-Object *

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