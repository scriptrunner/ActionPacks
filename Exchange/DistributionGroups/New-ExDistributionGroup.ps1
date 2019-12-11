#Requires -Version 4.0

<#
    .SYNOPSIS
        Connect to Microsoft Exchange Server and create Universal distribution group or mail-enabled security group
    
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
        Specifies the unique name of the group. The maximum length is 64 characters
    
    .Parameter PrimarySmtpAddress
        Specifies the primary return email address that's used for the recipient

    .Parameter ManagedBy
        Specifies specifies an owner for the group. You can use the Alias, Display name, Distinguished name, Guid or Mail address that uniquely identifies the group owner

    .Parameter Alias
        Specifies the Exchange alias (also known as the mail nickname) for the recipient
    
    .Parameter DisplayName
        Specifies the display name of the group

    .Parameter Note
        Specifies additional information about the object

    .Parameter Members
        Specifies the recipients (mail-enabled objects) that are members of the group. 
        You can use the Alias, Display name, Distinguished name, Guid or Mail address that uniquely identifies the recipient
    
    .Parameter MemberDepartRestriction
        Specifies the restrictions that you put on requests to leave the group

    .Parameter MemberJoinRestriction 
        Specifies the restrictions that you put on requests to join the group

    .Parameter GroupType
        Specifies the type of group that you want to create.
        Distribution = A distribution group
        Security = A mail-enabled security group
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$GroupName,
    [string]$PrimarySmtpAddress ,
    [Parameter(Mandatory = $true)]
    [string]$ManagedBy,
    [string]$Alias,
    [string]$DisplayName,
    [string]$Note,
    [string[]]$Members,
    [ValidateSet('Open','Closed')]
    [string]$MemberDepartRestriction='Open',
    [ValidateSet('ApprovalRequired','Open','Closed')]
    [string]$MemberJoinRestriction='Closed',
    [ValidateSet('Distribution','Security')]
    [string]$GroupType='Distribution'
)

$Script:result = @()
try{
    $Script:err =$false
    $Script:grp
    $Script:usr
    try{
        $Script:grp = New-DistributionGroup -Name $GroupName -Alias $Alias -DisplayName $DisplayName -Note $Note -ManagedBy $ManagedBy -Type $GroupType `
                        -PrimarySmtpAddress $PrimarySmtpAddress -MemberDepartRestriction $MemberDepartRestriction -MemberJoinRestriction $MemberJoinRestriction `
                        -Confirm:$false -ErrorAction Stop
        $Script:result += "Group: $($Script:grp.DisplayName) created"
        if($null -ne $Script:grp -and $null -ne $Members){
            forEach($itm in $Members){
                try{
                    $Script:usr = Get-Mailbox -Identity $itm -ErrorAction Stop
                }
                catch{
                    $Script:result += "Error: Member $($itm) $($_.Exception.Message)"
                    $Script:err =$true
                    continue
                }
                if($null -ne $Script:usr){
                    try{
                        Add-DistributionGroupMember -Identity $Script:grp.DistinguishedName -Member $itm -BypassSecurityGroupManagerCheck -Confirm:$false -ErrorAction Stop
                        $Script:result += "Member $($Script:usr.DisplayName) added to Distribution group $($grp.DisplayName)"
                    }
                    catch{
                        $Script:result += "Error: UserID $($itm) $($_.Exception.Message)"
                        $Script:err =$true
                        continue
                    }
                }
            }
        }
        $Script:result += $Script:grp
    }
    catch{
        $Script:result += "Error: $($_.Exception.Message)"
        $Script:err =$true
        continue
    }
}
catch{
    throw
}
Finally{
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:result
        if($Script:err -eq $true){
            Throw $($Script:result -join ' ')
        }
    } 
    else{    
        Write-Output $Script:result 
    }
    
}