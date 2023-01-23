#Requires -Version 5.0
#Requires -Modules ExchangeOnlineManagement

<#
    .SYNOPSIS
        View the availability and feature status of MyAnalytics for the specified user
        This cmdlet is available in version 2.0.4-Preview3 of the EXO V2 Module
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT       
        Requires PS Module ExchangeOnlineManagement

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/ExchangeOnlinev2/MailBoxes

    .Parameter Identity
        [sr-en] Specifies name, Alias or SamAccountName of the mailbox
        [sr-de] Name, Guid oder UPN des Postfachs
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Identity
)

Import-Module ExchangeOnlineManagement

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                    'Identity' = $Identity
    }

    $box = Get-MyAnalyticsFeatureConfig @cmdArgs
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $box
    } 
    else{
        Write-Output $box 
    }
}
catch{
    throw
}
finally{    
}