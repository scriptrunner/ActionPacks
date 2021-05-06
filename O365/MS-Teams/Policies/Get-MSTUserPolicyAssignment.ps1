#Requires -Version 5.0
#Requires -Modules @{ModuleName = "microsoftteams"; ModuleVersion = "1.0.5"}

<#
.SYNOPSIS
    Return the policy assignments for a user

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Module microsoftteams 1.0.5 or greater
    Requires a ScriptRunner Microsoft 365 target

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams/Policies
    
.Parameter Identity
    [sr-en] The user that will get their assigned policies
    [sr-de] Benutzer, der die ihnen zugewiesenen Policies erhält
    
.Parameter PolicyType
    [sr-en] The type of the policy package
    [sr-de] Typ der Policy
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$Identity,
    [ValidateSet('CallingLineIdentity', 'OnlineVoiceRoutingPolicy', 'TeamsAppSetupPolicy', 'TeamsAppPermissionPolicy', 'TeamsCallingPolicy', 'TeamsCallParkPolicy', 'TeamsChannelsPolicy', 'TeamsEducationAssignmentsAppPolicy','TeamsEmergencyCallingPolicy', 'TeamsMeetingBroadcastPolicy', 'TeamsEmergencyCallRoutingPolicy', 'TeamsMeetingPolicy', 'TeamsMessagingPolicy', 'TeamsUpdateManagementPolicy', 'TeamsUpgradePolicy', 'TeamsVerticalPackagePolicy', 'TeamsVideoInteropServicePolicy', 'TenantDialPlan')]  
    [string]$PolicyType
)

Import-Module microsoftteams

try{
    [hashtable]$getArgs = @{'ErrorAction' = 'Stop'
                            'Identity' = $Identity
                            }  
                            
    if([System.String]::IsNullOrWhiteSpace($PolicyType) -eq $false){
        $getArgs.Add('PolicyType',$PolicyType)
    }

    $result = Get-CsUserPolicyAssignment @getArgs | Select-Object *
    
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