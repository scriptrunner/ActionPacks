#Requires -Version 5.0
#Requires -Modules @{ModuleName = "microsoftteams"; ModuleVersion = "1.1.4"}

<#
.SYNOPSIS
    Remove a group policy assignment

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Module microsoftteams 1.1.4 or greater
    Requires a ScriptRunner Microsoft 365 target

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams/Policies
    
.Parameter GroupId 
    [sr-en] Specifies the object id of the group
    [sr-de] ID der Gruppe
    
.Parameter PolicyType
    [sr-en] The type of the policy package
    [sr-de] Typ der Policy
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$GroupId,
    [Parameter(Mandatory = $true)]   
    [ValidateSet('TeamsAppSetupPolicy', 'TeamsCallingPolicy', 'TeamsCallParkPolicy', 'TeamsChannelsPolicy', 'TeamsComplianceRecordingPolicy', 'TeamsEducationAssignmentsAppPolicy', 'TeamsMeetingBroadcastPolicy', 'TeamsMeetingPolicy', 'TeamsMessagingPolicy')]
    [string]$PolicyType
)

Import-Module microsoftteams

try{
    [hashtable]$remArgs = @{'ErrorAction' = 'Stop'
                            'GroupId' = $GroupId
                            'PolicyType' = $PolicyType
                            }  

    $null = Remove-CsGroupPolicyAssignment @remArgs
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Group policy assignment successful removed"
    }
    else{
        Write-Output "Group policy assignment successful removed"
    }
}
catch{
    throw
}
finally{
}