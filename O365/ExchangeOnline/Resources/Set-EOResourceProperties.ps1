#Requires -Version 4.0

<#
    .SYNOPSIS
        Connect to Exchange Online and sets the resource properties
        Only parameters with value are set
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT       
        ScriptRunner Version 4.x or higher

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/ExchangeOnline/Resources

    .Parameter MailboxId
        Specifies the Alias, Display name, Distinguished name, SamAccountName, Guid or user principal name of the resource from which to set properties
    
    .Parameter AccountDisabled
        Specifies whether to disable the account that's associated with the resource

    .Parameter Alias
        Specifies the alias name of the resource

    .Parameter DisplayName
        Specifies the display name of the resource

    .Parameter ResourceCapacity
        Specifies the capacity of the resource

    .Parameter WindowsEmailAddress
        Specifies the windows mail address of the resource

    .Parameter AllBookInPolicy
        Specifies whether to automatically approve in-policy requests from all users

    .Parameter AllowRecurringMeetings
        Specifies whether to allow recurring meetings

    .Parameter BookingWindowInDays
        Specifies the maximum number of days in advance that the resource can be reserved

    .Parameter EnforceSchedulingHorizon
        Specifies the behavior of recurring meetings that extend beyond the date specified by the BookingWindowInDays parameter

    .Parameter MaximumDurationInMinutes
        Specifies duration in minutes for meeting requests

    .Parameter ScheduleOnlyDuringWorkHours
        Specifies whether to allow meetings to be scheduled outside of the working hours that are defined for the resource
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$MailboxId,
    [switch]$AccountDisabled,    
    [string]$Alias,
    [string]$DisplayName,
    [int]$ResourceCapacity,
    [string]$WindowsEmailAddress,
    [bool]$AllBookInPolicy ,
    [bool]$AllowRecurringMeetings,
    [int]$BookingWindowInDays,
    [bool]$EnforceSchedulingHorizon,
    [int]$MaximumDurationInMinutes,
    [bool]$ScheduleOnlyDuringWorkHours
)

try{
    [string[]]$Properties = @('AccountDisabled','Alias','DisplayName','ResourceCapacity','WindowsEmailAddress')
    [string[]]$calProperties = @('AllBookInPolicy','AllowRecurringMeetings','BookingWindowInDays','EnforceSchedulingHorizon','MaximumDurationInMinutes','ScheduleOnlyDuringWorkHours')

    $box = Get-Mailbox -Identity $MailboxId
    if($null -ne $box){
        if(-not [System.String]::IsNullOrWhiteSpace($Alias)){
            $null = Set-Mailbox -Identity $MailboxId -Alias $Alias
        }
        if(-not [System.String]::IsNullOrWhiteSpace($DisplayName)){
            $null = Set-Mailbox -Identity $MailboxId -DisplayName $DisplayName
        }
        if($PSBoundParameters.ContainsKey('ResourceCapacity') -eq $true ){
            $null = Set-Mailbox -Identity $MailboxId -ResourceCapacity $ResourceCapacity
        }
        if(-not [System.String]::IsNullOrWhiteSpace($WindowsEmailAddress)){
            $null = Set-Mailbox -Identity $MailboxId -WindowsEmailAddress $WindowsEmailAddress
        }
        if($PSBoundParameters.ContainsKey('AllBookInPolicy') -eq $true ){
            $null = Set-CalendarProcessing -Identity $MailboxId -AllBookInPolicy $AllBookInPolicy
        }
        if($PSBoundParameters.ContainsKey('AllowRecurringMeetings') -eq $true ){
            $null = Set-CalendarProcessing -Identity $MailboxId -AllowRecurringMeetings $AllowRecurringMeetings
        }
        if($PSBoundParameters.ContainsKey('BookingWindowInDays') -eq $true ){
            $null = Set-CalendarProcessing -Identity $MailboxId -BookingWindowInDays $BookingWindowInDays
        }      
        if($PSBoundParameters.ContainsKey('EnforceSchedulingHorizon') -eq $true ){
            $null = Set-CalendarProcessing -Identity $MailboxId -EnforceSchedulingHorizon $EnforceSchedulingHorizon
        }
        if($PSBoundParameters.ContainsKey('MaximumDurationInMinutes') -eq $true ){
            $null = Set-CalendarProcessing -Identity $MailboxId -MaximumDurationInMinutes $MaximumDurationInMinutes
        }
        if($PSBoundParameters.ContainsKey('ScheduleOnlyDuringWorkHours') -eq $true ){
            $null = Set-CalendarProcessing -Identity $MailboxId -ScheduleOnlyDuringWorkHours $ScheduleOnlyDuringWorkHours
        }
        if($PSBoundParameters.ContainsKey('AccountDisabled') -ne $true){
            $AccountDisabled = $box.AccountDisabled
        }
        $null = Set-Mailbox -Identity $box.Name -AccountDisabled:$AccountDisabled -Confirm:$false

        $resultMessage = Get-Mailbox -Identity $MailboxId | Select-Object $Properties
        $resultMessage += Get-CalendarProcessing -Identity $MailboxId | Select-Object $calProperties
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