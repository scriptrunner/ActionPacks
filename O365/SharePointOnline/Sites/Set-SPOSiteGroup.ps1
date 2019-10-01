#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Updates the SharePoint Online owner and permission levels on a group inside a site collection
    
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
        Specifies the name of the group

    .Parameter Site
        Specifies the site collection the group belongs to

    .Parameter Name
        Specifies the new name of the group

    .Parameter Owner
        Specifies the owner (individual or a security group) of the group to be created

    .Parameter PermissionLevelsToAdd
        Specifies the permission levels to grant to the group
        
    .Parameter PermissionLevelsToRemove
        Specifies the permission levels to remove from the group
#>

param(            
    [Parameter(Mandatory = $true)]
    [string]$Site,
    [Parameter(Mandatory = $true)]
    [string]$Group,
    [string]$Name,
    [string]$Owner,
    [ValidateSet('View Only','Read','Limited Access','Contribute','Approve','Edit','Design','Manage Hierarchy','Full Control')]
# localized :-(   [ValidateSet('Nur anzeigen','Lesen','Beschränkter Zugriff','Mitwirken','Genehmigen','Bearbeiten','Entwerfen','Hierarchie verwalten','Vollzugriff')]
    [string]$PermissionLevelsToAdd,
    [ValidateSet('View Only','Read','Limited Access','Contribute','Approve','Edit','Design','Manage Hierarchy','Full Control')]
# localized :-(   [ValidateSet('Nur anzeigen','Lesen','Beschränkter Zugriff','Mitwirken','Genehmigen','Bearbeiten','Entwerfen','Hierarchie verwalten','Vollzugriff')]
    [string]$PermissionLevelsToRemove
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Site' = $Site
                            'Identity' = $Group
                            }      
    
    if([System.String]::IsNullOrWhiteSpace($Name) -eq $false){
        $cmdArgs.Add('Name',$Name)
    }
    if([System.String]::IsNullOrWhiteSpace($Owner) -eq $false){
        $cmdArgs.Add('Owner',$Owner)
    }
    if([System.String]::IsNullOrWhiteSpace($PermissionLevelsToAdd) -eq $false){
        $cmdArgs.Add('PermissionLevelsToAdd',$PermissionLevelsToAdd)
    }
    if([System.String]::IsNullOrWhiteSpace($PermissionLevelsToRemove) -eq $false){
        $cmdArgs.Add('PermissionLevelsToRemove',$PermissionLevelsToRemove)
    }

    $result = Set-SPOSiteGroup @cmdArgs | Select-Object *
      
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