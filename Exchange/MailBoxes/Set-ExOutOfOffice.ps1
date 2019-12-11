#Requires -Version 4.0

<#
    .SYNOPSIS
        Connect to Microsoft Exchange Server and enable or disable Automatic Replies for a specified mailbox
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/Exchange/MailBoxes

    .Parameter MailboxId
        Specifies the Alias, Display name, Distinguished name, SamAccountName, Guid or user principal name of the mailbox from which to set out of office

    .Parameter InternalText
        Specifies the Automatic Replies message that's sent to internal senders or senders within the organization

    .Parameter AutoReplyType 
        Specifies whether Automatic Replies are sent to external senders.

    .Parameter ExternalText 
        Specifies the Automatic Replies message that's sent to external senders or senders outside the organization

    .Parameter StartDate
        Specifies the start date that Automatic Replies are sent for the specified mailbox

    .Parameter EndDate
        Specifies the end date that Automatic Replies are sent for the specified mailbox
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName="Disable Auto Reply")]
    [Parameter(Mandatory = $true,ParameterSetName="Enable Auto Reply")]
    [Parameter(Mandatory = $true,ParameterSetName="Schedule Auto Reply")]
    [string]$MailboxId ,
    [Parameter(Mandatory = $true,ParameterSetName="Enable Auto Reply",HelpMessage="ASRDisplay(Multiline)")]
    [Parameter(Mandatory = $true,ParameterSetName="Schedule Auto Reply",HelpMessage="ASRDisplay(Multiline)")]
    [string]$InternalText,
    [Parameter(ParameterSetName="Enable Auto Reply")]
    [Parameter(ParameterSetName="Schedule Auto Reply")]
    [ValidateSet("All","Only contact list members","Internal only")]
    [string]$AutoReplyType="All",
    [Parameter(ParameterSetName="Enable Auto Reply",HelpMessage="ASRDisplay(Multiline)")]
    [Parameter(ParameterSetName="Schedule Auto Reply",HelpMessage="ASRDisplay(Multiline)")]
    [string]$ExternalText ,
    [Parameter(Mandatory = $true,ParameterSetName="Schedule Auto Reply")]
    [datetime]$StartDate,
    [Parameter(Mandatory = $true,ParameterSetName="Schedule Auto Reply")]
    [datetime]$EndDate
)

try{
    $box = Get-Mailbox -Identity $MailboxId
    if($null -ne $box){
        $resultMessage = @()
        if($PSCmdlet.ParameterSetName  -eq "Disable Auto Reply"){
            Set-MailboxAutoReplyConfiguration -Identity $box.UserPrincipalName -AutoReplyState Disabled -Confirm:$false
            $resultMessage += Get-MailboxAutoReplyConfiguration -Identity $box.UserPrincipalName | Select-Object * | Format-List
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
            if([System.String]::IsNullOrWhiteSpace($InternalText) -eq $false){
                $InternalText = $InternalText.Replace("StartDate",$StartDate.ToShortDateString()).Replace("EndDate",$EndDate.ToShortDateString())                
            }
            if(($type -eq 'All') -or ($type -eq 'Known')){
                if([System.String]::IsNullOrWhiteSpace($ExternalText) -eq $true){
                    $ExternalText = $InternalText
                }
                else {
                    $ExternalText = $ExternalText.Replace("StartDate",$StartDate.ToShortDateString()).Replace("EndDate",$EndDate.ToShortDateString())                
                }
            }
            if($PSCmdlet.ParameterSetName  -eq "Schedule Auto Reply"){
                if($StartDate.ToFileTimeUtc() -lt [DateTime]::Now.ToFileTimeUtc()){
                    $StartDate =[DateTime]::Now
                }
                if(($null -eq $EndDate) -or ($EndDate.Year -lt 2000)){
                    $EndDate = $StartDate                    }
                if($EndDate.ToFileTimeUtc() -lt [DateTime]::Now.ToFileTimeUtc()){
                    $EndDate =$StartDate.AddDays(1)
                }
                Set-MailboxAutoReplyConfiguration -Identity $box.UserPrincipalName -AutoReplyState 'Scheduled' -Confirm:$false -ExternalAudience $type `
                    -InternalMessage $InternalText -ExternalMessage $ExternalText -EndTime $EndDate -StartTime $StartDate
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
catch{
    throw
}
finally{
    
}