#Requires -Version 5.0
#Requires -Modules @{ModuleName = "microsoftteams"; ModuleVersion = "1.0.6"}

<#
.SYNOPSIS
    Submits an operation that applies a policy package to a batch of users in a tenant

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

.Parameter Identities
    [sr-en] A list of one or more users in the tenant
    [sr-de] Benutzer-Liste 

.Parameter PolicyName
    [sr-en] The name of a specific policy package to apply
    [sr-de] Name der Policy
    
.Parameter PolicyType
    [sr-en] The type of the policy package
    [sr-de] Typ der Policy

.Parameter OperationName
    [sr-en] Custom name of the operation
    [sr-de] Benutzerdefinierter Name der Operation
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [string[]]$Identities,
    [Parameter(Mandatory = $true)] 
    [string]$PolicyName,
    [Parameter(Mandatory = $true)] 
    [ValidateSet('CallingLineIdentity', 'OnlineVoiceRoutingPolicy', 'TeamsAppSetupPolicy', 'TeamsAppPermissionPolicy', 'TeamsCallingPolicy', 'TeamsCallParkPolicy', 'TeamsChannelsPolicy', 'TeamsEducationAssignmentsAppPolicy','TeamsEmergencyCallingPolicy', 'TeamsMeetingBroadcastPolicy', 'TeamsEmergencyCallRoutingPolicy', 'TeamsMeetingPolicy', 'TeamsMessagingPolicy', 'TeamsUpdateManagementPolicy', 'TeamsUpgradePolicy', 'TeamsVerticalPackagePolicy', 'TeamsVideoInteropServicePolicy', 'TenantDialPlan')]  
    [string]$PolicyType,
    [string]$OperationName
)

Import-Module microsoftteams

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Identity' = $Identities
                            'PolicyName' = $PolicyName
                            'PolicyType' = $PolicyType
                            }                                 
    if([System.String]::IsNullOrWhiteSpace($OperationName) -eq $false){
        $getArgs.Add('OperationName',$OperationName)
    }

    $opid = New-CsBatchPolicyAssignmentOperation @cmdArgs
    $result = Get-CsBatchPolicyAssignmentOperation -OperationID $opid -ErrorAction Stop
    
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