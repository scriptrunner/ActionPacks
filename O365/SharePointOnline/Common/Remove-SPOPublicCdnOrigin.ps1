#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Removes a given public CDN origin based on its identity (id) in your Sharepoint Online Tenant
    
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

    .Parameter Identity
        It's the unique identifier of the Public CDN path
#>

param(     
    [Parameter(Mandatory = $true)]
    [string]$Identity
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Identity' = $Identity
                            'Confirm' = $false
                            }

    $result = Remove-SPOPublicCdnOrigin @cmdArgs | Select-Object *
      
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