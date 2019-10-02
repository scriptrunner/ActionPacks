#Requires -Version 4.0

<#
    .SYNOPSIS
        Connect to Microsoft Exchange Server and and sets the mailbox quotas
    
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
        Specifies the Alias, Display name, Distinguished name, SamAccountName, Guid or user principal name of the mailbox from which to set properties
    
    .Parameter Unit
        Specifies the units

    .Parameter UseDatabaseQuotaDefaults
        Specifies the alias name of the mailbox

    .Parameter ProhibitSendQuota
        Specifies a size limit for new messages on the mailbox. 
        The value must be less than or equal to the ProhibitSendReceiveQuota value

    .Parameter ProhibitSendReceiveQuota
        Specifies a size limit for send or receive new messages on the mailbox. 
        The value must be greater than or equal to the ProhibitSendQuota or IssueWarningQuota values

    .Parameter RecoverableItemsQuota
        Specifies the maximum size for the Recoverable Items folder of the mailbox

    .Parameter RecoverableItemsWarningQuota
        Specifies the warning threshold for the size of the Recoverable Items folder for the mailbox

    .Parameter IssueWarningQuota
        Specifies the warning threshold for the size of the mailbox

    .Parameter CalendarLoggingQuota 
        Specifies the maximum size of the log in the Recoverable Items folder of the mailbox that stores changes to calendar items
        
    .Parameter ArchiveQuota
        Specifies the maximum size for the user's archive mailbox

    .Parameter ArchiveWarningQuota 
        Specifies the warning threshold for the size of the user's archive mailbox
        
    .Parameter RulesQuota
        Specifies the limit for the size of Inbox rules for the mailbox (in bytes)
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$MailboxId,  
    [ValidateSet('MB','GB')]  
    [string]$Unit = 'GB',
    [bool]$UseDatabaseQuotaDefaults = $false,
    [ValidateRange(0, [double]::MaxValue)]
    [double]$ProhibitSendQuota ,    
    [ValidateRange(0, [double]::MaxValue)]
    [double]$ProhibitSendReceiveQuota,
    [ValidateRange(0, [double]::MaxValue)]
    [double]$RecoverableItemsQuota,
    [ValidateRange(0, [double]::MaxValue)]
    [double]$RecoverableItemsWarningQuota,
    [ValidateRange(0, [double]::MaxValue)]
    [double]$ArchiveQuota,
    [ValidateRange(0, [double]::MaxValue)]
    [double]$ArchiveWarningQuota,
    [ValidateRange(0, [double]::MaxValue)]
    [double]$CalendarLoggingQuota,
    [ValidateRange(0, [double]::MaxValue)]
    [double]$IssueWarningQuota,
    [int]$RulesQuota
)

try{
    [uint64]$Script:setSize
    $Script:sizeUnit = '1GB'
    if($Unit -eq "MB"){
        $Script:sizeUnit = '1MB'
    }
    if(($ProhibitSendQuota -gt 0) -and ($ProhibitSendReceiveQuota -gt 0)){
        if($ProhibitSendQuota -gt $ProhibitSendReceiveQuota){
            $ProhibitSendQuota = $ProhibitSendReceiveQuota
        }
    }
    if(($RecoverableItemsQuota -gt 0) -and ($RecoverableItemsWarningQuota -gt 0)){
        if($RecoverableItemsWarningQuota -gt $RecoverableItemsQuota){
            $RecoverableItemsWarningQuota = $RecoverableItemsQuota
        }
    }
    if(($ArchiveQuota -gt 0) -and ($ArchiveWarningQuota -gt 0)){
        if($ArchiveWarningQuota -gt $ArchiveQuota){
            $ArchiveWarningQuota = $ArchiveQuota
        }
    }
    if(($CalendarLoggingQuota -gt 0) -and ($RecoverableItemsQuota -gt 0)){
        if($CalendarLoggingQuota -gt $RecoverableItemsQuota){
            $CalendarLoggingQuota = $RecoverableItemsQuota
        }
    }
    if(($IssueWarningQuota -gt 0) -and ($ProhibitSendReceiveQuota -gt 0)){
        if($IssueWarningQuota -gt $ProhibitSendReceiveQuota){
            $IssueWarningQuota = $ProhibitSendReceiveQuota
        }
    }
    $box = Get-Mailbox -Identity $MailboxId 
    if($null -ne $box){
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                                'Identity' = $box.UserPrincipalName
                                'Confirm' = $false
                                'Force' = $null
                                'UseDatabaseQuotaDefaults' = $UseDatabaseQuotaDefaults
                                }
        if($UseDatabaseQuotaDefaults -eq $true)
        {                        
            Set-Mailbox @cmdArgs
        }
        else{
            if($ProhibitSendReceiveQuota -gt 0 ){
                $Script:setSize = [math]::Round($ProhibitSendReceiveQuota * $Script:sizeUnit,0)
                Set-Mailbox @cmdArgs -ProhibitSendReceiveQuota $Script:setSize
            }
            if($ProhibitSendQuota -gt 0 ){
                $Script:setSize = [math]::Round($ProhibitSendQuota * $Script:sizeUnit,0)
                Set-Mailbox @cmdArgs -ProhibitSendQuota $Script:setSize
            }
            if($RecoverableItemsQuota -gt 0 ){
                $Script:setSize = [math]::Round($RecoverableItemsQuota * $Script:sizeUnit,0)
                Set-Mailbox @cmdArgs -RecoverableItemsQuota $Script:setSize
            }
            if($RecoverableItemsWarningQuota -gt 0 ){
                $Script:setSize = [math]::Round($RecoverableItemsWarningQuota * $Script:sizeUnit,0)
                Set-Mailbox @cmdArgs -RecoverableItemsWarningQuota $Script:setSize
            }
            if($ArchiveQuota -gt 0 ){
                $Script:setSize = [math]::Round($ArchiveQuota * $Script:sizeUnit,0)
                Set-Mailbox @cmdArgs -ArchiveQuota $Script:setSize
            }
            if($ArchiveWarningQuota -gt 0 ){
                $Script:setSize = [math]::Round($ArchiveWarningQuota * $Script:sizeUnit,0)
                Set-Mailbox @cmdArgs -ArchiveWarningQuota $Script:setSize
            }
            if($CalendarLoggingQuota -gt 0 ){
                $Script:setSize = [math]::Round($CalendarLoggingQuota * $Script:sizeUnit,0)
                Set-Mailbox @cmdArgs -CalendarLoggingQuota $Script:setSize
            }
            if($IssueWarningQuota -gt 0 ){
                $Script:setSize = [math]::Round($IssueWarningQuota * $Script:sizeUnit,0)
                Set-Mailbox @cmdArgs -IssueWarningQuota $Script:setSize
            }
            if($RulesQuota -gt 0 ){
                Set-Mailbox @cmdArgs -RulesQuota $RulesQuota
            }
        }
        $resultMessage = @()
        $resultMessage += Get-Mailbox -Identity $box.UserPrincipalName | `
                Select-Object @('UseDatabaseQuotaDefaults','ProhibitSendQuota','ProhibitSendReceiveQuota', `
                                'RecoverableItemsQuota','RecoverableItemsWarningQuota','CalendarLoggingQuota', `
                                'IssueWarningQuota','RulesQuota','ArchiveQuota','ArchiveWarningQuota')       
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
        Throw  "Mailbox $($MailboxId) not found"
    }
}
catch{
    throw
}
finally{
    
}