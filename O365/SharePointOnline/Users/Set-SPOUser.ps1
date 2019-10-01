#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Configures properties on an existing user
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/SharePointOnline/Users

    .Parameter LoginName
        Specifies the user name

    .Parameter Site
        Specifies the full URL of the site collection

    .Parameter IsSiteCollectionAdmin
        Specifies whether the user is a site collection administrator
#>

param(            
    [Parameter(Mandatory = $true)]
    [string]$LoginName,
    [Parameter(Mandatory = $true)]
    [string]$Site,
    [bool]$IsSiteCollectionAdmin
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'LoginName' = $LoginName
                            'Site' = $Site
                            }      
                            
    if($PSBoundParameters.ContainsKey('IsSiteCollectionAdmin')){
        $cmdArgs.Add('IsSiteCollectionAdmin',$IsSiteCollectionAdmin)
    }
    
    $result = Set-SPOUser @cmdArgs | Select-Object *
      
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