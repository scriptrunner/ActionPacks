#Requires -Version 5.0
#Requires -Modules @{ModuleName = "microsoftteams"; ModuleVersion = "1.0.5"}

<#
.SYNOPSIS
    Retrieve the status of batch policy assignment operations

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

.Parameter OperationID
    [sr-en] The ID of the operation
    [sr-de] ID der Operation
    
.Parameter Status
    [sr-en] The status for the operation
    [sr-de] Status der Operation
#>

[CmdLetBinding()]
Param(
    [string]$OperationID,
    [ValidateSet('NotStarted', 'InProgress', 'Completed')]
    [string]$Status
)

Import-Module microsoftteams

try{
    [hashtable]$getArgs = @{'ErrorAction' = 'Stop'}  
    if([System.string]::IsNullOrWhiteSpace($OperationID) -eq $false){
        $getArgs.Add('OperationID',$OperationID)
    }
    if([System.string]::IsNullOrWhiteSpace($Status) -eq $false){
        $getArgs.Add('Status',$Status)
    }

    $result = Get-CsBatchPolicyAssignmentOperation @getArgs | Select-Object *    
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