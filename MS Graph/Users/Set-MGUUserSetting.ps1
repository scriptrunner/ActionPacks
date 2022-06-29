#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Users

<#
    .SYNOPSIS
        Updates settings for the user
        
    .DESCRIPTION          

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Library script MS Graph\_LIB_\MGLibrary
        Requires Modules Microsoft.Graph.Users

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/MS%20Graph/Users

    .Parameter UserId
        [sr-en] User identifier
        [sr-de] Benutzer ID

    .PARAMETER ContributionToContentDiscoveryDisabled
        [sr-en] Disable documents in the user's Office Delve
        [sr-de] Benutzer Dokumente sperren

    .PARAMETER ContributionToContentDiscoveryAsOrganizationDisabled
        [sr-en] Reflects the Office Delve organization level setting
        [sr-de] Einstellung der Organisation
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$UserId,
    [bool]$ContributionToContentDiscoveryDisabled,
    [bool]$ContributionToContentDiscoveryAsOrganizationDisabled
)

Import-Module Microsoft.Graph.Users

try{
    ConnectMSGraph 
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'    
                        'UserId'= $UserId
                        'Confirm' = $false
                        'PassThru' = $null
    }
    if($PSBoundParameters.ContainsKey('ContributionToContentDiscoveryDisabled') -eq $true){
        $cmdArgs.Add('ContributionToContentDiscoveryDisabled',$ContributionToContentDiscoveryDisabled)
    }
    if($PSBoundParameters.ContainsKey('ContributionToContentDiscoveryAsOrganizationDisabled') -eq $true){
        $cmdArgs.Add('ContributionToContentDiscoveryAsOrganizationDisabled',$ContributionToContentDiscoveryAsOrganizationDisabled)
    }
    $null = Update-MgUserSetting @cmdArgs

    $result = Get-MgUserSetting -UserId $UserId | Select-Object *    
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
    DisconnectMSGraph
}