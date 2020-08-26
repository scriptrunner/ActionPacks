#Requires -Version 5.0
#Requires -Modules ExchangeOnlineManagement

<#
    .SYNOPSIS
        Gets he current state of the Briefing email flag for the specified user
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/ExchangeOnlinev2/BriefingEmail

    .Parameter Identity
        Specifies the user that you want to view(for example, Jeff.Skywalker@DevStar.com)
        [sr-de] Gibt den Benutzer an, der angezeigt werden soll
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

    $result = Get-UserBriefingConfig @cmdArgs | Select-Object *
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $result
    } 
    else{
        Write-Output $result 
    }
}
catch{
    throw
}
finally{
    
}