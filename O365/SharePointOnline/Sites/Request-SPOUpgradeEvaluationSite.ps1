#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Requests to create a copy of an existing site collection for the purposes of validating the effects of upgrade without affecting the original site
    
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
        Specifies the SharePoint Online site collection for which you want to request a copy for the new Upgrade or Evaluation site collection

    .Parameter NoEmail
        Specifies that the system not send the requester and site collection administrators an email message at the end of the upgrade evaluation site creation process

    .Parameter NoUpgrade
        Specifies that the system not perform an upgrade as part of the evaluation site creation process
#>

param(   
    [Parameter(Mandatory = $true)]  
    [string]$Identity,
    [switch]$NoEmail,
    [switch]$NoUpgrade
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{       
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Identity' = $Identity
                            'Confirm' = $false
                            'NoEmail' = $NoEmail
                            'NoUpgrade' = $NoUpgrade
                            }      

    $result = Request-SPOUpgradeEvaluationSite @cmdArgs | Select-Object *
      
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