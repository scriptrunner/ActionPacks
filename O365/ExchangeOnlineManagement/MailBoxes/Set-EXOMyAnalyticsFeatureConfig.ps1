#Requires -Version 5.0
#Requires -Modules ExchangeOnlineManagement

<#
    .SYNOPSIS
        Configure the availability and features of MyAnalytics for the specified user
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

    .Parameter Feature
        [sr-en] Specifies the MyAnalytics features to enable or disable for the user
        [sr-de] Die MyAnalytics-Funktionen, die für den Benutzer aktiviert oder deaktiviert werden sollen

    .Parameter IsEnabled
        [sr-en] Specifies whether to enable or disable the feature that's specified by the Feature parameter
        [sr-de] Die Funktion, die mit dem Parameter Feature angegeben wird, wird aktiviert oder deaktiviert

    .Parameter PrivacyMode
        [sr-en] Specifies whether to enable or disable MyAnalytics for the specified user
        [sr-de] MyAnalytics für den angegebenen Benutzer aktivieren oder deaktivieren
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$Identity,
    [ValidateSet('all','add-in','dashboard','digest-email')]
    [string]$Feature,
    [bool]$IsEnabled,
    [ValidateSet('opt-in','opt-out')]
    [string]$PrivacyMode
)

Import-Module ExchangeOnlineManagement

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                    'Identity' = $Identity
    }

    if($PSBoundParameters.ContainsKey('Feature') -eq $true){
        $cmdArgs.Add('Feature',$Feature)
    }
    if($PSBoundParameters.ContainsKey('IsEnabled') -eq $true){
        $cmdArgs.Add('IsEnabled',$IsEnabled)
    }
    if($PSBoundParameters.ContainsKey('PrivacyMode') -eq $true){
        $cmdArgs.Add('PrivacyMode',$PrivacyMode)
    }
    $null = Set-MyAnalyticsFeatureConfig @cmdArgs 

    $box = Get-MyAnalyticsFeatureConfig -Identity $Identity -ErrorAction Stop
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