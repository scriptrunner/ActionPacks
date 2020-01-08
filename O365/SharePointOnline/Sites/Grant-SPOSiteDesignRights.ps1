#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Used to apply permissions to a set of users or a security group, 
        effectively scoping the visibility of the site design in the UX
    
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
        The ID of the site design to get scoping information

    .Parameter Principals
        One or more principles to add permissions for, comma separated
#>

param(        
    [Parameter(Mandatory=$true)]
    [string]$Site,
    [Parameter(Mandatory=$true)]
    [string]$Principals
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{
    [string[]]$tmp = $Principals.Split(',')
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Identity' = $Site
                            'Rights' = 'View'
                            'Principals' = $tmp
                            }              

    $result = Grant-SPOSiteDesignRights @cmdArgs                      

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