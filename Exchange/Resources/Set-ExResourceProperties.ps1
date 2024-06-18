#Requires -Version 5.0

<#
    .SYNOPSIS
        Connect to Microsoft Exchange Server and sets the resource properties
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH 

    .COMPONENT       

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/Exchange/Resources

    .Parameter MailboxId
        [sr-en] Alias, Display name, Distinguished name, SamAccountName, Guid or user principal name of the resource from which to set properties
    
    .Parameter AccountDisabled
        [sr-en] Disable the account that's associated with the resource

    .Parameter Alias
        [sr-en] Alias name of the resource

    .Parameter DisplayName
        [sr-en] Display name of the resource

    .Parameter ResourceCapacity
        [sr-en] Capacity of the resource

    .Parameter AllBookInPolicy
        [sr-en] Automatically approve in-policy requests from all users

    .Parameter AllowRecurringMeetings
        [sr-en] Allow recurring meetings

    .Parameter BookingWindowInDays
        [sr-en] Maximum number of days in advance that the resource can be reserved

    .Parameter EnforceSchedulingHorizon
        [sr-en] Behavior of recurring meetings that extend beyond the date specified by the BookingWindowInDays parameter

    .Parameter MaximumDurationInMinutes
        [sr-en] Duration in minutes for meeting requests

    .Parameter ScheduleOnlyDuringWorkHours
        [sr-en] Allow meetings to be scheduled outside of the working hours that are defined for the resource
#>

param(    
    [Parameter(Mandatory = $true)]
    [string]$MailboxId,
    [switch]$AccountDisabled,    
    [string]$Alias,
    [string]$DisplayName,
    [int]$ResourceCapacity,
    [bool]$AllBookInPolicy ,
    [bool]$AllowRecurringMeetings,
    [int]$BookingWindowInDays,
    [bool]$EnforceSchedulingHorizon,
    [int]$MaximumDurationInMinutes,
    [bool]$ScheduleOnlyDuringWorkHours
)

try{
    $box = Get-Mailbox -Identity $MailboxId | Select-Object Name,AccountDisabled
    if($null -ne $box){
        if($PSBoundParameters.ContainsKey('Alias')){
            Set-Mailbox -Identity $box.Name -Alias $Alias
        }
        if($PSBoundParameters.ContainsKey('DisplayName')){
            Set-Mailbox -Identity $box.Name -DisplayName $DisplayName
        }
        if($PSBoundParameters.ContainsKey('ResourceCapacity') -eq $true ){
            Set-Mailbox -Identity $box.Name -ResourceCapacity $ResourceCapacity
        }
        if($PSBoundParameters.ContainsKey('AllBookInPolicy') -eq $true ){
            Set-CalendarProcessing -Identity $box.Name -AllBookInPolicy $AllBookInPolicy
        }
        if($PSBoundParameters.ContainsKey('AllowRecurringMeetings') -eq $true ){
            Set-CalendarProcessing -Identity $box.Name -AllowRecurringMeetings $AllowRecurringMeetings
        }
        if($PSBoundParameters.ContainsKey('BookingWindowInDays') -eq $true ){
            Set-CalendarProcessing -Identity $box.Name -BookingWindowInDays $BookingWindowInDays
        }      
        if($PSBoundParameters.ContainsKey('EnforceSchedulingHorizon') -eq $true ){
            Set-CalendarProcessing -Identity $box.Name -EnforceSchedulingHorizon $EnforceSchedulingHorizon
        }
        if($PSBoundParameters.ContainsKey('MaximumDurationInMinutes') -eq $true ){
            Set-CalendarProcessing -Identity $box.Name -MaximumDurationInMinutes $MaximumDurationInMinutes
        }
        if($PSBoundParameters.ContainsKey('ScheduleOnlyDuringWorkHours') -eq $true ){
            Set-CalendarProcessing -Identity $box.Name -ScheduleOnlyDuringWorkHours $ScheduleOnlyDuringWorkHours
        }
        if($PSBoundParameters.ContainsKey('AccountDisabled') -ne $true){
            $AccountDisabled = $box.AccountDisabled
        }
        Set-Mailbox -Identity $box.Name -AccountDisabled:$AccountDisabled -Confirm:$false

        $resultMessage = @()
        $resultMessage += Get-Mailbox -Identity $box.Name | `
                Select-Object AccountDisabled,Alias,DisplayName,ResourceCapacity,WindowsEmailAddress
        $resultMessage += Get-CalendarProcessing -Identity $box.Name | `
                Select-Object AllBookInPolicy,AllowRecurringMeetings,BookingWindowInDays,EnforceSchedulingHorizon,MaximumDurationInMinutes,ScheduleOnlyDuringWorkHours
        if($SRXEnv) {
            $SRXEnv.ResultMessage = $resultMessage  
        }
        else{
            Write-Output $resultMessage
        }
    }    
    else{
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "Resource $($MailboxId) not found"
        } 
        Throw  "Resource $($MailboxId) not found"
    }
}
catch{
    throw
}
finally{
    
}