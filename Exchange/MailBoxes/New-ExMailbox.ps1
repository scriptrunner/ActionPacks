#Requires -Version 4.0

<#
    .SYNOPSIS
        Connect to Microsoft Exchange Server and create the mailbox
        Only parameters with value are set
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT       
        ScriptRunner Version 4.2.x or higher

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/Exchange/MailBoxes

    .Parameter Name
        Specifies the unique name of the mailbox. The maximum length is 64 characters.
    
    .Parameter UserPrincipalName
        Specifies the logon name for the user account

    .Parameter Password
        Specifies the password for the mailbox 

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
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [Parameter(Mandatory = $true)]
    [string]$UserPrincipalName,
    [Parameter(Mandatory = $true)]
    [securestring]$Password,
    [string]$Alias,
    [string]$DisplayName ,    
    [string]$WindowsEmailAddress ,
    [string]$FirstName ,
    [string]$LastName ,
    [string]$Office ,
    [string]$Phone ,
    [switch]$ResetPasswordOnNextLogon
)

try{
    $box = New-Mailbox -Name $Name -UserPrincipalName $UserPrincipalName -Password $Password -ResetPasswordOnNextLogon:$ResetPasswordOnNextLogon  -Force -Confirm:$false
    if($null -ne $box){
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                                'Identity' = $box.UserPrincipalName
                                'Confirm' = $false
                                }
        if($PSBoundParameters.ContainsKey('Alias') -eq $true ){
            Set-Mailbox @cmdArgs -Alias $Alias
        }
        if($PSBoundParameters.ContainsKey('DisplayName') -eq $true ){
            Set-Mailbox @cmdArgs -DisplayName $DisplayName
        }
        if($PSBoundParameters.ContainsKey('FirstName') -eq $true ){
            Set-User @cmdArgs -FirstName $FirstName
        }
        if($PSBoundParameters.ContainsKey('LastName') -eq $true ){
            Set-User @cmdArgs -LastName $LastName
        }
        if($PSBoundParameters.ContainsKey('Office') -eq $true ){
            Set-User @cmdArgs -Office $Office
        }
        if($PSBoundParameters.ContainsKey('Phone') -eq $true ){
            Set-User @cmdArgs -Phone $Phone
        }
        if($PSBoundParameters.ContainsKey('WindowsEmailAddress') -eq $true ){
            Set-Mailbox @cmdArgs -WindowsEmailAddress $WindowsEmailAddress
        }
        $resultMessage = @()
        $resultMessage += Get-Mailbox -Identity $box.UserPrincipalName | `
                Select-Object AccountDisabled,Alias,DisplayName,Name,WindowsEmailAddress, `
                            ResetPasswordOnNextLogon,UserPrincipalName         
        $resultMessage += Get-User -Identity $box.UserPrincipalName | `
                Select-Object FirstName,LastName,Office,Phone                                         
        if($SRXEnv) {
            $SRXEnv.ResultMessage = $resultMessage  
        }
        else{
            Write-Output $resultMessage
        }
    }
}
catch{
    throw
}
finally{
    
}