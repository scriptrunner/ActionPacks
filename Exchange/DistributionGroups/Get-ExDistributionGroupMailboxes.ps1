#Requires -Version 4.0

<#
    .SYNOPSIS
        Connect to Microsoft Exchange Server and gets the Mailboxes from the Universal distribution group
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/Exchange/DistributionGroups

    .Parameter GroupName
        Specifies the Name, Alias, Display name, Distinguished name, Guid or Mail address of the Universal distribution group from which to get the mailboxes
    
    .Parameter Nested
        Shows group members nested 
    
    .Parameter MemberObjectTypes
        Specifies the member object types
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$GroupName,
    [switch]$Nested,
    [ValidateSet('All','Users', 'Groups')]
    [string]$MemberObjectTypes='All'
)

try{
    $Script:Members=@()
    function Get-NestedGroupMember($group) { 
        $Script:Members += "Group: $($group.DisplayName), $($group.PrimarySmtpAddress)" 
        if(($MemberObjectTypes -eq 'All' ) -or ($MemberObjectTypes -eq 'Users')){
            Get-DistributionGroupMember -Identity $group.Name  | Where-Object {$_.RecipientType -EQ 'MailUser' -or $_.RecipientType -EQ 'UserMailbox'} | `
                Sort-Object -Property DisplayName | ForEach-Object{
                    $Script:Members += "Mailbox: $($_.DisplayName), $($_.PrimarySmtpAddress)"
                }
        }
        if(($MemberObjectTypes -eq 'All' ) -or ($MemberObjectTypes -eq 'Groups')){
            Get-DistributionGroupMember -Identity $group.Name  | Where-Object {$_.RecipientType -EQ 'MailUniversalDistributionGroup'} | `
                Sort-Object -Property DisplayName | ForEach-Object{
                    if($Nested -eq $true){
                        Get-NestedGroupMember $_
                    }
                    else {
                        $Script:Members += "Group: $($_.DisplayName), $($_.PrimarySmtpAddress)"
                    }                
                }
        }
    }
    $Grp = Get-DistributionGroup -Identity $GroupName
    if($null -ne $Grp){
        Get-NestedGroupMember $Grp
    }
    else {
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "Universal distribution group not found"
        } 
        Throw "Universal distribution group not found"
    }

    if($null -ne $Script:Members){
        if($SRXEnv) {
            $SRXEnv.ResultMessage = $Script:Members
        } 
        else{
            Write-Output $Script:Members 
        }
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
Finally{

}