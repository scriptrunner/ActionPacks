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
        https://github.com/scriptrunner/ActionPacks/tree/master/Exchange/_REPORTS_ 

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
        $Script:Members += [PSCustomObject]@{
            'Object type' = 'Group';
            'Name' = $group.DisplayName;
            'Primary Smtp Address' = $group.PrimarySmtpAddress
        }
        if(($MemberObjectTypes -eq 'All' ) -or ($MemberObjectTypes -eq 'Users')){
            Get-DistributionGroupMember -Identity $group.Name  | Where-Object {$_.RecipientType -EQ 'MailUser' -or $_.RecipientType -EQ 'UserMailbox'} | `
                Sort-Object -Property DisplayName | ForEach-Object{
                    $Script:Members += [PSCustomObject]@{
                        'Object type' = 'Mailbox';
                        'Name' = $_.DisplayName;
                        'Primary Smtp Address' = $_.PrimarySmtpAddress
                    }
                }
        }
        if(($MemberObjectTypes -eq 'All' ) -or ($MemberObjectTypes -eq 'Groups')){
            Get-DistributionGroupMember -Identity $group.Name  | Where-Object {$_.RecipientType -EQ 'MailUniversalDistributionGroup'} | `
                Sort-Object -Property DisplayName | ForEach-Object{
                    if($Nested -eq $true){
                        Get-NestedGroupMember $_
                    }
                    else {
                        $Script:Members += [PSCustomObject]@{
                            'Object type' = 'Group';
                            'Name' = $_.DisplayName;
                            'Primary Smtp Address' = $_.PrimarySmtpAddress
                        }
                    }                
                }
        }
    }

    $Grp = Get-DistributionGroup -Identity $GroupName -ErrorAction Stop
    Get-NestedGroupMember $Grp    
    
    ConvertTo-ResultHtml -Result $Script:Members
}
catch{
    throw
}
Finally{

}