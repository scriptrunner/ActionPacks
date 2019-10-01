#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Updates a previously uploaded site design
    
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
        The site design Id

    .Parameter Title
        The display name of the site design

    .Parameter WebTemplate
        Identifies which base template to add the design to

    .Parameter Description
        The display description of the site design

    .Parameter SiteScript
        A site script

    .Parameter IsDefault
        Applies the site design to the default site template

    .Parameter PreviewImageAltText
        The alt text description of the image for accessibility

    .Parameter PreviewImageUrl
        The URL of a preview image
#>

param(   
    [Parameter(Mandatory = $true)]  
    [string]$Identity,   
    [string]$Title,    
    [Validateset('Team site template','Communication site template')] 
    [string]$WebTemplate,
    [string]$Description,
    [switch]$IsDefault,
    [string]$PreviewImageAltText,
    [string]$PreviewImageUrl
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{    
    [guid]$tmp = [System.Guid]::NewGuid()
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Identity' = $Identity
                            }

    if($WebTemplate -eq 'Team site template'){
        $cmdArgs.Add('WebTemplate','64')
    }
    elseif($WebTemplate -eq 'Communication site template'){
        $cmdArgs.Add('WebTemplate','68')
    }
    if($PSBoundParameters.ContainsKey('Title')){
        $cmdArgs.Add('Title',$Title)
    }
    if($PSBoundParameters.ContainsKey('Description')){
        $cmdArgs.Add('Description',$Description)
    }
    if($PSBoundParameters.ContainsKey('IsDefault')){
        $cmdArgs.Add('IsDefault',$IsDefault)
    }
    if($PSBoundParameters.ContainsKey('PreviewImageAltText')){
        $cmdArgs.Add('PreviewImageAltText',$PreviewImageAltText)
    }
    if($PSBoundParameters.ContainsKey('PreviewImageUrl')){
        $cmdArgs.Add('PreviewImageUrl',$PreviewImageUrl)
    }

    $result = Set-SPOSiteDesign @cmdArgs | Select-Object *
      
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