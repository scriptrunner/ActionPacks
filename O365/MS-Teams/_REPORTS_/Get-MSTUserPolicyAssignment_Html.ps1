#Requires -Version 5.0
#Requires -Modules @{ModuleName = "microsoftteams"; ModuleVersion = "1.0.5"}

<#
.SYNOPSIS
    Generates a report with the policy assignments for a user

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
    Requires Library script MSTLibrary.ps1
    Requires Library Script ReportLibrary from the Action Pack Reporting\_LIB_

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/O365/MS-Teams/_REPORTS_
 
.Parameter MSTCredential
    [sr-en] Provides the user ID and password for organizational ID credentials
    [sr-de] Enthält den Benutzernamen und das Passwort für die Anmeldung
    
.Parameter Identity
    [sr-en] The user that will get their assigned policy package
    [sr-de] Benutzer ID dessen Policies-Pakete angezeigt werden
    
.Parameter PolicyType
    [sr-en] The type of the policy package
    [sr-de] Typ des Ploiciy Pakets    

.Parameter TenantID
    [sr-en] Specifies the ID of a tenant
    [sr-de] ID eines Mandanten
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]   
    [pscredential]$MSTCredential,
    [Parameter(Mandatory = $true)]   
    [string]$Identity,
    [ValidateSet('CallingLineIdentity', 'OnlineVoiceRoutingPolicy', 'TeamsAppSetupPolicy', 'TeamsAppPermissionPolicy', 'TeamsCallingPolicy', 'TeamsCallParkPolicy', 'TeamsChannelsPolicy', 'TeamsEducationAssignmentsAppPolicy','TeamsEmergencyCallingPolicy', 'TeamsMeetingBroadcastPolicy', 'TeamsEmergencyCallRoutingPolicy', 'TeamsMeetingPolicy', 'TeamsMessagingPolicy', 'TeamsUpdateManagementPolicy', 'TeamsUpgradePolicy', 'TeamsVerticalPackagePolicy', 'TeamsVideoInteropServicePolicy', 'TenantDialPlan')]  
    [string]$PolicyType,
    [string]$TenantID
)

Import-Module microsoftteams

try{
    ConnectMSTeams -MTCredential $MSTCredential -TenantID $TenantID

    [hashtable]$getArgs = @{'ErrorAction' = 'Stop'
                            'Identity' = $Identity
                            }  
                            
    if([System.String]::IsNullOrWhiteSpace($PolicyType) -eq $false){
        $getArgs.Add('PolicyType',$PolicyType)
    }

    $result = @()
    $null = Get-CsUserPolicyAssignment @getArgs | Select-Object *  | ForEach-Object{
        $result += [pscustomobject]@{
                PolicyName = $_.PolicyName
                PolicyType  = $_.PolicyType
                AssignmentType = $_.PolicySource.AssignmentType
        }   
    }
    
    ConvertTo-ResultHtml -Result $result
}
catch{
    throw
}
finally{
    DisconnectMSTeams
}