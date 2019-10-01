#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Creates a new group in a SharePoint Online site collection
    
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

    .Parameter Group
        Specifies the name of the group to add

    .Parameter Site
        Specifies the site collection to add the group to

    .Parameter PermissionLevel
        Specifies the permission level to grant to the newly created group
#>

param(            
    [Parameter(Mandatory = $true)]
    [string]$Site,
    [Parameter(Mandatory = $true)]
    [string]$Group,
    [Parameter(Mandatory = $true)]
    [ValidateSet('View Only','Read','Limited Access','Contribute','Approve','Edit','Design','Manage Hierarchy','Full Control')]
# localized :-(   [ValidateSet('Nur anzeigen','Lesen','Beschränkter Zugriff','Mitwirken','Genehmigen','Bearbeiten','Entwerfen','Hierarchie verwalten','Vollzugriff')]
    [string]$PermissionLevel
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Site' = $Site
                            'Group' = $Group
                            'PermissionLevels' = @($PermissionLevel)
                            }      
    
    $result = New-SPOSiteGroup @cmdArgs | Select-Object *
      
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