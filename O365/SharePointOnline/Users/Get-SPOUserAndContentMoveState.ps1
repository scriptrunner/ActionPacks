#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Allows a SharePoint administrators to check the status of a user or site move across geo locations
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module Microsoft.Online.SharePoint.PowerShell
        ScriptRunner Version 4.2.x or higher

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/SharePointOnline/Users

    .Parameter MoveDirection
        Allows you to define the direction of the user move in relation to your current SharePoint location

    .Parameter MoveState
        Move State current status

    .Parameter MoveEndTime
        Allows you to obtain the moves that are scheduled to end by a particular time

    .Parameter MoveStartTime
        Allows you to obtain the moves that are scheduled to begin at a particular time
        
    .Parameter OdbMoveId
        Onedrive GUID MoveID that you get when you start a job
    
    .Parameter UserPrincipalName
        User Principal name is the unique property on Azure AD for each user
#>

param(            
    [Parameter(Mandatory = $true, ParameterSetName = 'User')]
    [string]$UserPrincipalName,
    [Parameter(Mandatory = $true, ParameterSetName = 'OdbMove')]
    [string]$OdbMoveId,
    [Parameter(ParameterSetName = 'MoveReport')]
    [ValidateSet('All', 'MoveIn', 'MoveOut')]
    [string]$MoveDirection,
    [Parameter(ParameterSetName = 'MoveReport')]
    [ValidateSet('All', 'NotStarted', 'Scheduled', 'InProgress', 'Stopped', 'Success', 'Failed')]
    [string]$MoveState,
    [Parameter(ParameterSetName = 'MoveReport',HelpMessage="ASRDisplay(Date)")]
    [datetime]$MoveEndTime,
    [Parameter(ParameterSetName = 'MoveReport',HelpMessage="ASRDisplay(Date)")]
    [datetime]$MoveStartTime
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}      
    
    if($PSCmdlet.ParameterSetName -eq 'OdbMove'){
        $cmdArgs.Add('OdbMoveId',$OdbMoveId)
    }  
    elseif($PSCmdlet.ParameterSetName -eq 'User'){
        $cmdArgs.Add('UserPrincipalName',$UserPrincipalName)
    }       
    if($PSBoundParameters.ContainsKey('MoveDirection')){
        $cmdArgs.Add('MoveDirection',$MoveDirection)
    } 
    if($PSBoundParameters.ContainsKey('MoveState')){
        $cmdArgs.Add('MoveState',$MoveState)
    }   
    if($PSBoundParameters.ContainsKey('MoveEndTime')){
        $cmdArgs.Add('MoveEndTime',$MoveEndTime)
    } 
    if($PSBoundParameters.ContainsKey('MoveStartTime')){
        $cmdArgs.Add('MoveStartTime',$MoveStartTime)
    }

    $result = Get-SPOUserAndContentMoveState @cmdArgs | Select-Object *
      
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $result
    }
    else {
        Write-Output $result 
    }    
}
catch{
    throw
}
finally{
}