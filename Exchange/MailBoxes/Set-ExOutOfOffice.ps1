<#
    .SYNOPSIS
        Connect to Microsoft Exchange Server and enable or disable Automatic Replies for a specified mailbox
        Requirements 
        ScriptRunner Version 4.x or higher
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
        © AppSphere AG

    .Parameter MailboxId
        Specifies the Alias, Display name, Distinguished name, SamAccountName, Guid or user principal name of the mailbox from which to set out of office

    .Parameter InternalText
        Specifies the Automatic Replies message that's sent to internal senders or senders within the organization

    .Parameter AutoReplyType 
        Specifies whether Automatic Replies are sent to external senders.

    .Parameter ExternalText 
        Specifies the Automatic Replies message that's sent to external senders or senders outside the organization

    .Parameter StartDay
        Specifies the start day that Automatic Replies are sent for the specified mailbox. (1-31)

    .Parameter StartMonth
        Specifies the start month that Automatic Replies are sent for the specified mailbox. (1-12)

    .Parameter StartYear
        Specifies the start year that Automatic Replies are sent for the specified mailbox. (2017-2020)

    .Parameter StartHour
        Specifies the start hour that Automatic Replies are sent for the specified mailbox. (0-23)

    .Parameter StartMinute
        Specifies the start minute that Automatic Replies are sent for the specified mailbox. (0-59)

    .Parameter EndDay
        Specifies the end day that Automatic Replies are sent for the specified mailbox. (1-31)

    .Parameter EndMonth
        Specifies the end month that Automatic Replies are sent for the specified mailbox. (1-12)

    .Parameter EndYear
        Specifies the end year that Automatic Replies are sent for the specified mailbox. (2017-2020)

    .Parameter EndHour
        Specifies the end hour that Automatic Replies are sent for the specified mailbox. (0-23)

    .Parameter EndMinute
        Specifies the end minute that Automatic Replies are sent for the specified mailbox. (0-59)
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName="Disable Auto Reply")]
    [Parameter(Mandatory = $true,ParameterSetName="Enable Auto Reply")]
    [Parameter(Mandatory = $true,ParameterSetName="Schedule Auto Reply")]
    [string]$MailboxId ,
    [Parameter(Mandatory = $true,ParameterSetName="Enable Auto Reply")]
    [Parameter(Mandatory = $true,ParameterSetName="Schedule Auto Reply")]
    [string]$InternalText,
    [Parameter(ParameterSetName="Enable Auto Reply")]
    [Parameter(ParameterSetName="Schedule Auto Reply")]
    [ValidateSet("All","Only contact list members","Internal only")]
    [string]$AutoReplyType="All",
    [Parameter(ParameterSetName="Enable Auto Reply")]
    [Parameter(ParameterSetName="Schedule Auto Reply")]
    [string]$ExternalText ,
    [Parameter(Mandatory = $true,ParameterSetName="Schedule Auto Reply")]
    [ValidateRange(1,31)]
    [int]$StartDay=1,
    [Parameter(Mandatory = $true,ParameterSetName="Schedule Auto Reply")]
    [ValidateRange(1,12)]
    [int]$StartMonth=1,
    [Parameter(Mandatory = $true,ParameterSetName="Schedule Auto Reply")]
    [ValidateRange(2017,2030)]
    [int]$StartYear=2017,
    [Parameter(Mandatory = $true,ParameterSetName="Schedule Auto Reply")]
    [ValidateRange(0,23)]
    [int]$StartHour=0,
    [Parameter(Mandatory = $true,ParameterSetName="Schedule Auto Reply")]
    [ValidateRange(0,59)]
    [int]$StartMinute=0,
    [Parameter(Mandatory = $true,ParameterSetName="Schedule Auto Reply")]
    [ValidateRange(1,31)]
    [int]$EndDay=1,
    [Parameter(Mandatory = $true,ParameterSetName="Schedule Auto Reply")]
    [ValidateRange(1,12)]
    [int]$EndMonth=1,
    [Parameter(Mandatory = $true,ParameterSetName="Schedule Auto Reply")]
    [ValidateRange(2017,2030)]
    [int]$EndYear=2017,
    [Parameter(Mandatory = $true,ParameterSetName="Schedule Auto Reply")]
    [ValidateRange(0,23)]
    [int]$EndHour=0,
    [Parameter(Mandatory = $true,ParameterSetName="Schedule Auto Reply")]
    [ValidateRange(0,59)]
    [int]$EndMinute=0
)

#Clear
    try{
        $box = Get-Mailbox -Identity $MailboxId
        if($null -ne $box){
            $resultMessage = @()
            if($PSCmdlet.ParameterSetName  -eq "Disable Auto Reply"){
                Set-MailboxAutoReplyConfiguration -Identity $box.UserPrincipalName -AutoReplyState Disabled -Confirm:$false
                $resultMessage += Get-MailboxAutoReplyConfiguration -Identity $box.UserPrincipalName | Select-object * | Format-List
                $resultMessage += "Mailbox $($box.UserPrincipalName) disabled"
            }
            else {
                $type = 'All'
                if($AutoReplyType -eq 'Only contact list members'){
                    $type = 'Known'
                }
                if($AutoReplyType -eq 'Internal only'){
                    $type = 'None'
                }
                if(($type -eq 'All') -or ($type -eq 'Known')){
                if([System.String]::IsNullOrWhiteSpace($ExternalText)){
                    $ExternalText=$InternalText
                }
                }
                if($PSCmdlet.ParameterSetName  -eq "Schedule Auto Reply"){
                    [datetime]$start = New-Object DateTime $StartYear, $StartMonth, $StartDay, $StartHour, $StartMinute, 0
                    if($start.ToFileTimeUtc() -lt [DateTime]::Now.ToFileTimeUtc()){
                        $start =[DateTime]::Now
                    }
                    [datetime]$end = $start
                    if($EndYear -gt 0){
                        $end = New-Object DateTime $EndYear, $EndMonth, $EndDay, $EndHour, $EndMinute, 0
                    }
                    if($end.ToFileTimeUtc() -lt [DateTime]::Now.ToFileTimeUtc()){
                        $end =$start.AddDays(1)
                    }
                    Set-MailboxAutoReplyConfiguration -Identity $box.UserPrincipalName -AutoReplyState 'Scheduled' -Confirm:$false -ExternalAudience $type `
                        -InternalMessage $InternalText -ExternalMessage $ExternalText -EndTime $end -StartTime $start
                    $resultMessage += Get-MailboxAutoReplyConfiguration -Identity $box.UserPrincipalName | Select-object * | Format-List
                    $resultMessage += "Mailbox $($box.UserPrincipalName) scheduled"
                }
                else {
                    Set-MailboxAutoReplyConfiguration -Identity $box.UserPrincipalName -AutoReplyState 'Enabled' -Confirm:$false -ExternalAudience $type `
                        -InternalMessage $InternalText -ExternalMessage $ExternalText 
                    $resultMessage += Get-MailboxAutoReplyConfiguration -Identity $box.UserPrincipalName | Select-object * | Format-List
                    $resultMessage += "Mailbox $($box.UserPrincipalName) enabled"
                }          
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
                $SRXEnv.ResultMessage = "Mailbox $($MailboxId) not found"
            } 
            Throw "Mailbox $($MailboxId) not found"
        }
    }
    finally{
     
    }