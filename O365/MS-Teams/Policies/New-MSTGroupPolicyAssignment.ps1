#Requires -Version 5.0
#Requires -Modules @{ModuleName = "microsoftteams"; ModuleVersion = "1.1.4"}

<#
.SYNOPSIS
    Assign a policy to a security group or distribution list

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

.Parameter PolicyName
    [sr-en] The name of the new policy to be assigned
    [sr-de] Der Name der neuen Policy

.Parameter Rank
    [sr-en] The new rank of the policy assignment
    [sr-de] Die neue Position der Policy Zuweisung
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string]$GroupId,
    [Parameter(Mandatory = $true)]   
    [ValidateSet('TeamsAppSetupPolicy', 'TeamsCallingPolicy', 'TeamsCallParkPolicy', 'TeamsChannelsPolicy', 'TeamsComplianceRecordingPolicy', 'TeamsEducationAssignmentsAppPolicy', 'TeamsMeetingBroadcastPolicy', 'TeamsMeetingPolicy', 'TeamsMessagingPolicy')]      
    [string]$PolicyType,
    [Parameter(Mandatory = $true)]   
    [string]$PolicyName,
    [int]$Rank
)

Import-Module microsoftteams

try{
    [hashtable]$setArgs = @{'ErrorAction' = 'Stop'
                            'GroupId' = $GroupId
                            'PolicyName' = $PolicyName
                            'PolicyType' = $PolicyType
                            }                              
    if($Rank -gt 0){
        $setArgs.Add('Rank',$Rank)
    }

    $null = New-CsGroupPolicyAssignment @setArgs

    $setArgs.Remove('PolicyName')
    $result = Get-CsGroupPolicyAssignment @setArgs | Select-Object *    
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