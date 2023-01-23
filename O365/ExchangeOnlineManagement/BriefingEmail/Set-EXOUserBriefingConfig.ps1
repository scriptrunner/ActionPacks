#Requires -Version 5.0
#Requires -Modules ExchangeOnlineManagement

<#
    .SYNOPSIS
        Enable or disable the Briefing for a user
    
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
        [sr-en] Specifies the user that you want to modify(for example, Jeff.Skywalker@DevStar.com)
        [sr-de] Gibt den Benutzer an, der geändert werden soll (z.B., Jeff.Skywalker@DevStar.com)

    .Parameter Enabled
        [sr-en] Specifies whether the briefing e-mail should be enabled or disabled
        [sr-de] Gibt an ob die Briefing-e-Mail für das Postfach aktiviert oder deaktiviert werden soll
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Identity,
    [bool]$Enabled
)

Import-Module ExchangeOnlineManagement

try{

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                    'Identity' = $Identity
                    'Enabled' = $Enabled
    }

    $result = Set-UserBriefingConfig @cmdArgs | Select-Object *
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