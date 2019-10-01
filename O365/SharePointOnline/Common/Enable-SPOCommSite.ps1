#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Enables the modern communication site experience on an existing site
    
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

    .Parameter Site
        URL of the site for enabling the modern communication

    .Parameter DesignPackage
        The topic design will be applied to the new home page
#>

param(     
    [Parameter(Mandatory = $true)]
    [string]$Site,
    [Parameter(Mandatory = $true)]
    [ValidateSet('Topic','Showcase','Blank')]
    [string]$DesignPackage
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{    
    [guid]$packageid = [System.Guid]::Empty
    switch ($DesignPackage){
        'Topic' {
            $packageid = '96c933ac-3698-44c7-9f4a-5fd17d71af9e'
        }
        'Showcase' {
            $packageid = '6142d2a0-63a5-4ba0-aede-d9fefca2c767'
        }
        'Blank' {
            $packageid = 'f6cc5403-0d63-442e-96c0-285923709ffc'
        }
    }
    $result = Enable-SPOCommSite -SiteUrl $Site -DesignPackageId $packageid -ErrorAction Stop | Select-Object *
      
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