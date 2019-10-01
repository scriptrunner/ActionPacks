#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Enables the hub site feature on a site to make it a hub site
    
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
        Specifies the URL of the site collection to which to enable the hub site features

    .Parameter Principals
        Specifies One or more principles (user or group) to be granted rights to the specified HubSite, 
        comma separated
#>

param(        
    [Parameter(Mandatory=$true)]
    [string]$Site,
    [string]$Principals
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Site' = $Site
                            }      
       
    if([System.String]::IsNullOrWhiteSpace($Principals) -eq $true){
        $cmdArgs.Add('Principals',$null)
    }  
    else{
        $cmdArgs.Add('Principals',$Principals.Split(','))
    }          

    $result = Register-SPOHubSite @cmdArgs                      

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