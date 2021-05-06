#Requires -Version 5.0
#Requires -Modules @{ModuleName = "microsoftteams"; ModuleVersion = "1.1.6"}

<#
    .SYNOPSIS        
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module microsoftteams 1.1.6 or greater
        Requires a ScriptRunner Microsoft 365 target

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams/Common
             
    .Parameter TargetDomain        
                
    .Parameter OverrideDesiredLink

    .Parameter OverrideDiscoveryUri
        
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$TargetDomain,
    [string]$OverrideDesiredLink,
    [string]$OverrideDiscoveryUri
)

Import-Module microsoftteams

try{ 
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'TargetDomain' = $TargetDomain
                            }
    
    if([System.String]::IsNullOrWhiteSpace($OverrideDesiredLink) -eq $false){
        $cmdArgs.Add('OverrideDesiredLink', $OverrideDesiredLink)
    }
    if([System.String]::IsNullOrWhiteSpace($OverrideDiscoveryUri) -eq $false){
        $cmdArgs.Add('OverrideDiscoveryUri', $OverrideDiscoveryUri)
    }
    
    $result = Get-CsOnlinePowerShellEndpoint @$cmdArgs
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