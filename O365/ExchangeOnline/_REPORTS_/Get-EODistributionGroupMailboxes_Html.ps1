#Requires -Version 4.0

<#
    .SYNOPSIS
        Generates a report with the Mailboxes from the Universal distribution group
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT 
        Requires Library Script ReportLibrary from the Action Pack Reporting\_LIB_     

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/ExchangeOnline/_REPORTS_

    .Parameter GroupId
        [sr-en] Specifies the Alias, Display name, Distinguished name, Guid or Mail address of the Universal distribution group from which to get mailboxes
        [sr-de] Gibt den Alias, Anzeigenamen, Distinguished-Name, Guid oder die Mailadresse der Verteilergruppe oder der e-Mail-aktivierte Sicherheitsgruppe an

    .Parameter Nested
        [sr-en] Shows group members nested 
        [sr-de] Gruppenmitglieder rekursiv anzeigen
    
    .Parameter MemberObjectTypes
        [sr-en] Specifies the member object types
        [sr-de] Gruppen, Benutzer oder alle anzeigen
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$GroupId,
    [switch]$Nested,
    [ValidateSet('All','Users', 'Groups')]
    [string]$MemberObjectTypes='All'
)

try{
    $Script:Members=@()
    function Get-NestedGroupMember($group) { 
        $Script:Members += [PSCustomObject] @{Type = 'Group'
                                            DisplayName=$group.DisplayName
                                            'Smtp address' = $group.PrimarySmtpAddress}
                                            
        if(($MemberObjectTypes -eq 'All' ) -or ($MemberObjectTypes -eq 'Users')){
            Get-DistributionGroupMember -Identity $group.Name  | Where-Object {$_.RecipientType -EQ 'MailUser'} | `
                Sort-Object -Property DisplayName | ForEach-Object{                    
                    $Script:Members += [PSCustomObject] @{Type = 'Mailbox'
                                                DisplayName = $_.DisplayName
                                                'Smtp address' = $_.PrimarySmtpAddress}
                }
        }
        if(($MemberObjectTypes -eq 'All' ) -or ($MemberObjectTypes -eq 'Groups')){
            Get-DistributionGroupMember -Identity $group.Name  | Where-Object {$_.RecipientType -EQ 'MailUniversalDistributionGroup'} | `
                Sort-Object -Property DisplayName | ForEach-Object{
                    if($Nested -eq $true){
                        Get-NestedGroupMember $_
                    }
                    else {
                        $Script:Members += [PSCustomObject] @{Type = 'Group'
                                                DisplayName = $_.DisplayName
                                                'Smtp address' = $_.PrimarySmtpAddress}
                    }                
                }
        }
    }
    
    $Grp = Get-DistributionGroup -Identity $GroupId
    if($null -ne $Grp){
        Get-NestedGroupMember $Grp
    }
    else {
        Throw "Universal distribution group not found"
    }

    if($null -ne $Script:Members){
        ConvertTo-ResultHtml -Result $Script:Members 
    }
    else {
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "No Universal distribution group members found"
        } 
        else{
            Write-Output "No Universal distribution group members found"
        }
    }
}
catch{
    throw
}
finally{
    
}