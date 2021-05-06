#Requires -Version 5.0
#Requires -Modules @{ModuleName = "microsoftteams"; ModuleVersion = "1.1.4"}

<#
.SYNOPSIS
    Returns group policy assignments

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
    [string]$GroupId,
    [ValidateSet('TeamsAppSetupPolicy', 'TeamsCallingPolicy', 'TeamsCallParkPolicy', 'TeamsChannelsPolicy', 'TeamsComplianceRecordingPolicy', 'TeamsEducationAssignmentsAppPolicy', 'TeamsMeetingBroadcastPolicy', 'TeamsMeetingPolicy', 'TeamsMessagingPolicy')]
    [string]$PolicyType
)

Import-Module microsoftteams

try{
    [hashtable]$getArgs = @{'ErrorAction' = 'Stop'}  
                            
    if([System.String]::IsNullOrWhiteSpace($PolicyType) -eq $false){
        $getArgs.Add('PolicyType',$PolicyType)
    }
    if([System.String]::IsNullOrWhiteSpace($GroupId) -eq $false){
        $getArgs.Add('GroupId', $GroupId)
    }

    $result = Get-CsGroupPolicyAssignment @getArgs | Select-Object *
    
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