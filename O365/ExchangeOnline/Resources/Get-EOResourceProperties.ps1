#Requires -Version 4.0

<#
    .SYNOPSIS
        Connect to Exchange Online and gets the resource properties
    
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
        Specifies the Alias, Display name, Distinguished name, SamAccountName, Guid or user principal name of the resource from which to get properties

    .Parameter Properties
        List of properties to expand. Use * for all properties
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$MailboxId,
    [ValidateSet('*','DisplayName','WindowsEmailAddress','ResourceCapacity','AccountDisabled','IsMailboxEnabled','DistinguishedName','Alias','Guid','SamAccountName')]
    [string[]]$Properties = @('DisplayName','WindowsEmailAddress','ResourceCapacity','AccountDisabled','IsMailboxEnabled','DistinguishedName','Alias','Guid','SamAccountName')
)

try{
    [string[]]$calProperties = @('AllBookInPolicy','AllowRecurringMeetings','BookingWindowInDays','EnforceSchedulingHorizon','MaximumDurationInMinutes','ScheduleOnlyDuringWorkHours')
    $res = Get-Mailbox -Identity $MailboxId | Select-Object $Properties 

    if($null -ne $res){
        $resultMessage = @()
        $resultMessage += $res
        $res = Get-CalendarProcessing -Identity $MailboxId | Select-Object $calProperties

        if($null -ne $res){        
            $resultMessage +=$res
        }
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