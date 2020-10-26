#Requires -Version 5.0

<#
    .SYNOPSIS
        Connect to Exchange Online and removes mails from mailbox

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
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/ExchangeOnline/MailBoxes

    .Parameter O365Account
        [sr-en] Specifies a account that has permission to perform this action
        [sr-de] Benutzerkonto zur Ausführung der Aktion

    .Parameter MailboxId
        [sr-en] Specifies the user principal name of the mailbox
        [sr-de] UPN der Mailbox

    .Parameter RemoveOlderDay
        [sr-en] Deletes all mails older than X days
        [sr-de] Löscht alle Mails, die älter als X Tage sind

    .Parameter RemoveOlderThan
        [sr-en] Deletes all mails up to this date
        [sr-de] Löscht alle Mails, bis zu diesem Zeitpunkt

    .Parameter PurgeType
        [sr-en] Specifies how to remove items
        [sr-de] Gibt an, ob Mails endgültig gelöscht werden 
#>

param(
    [Parameter(Mandatory = $true)]
    [pscredential]$O365Account,
    [Parameter(Mandatory = $true)]
    [string]$MailboxId,
    [int]$RemoveOlderDay = 90,
    [Parameter(HelpMessage="ASRDisplay(Date)")]
    [datetime]$RemoveOlderThan,
    [ValidateSet('SoftDelete','HardDelete')]
    [string]$PurgeType = 'SoftDelete' 
)
 
try{
    $Script:result = $null
    $compSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.compliance.protection.outlook.com/powershell-liveid/ -Credential $O365Account -Authentication Basic -AllowRedirection
    $null = Import-PSSession $compSession -AllowClobber
    
    if($null -eq $RemoveOlderThan){
        $RemoveOlderThan = (Get-Date).AddDays(-$RemoveOlderDay)
    }

    [string]$searchName = 'SRPurgeSearch'
    try{
        if($null -ne (Get-ComplianceSearch  -Identity $searchName -ErrorAction SilentlyContinue)){
            $null = Remove-ComplianceSearch -Identity $searchName -Confirm:$false -ErrorAction SilentlyContinue
        }
        $null = New-ComplianceSearch -Name $searchName -ExchangeLocation $MailboxId -ContentMatchQuery "Received<$($RemoveOlderThan.ToString('yyyy-MM-dd'))(c:c)(ItemClass=IPM.Note)"
        $job = Start-ComplianceSearch -Identity $searchName -AsJob
        try{
            while($job.State -eq 'Running'){ # wait until job is finished            
                Start-Sleep -Seconds 1
            }
            if($job.State -eq 'Completed'){ 
                Start-Sleep -Seconds 5 # to be on the safe side
                $res = (Get-ComplianceSearch -Identity $searchName | Select-Object -ExpandProperty Items)
                if($res -gt 0){ # remove mails
                    $sAct = New-ComplianceSearchAction -SearchName $searchName -Purge -PurgeType $PurgeType -Force -Confirm:$false | Select-Object -ExpandProperty Status
                    try{
                        while(($sAct -eq 'Starting') -or ($sAct -eq 'InProgress')){ # wait until job is finished            
                            Start-Sleep -Seconds 1
                            $sAct = (Get-ComplianceSearchAction -Identity "$($searchName)_Purge" | Select-Object -ExpandProperty Status)
                        }
                        if($sAct -eq 'Completed'){ # mails removed
                            $Script:result = Get-ComplianceSearchAction -Identity "$($searchName)_Purge" | Select-Object -ExpandProperty Results
                        }
                        else{
                            throw "Search action failed"
                        }
                    }
                    finally{
                        $null = Remove-ComplianceSearchAction -Identity "$($searchName)_Purge" -Confirm:$false -ErrorAction SilentlyContinue
                    }
                }
                else{
                    $Script:result = 'No mails to delete found'
                }
            }
            else{
                throw "Search mails failed"
            }
        }
        finally{
            $null = Remove-ComplianceSearch -Identity $searchName -Confirm:$false -ErrorAction SilentlyContinue
        }
    }
    finally{
        $null = Remove-PSSession -Session $compSession -Confirm:$false
    }

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:result
    } 
    else{
        Write-Output $Script:result
    }
}
catch{
    throw
}
finally{

}