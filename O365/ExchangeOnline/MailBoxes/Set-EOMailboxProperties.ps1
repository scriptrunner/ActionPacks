#Requires -Version 4.0

<#
    .SYNOPSIS
        Connect to Exchange Online and and sets the mailbox properties
        Only parameters with value are set
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
        © AppSphere AG

    .COMPONENT       
        ScriptRunner Version 4.x or higher

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/ExchangeOnline/MailBoxes

    .Parameter MailboxId
        Specifies the Alias, Display name, Distinguished name, SamAccountName, Guid or user principal name of the mailbox from which to set properties
    
    .Parameter Alias
        Specifies the alias name of the resource

    .Parameter DisplayName
        Specifies the display name of the resource

    .Parameter WindowsEmailAddress
        Specifies the windows mail address of the mailbox

    .Parameter FirstName
        Specifies the user's first name

    .Parameter LastName
        Specifies the user's last name

    .Parameter Office
        Specifies the user's physical office name or number

    .Parameter Phone
        Specifies the user's telephone number

    .Parameter ResetPasswordOnNextLogon
        Specifies whether the user is required to change their password the next time they log on to their mailbox    

    .Parameter AccountDisabled
        Specifies whether to disable the account that's associated with the resource 
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$MailboxId,    
    [string]$UserPrincipalName ,
    [string]$Alias,
    [string]$DisplayName ,    
    [string]$WindowsEmailAddress ,
    [string]$FirstName ,
    [string]$LastName ,
    [string]$Office ,
    [string]$Phone ,
    [switch]$ResetPasswordOnNextLogon,
    [switch]$AccountDisabled
)

#Clear
#$ErrorActionPreference='Stop'

try{
        $box = Get-Mailbox -Identity $MailboxId 
        if($null -ne $box){
            if($PSBoundParameters.ContainsKey('AccountDisabled') -eq $true ){
                Set-Mailbox -Identity $box.UserPrincipalName -AccountDisabled $AccountDisabled.ToBool() -Confirm:$false
            }
            if($PSBoundParameters.ContainsKey('Alias') -eq $true ){
                Set-Mailbox -Identity $box.UserPrincipalName -Alias $Alias -Confirm:$false
            }
            if($PSBoundParameters.ContainsKey('DisplayName') -eq $true ){
                Set-Mailbox -Identity $box.UserPrincipalName -DisplayName $DisplayName -Confirm:$false
            }
            if($PSBoundParameters.ContainsKey('FirstName') -eq $true ){
                Set-User -Identity $box.UserPrincipalName -FirstName $FirstName -Confirm:$false
            }
            if($PSBoundParameters.ContainsKey('LastName') -eq $true ){
                Set-User -Identity $box.UserPrincipalName -LastName $LastName -Confirm:$false
            }
            if($PSBoundParameters.ContainsKey('Office') -eq $true ){
                Set-User -Identity $box.UserPrincipalName -Office  $Office -Confirm:$false
            }
            if($PSBoundParameters.ContainsKey('Phone') -eq $true ){
                Set-User -Identity $box.UserPrincipalName -Phone $Phone -Confirm:$false
            }
            if($PSBoundParameters.ContainsKey('WindowsEmailAddress') -eq $true ){
                Set-Mailbox -Identity $box.UserPrincipalName -WindowsEmailAddress $WindowsEmailAddress -Confirm:$false
            }
            if($PSBoundParameters.ContainsKey('ResetPasswordOnNextLogon') -eq $true ){
                Set-User -Identity $box.UserPrincipalName -ResetPasswordOnNextLogon  $ResetPasswordOnNextLogon.ToBool() -Confirm:$false
            }
            $resultMessage = @()
            $resultMessage += Get-Mailbox -Identity $box.Name | `
                    Select-Object AccountDisabled,Alias,DisplayName,Name,FirstName,LastName,Office,Phone,WindowsEmailAddress, `
                                  ResetPasswordOnNextLogon,UserPrincipalName              
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
finally{
    
}