#Requires -Version 4.0

<#
    .SYNOPSIS
        Connect to Exchange Online and enable or disable Automatic Replies for one or more specified mailboxes
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/ExchangeOnline/MailBoxes

    .Parameter MailboxIds
        [sr-en] Specifies the Aliases, Display names, Distinguished names, SamAccountNames, Guid or user principal names of the mailboxes from which to set out of office
        [sr-de] Alias, Anzeigename, Distinguished-Namen, SamAccount-Namen, Guids oder UPN der Mailboxen

    .Parameter InternalText
        [sr-en] Specifies the Automatic Replies message that's sent to internal senders or senders within the organization
        [sr-de] Text der automatischen Antwort an interne Absender

    .Parameter AutoReplyType 
        [sr-en] Specifies whether Automatic Replies are sent to external senders
        [sr-de] Automatische Antworten an externe Absender senden

    .Parameter ExternalText 
        [sr-en] Specifies the Automatic Replies message that's sent to external senders or senders outside the organization
        [sr-de] Text der automatischen Antwort an externe Absender

    .Parameter StartDate
        [sr-en] Specifies the start date that Automatic Replies are sent for the specified mailbox
        The text StartDate will be replaced by the defined start date
        [sr-de] Datum ab wann automatische Antworten verschickt werden.
        StartDate wird im Text der Antwort durch dieses Datum ersetzt

    .Parameter EndDate
        [sr-en] Specifies the end date that Automatic Replies are sent for the specified mailbox
        The text EndDate will be replaced by the defined end date
        [sr-de] Datum bis wann automatische Antworten verschickt werden.
        EndDate wird im Text der Antwort durch dieses Datum ersetzt

    .Parameter GenerateReport
        [sr-en] Generates a report with the current mailbox settings.        
        Requires Library Script ReportLibrary from the Action Pack Reporting\_LIB_
        [sr-de] Erstellt einen Report mit den aktuellen Einstellungen der Mailbox.        
        Erfordert das Library Script ReportLibrary aus dem Action Pack Reporting\_LIB_
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName="Disable Auto Reply")]
    [Parameter(Mandatory = $true,ParameterSetName="Enable Auto Reply")]
    [Parameter(Mandatory = $true,ParameterSetName="Schedule Auto Reply")]
    [string[]]$MailboxIds ,
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
    [datetime]$EndDate,
    [Parameter(ParameterSetName="Disable Auto Reply")]
    [Parameter(ParameterSetName="Enable Auto Reply")]
    [Parameter(ParameterSetName="Schedule Auto Reply")]
    [switch]$GenerateReport
)

try{
    [string[]]$Properties = @('Identity','AutoReplyState','StartTime','EndTime','ExternalAudience','IsValid')
    [string[]]$resultMessage = @()
    [string]$msg = "Mailbox {0} "
    [string]$replyType = 'All'

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Confirm' = $false
                            }

    if($PSCmdlet.ParameterSetName  -eq "Disable Auto Reply"){
        $cmdArgs.add('AutoReplyState' , 'Disabled')
        $msg += "disabled"
    }
    else{               
        if($AutoReplyType -eq 'Only contact list members'){
            $replyType = 'Known'
        }
        if($AutoReplyType -eq 'Internal only'){
            $replyType = 'None'
        }
        if($PSCmdlet.ParameterSetName -eq "Schedule Auto Reply"){
            if([System.String]::IsNullOrWhiteSpace($InternalText) -eq $false){
                $InternalText = $InternalText.Replace("StartDate",$StartDate.ToShortDateString()).Replace("EndDate",$EndDate.ToShortDateString())                
            }
            if($replyType -ne 'None'){
                if([System.String]::IsNullOrWhiteSpace($ExternalText) -eq $false){
                    $ExternalText = $ExternalText.Replace("StartDate",$StartDate.ToShortDateString()).Replace("EndDate",$EndDate.ToShortDateString())                
                }
            }
            if($StartDate.ToFileTimeUtc() -lt [DateTime]::Now.ToFileTimeUtc()){
                $StartDate =[DateTime]::Now
            }
            if(($null -eq $EndDate) -or ($EndDate.Year -lt 2020)){
                $EndDate = $StartDate           
            }
            if($EndDate.ToFileTimeUtc() -lt [DateTime]::Now.ToFileTimeUtc()){
                $EndDate =$StartDate.AddDays(1)
            }
        }
        if([System.String]::IsNullOrWhiteSpace($ExternalText) -eq $true){
            $ExternalText = $InternalText
        }
        $cmdArgs.Add('ExternalAudience', $replyType)
        $cmdArgs.Add('InternalMessage', $InternalText )
        $cmdArgs.Add('ExternalMessage', $ExternalText )
        if($PSCmdlet.ParameterSetName  -eq "Schedule Auto Reply"){
            $cmdArgs.Add('AutoReplyState', 'Scheduled')                
            $cmdArgs.Add('EndTime', $EndDate)
            $cmdArgs.Add('StartTime', $StartDate)
            $msg += "scheduled"
        }
        else{
            $cmdArgs.Add('AutoReplyState', 'Enabled')
            $msg += "enabled"
        }
    }    

    $Script:resHtml = @()
    foreach($item in $MailboxIds){
        try{
            $box = Get-Mailbox -Identity $item -ErrorAction Stop
            if($null -ne $box){
                try{
                    $null = Set-MailboxAutoReplyConfiguration @cmdArgs -Identity $box.UserPrincipalName
                    if($GenerateReport -eq $true){
                        $Script:resHtml += Get-MailboxAutoReplyConfiguration -Identity $box.UserPrincipalName | Select-Object $Properties
                    }
                    $resultMessage += [System.String]::Format($msg,$box.UserPrincipalName)
                }
                catch{
                    Write-Output "Error occurred at set Mailbox $($item)"
                }
            }
        }
        catch{
            Write-Output "Error occurred at get Mailbox $($item)"
        }
    }

    if($GenerateReport -eq $true){
        ConvertTo-ResultHtml -Result $Script:resHtml
    }
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $resultMessage 
    } 
    else{
        Write-Output $resultMessage 
    }
}
catch{
    throw
}
finally{
    
}