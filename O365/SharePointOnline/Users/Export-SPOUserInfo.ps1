#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Export user information from site user information list
    
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
        Specifies the login name of the user to export

    .Parameter OutputFolder
        Target folder where the CSV file is generated

    .Parameter Site
        Specifies the URL of the site collection to which you want to export the user
#>

param(            
    [Parameter(Mandatory = $true)]
    [string]$LoginName,
    [Parameter(Mandatory = $true)]
    [string]$OutputFolder,
    [Parameter(Mandatory = $true)]
    [string]$Site
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'LoginName' = $LoginName
                            'OutputFolder' = $OutputFolder
                            'Site' = $Site
                            }      
                            
    $null = Export-SPOUserInfo @cmdArgs 
    $result = "User info for $($LoginName) in folder $($OutputFolder) exported"
      
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