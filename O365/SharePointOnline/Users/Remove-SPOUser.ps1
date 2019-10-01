#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Removes a user or a security group from a site collection or a group
    
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
        Specifies the site collection to remove the user from

    .Parameter Group
        Specifies the group to remove the user from
#>

param(         
    [Parameter(Mandatory = $true)]
    [string]$LoginName,   
    [Parameter(Mandatory = $true)]
    [string]$Site,
    [string]$Group
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Site' = $Site
                            'LoginName' = $LoginName
                            }      
                            
    if($PSBoundParameters.ContainsKey('Group')){
        $cmdArgs.Add('Group',$Group)
    }
    
    $result = Remove-SPOUser @cmdArgs | Select-Object *
      
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