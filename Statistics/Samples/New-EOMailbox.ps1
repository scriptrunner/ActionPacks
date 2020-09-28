#Requires -Version 4.0

<#
    .SYNOPSIS
        Connect to Exchange Online and create mailbox and user account at the same time
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
        Requires the library script StatisticLib.ps1

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/Statistics/Samples

    .Parameter Name
        [sr-en] Specifies the unique name of the mailbox. The maximum length is 64 characters.
        [sr-de] Eindeutiger Name der Mailbox, max. 64 Zeichen
    
    .Parameter UserPrincipalName
        [sr-en] Specifies the logon name for the user account
        [sr-de] UPN des Benutzers

    .Parameter Password
        [sr-en] Specifies the password for the mailbox 
        [sr-de] Passwort der Mailbox

    .Parameter Alias
        [sr-en] Specifies the alias name of the resource
        [sr-de] Aliasname

    .Parameter DisplayName
        [sr-en] Specifies the display name of the resource
        [sr-de] Anzeigename

    .Parameter WindowsEmailAddress
        [sr-en] Specifies the windows mail address of the mailbox
        [sr-de] Windows Mailadresse

    .Parameter FirstName
        [sr-en] Specifies the user's first name
        [sr-de] Vorname

    .Parameter LastName
        [sr-en] Specifies the user's last name
        [sr-de] Nachname

    .Parameter Office
        [sr-en] Specifies the user's physical office name or number
        [sr-de] Büro

    .Parameter Phone
        [sr-en] Specifies the user's telephone number
        [sr-de] Telefonnummer

    .Parameter ResetPasswordOnNextLogon
        [sr-en] Specifies whether the user is required to change their password the next time they log on to their mailbox    
        [sr-de] Benutzer muss bei der nächsten Anmeldung das Passwort ändern

    .Parameter AccountDisabled
        [sr-en] Specifies whether to disable the account that's associated with the resource 
        [sr-de] Konto sperren

    .Parameter CostReduction
        [sr-en] Cost saving through execution per ScriptRunner, in seconds
        [sr-de] Zeitersparnis, in Sekunden
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [Parameter(Mandatory = $true)]
    [string]$UserPrincipalName ,
    [Parameter(Mandatory = $true)]
    [securestring]$Password,
    [string]$Alias,
    [string]$DisplayName ,    
    [string]$WindowsEmailAddress ,
    [string]$FirstName ,
    [string]$LastName ,
    [string]$Office ,
    [string]$Phone ,
    [switch]$ResetPasswordOnNextLogon,
    [int]$CostReduction = 900,
    [switch]$AccountDisabled
)

try{
    [string[]]$Properties = @('AccountDisabled','Alias','DisplayName','Name','FirstName','LastName','Office','Phone','WindowsEmailAddress','ResetPasswordOnNextLogon','UserPrincipalName')
    
    $box = New-Mailbox -Name $Name -MicrosoftOnlineServicesID $UserPrincipalName -Password $Password -ResetPasswordOnNextLogon:$ResetPasswordOnNextLogon -Force -Confirm:$false -ErrorAction Stop
    if($null -ne $box){
        if($PSBoundParameters.ContainsKey('AccountDisabled') -eq $true ){
            $null = Set-Mailbox -Identity $box.UserPrincipalName -AccountDisabled $AccountDisabled.ToBool() -Confirm:$false 
        }
        if($PSBoundParameters.ContainsKey('Alias') -eq $true ){
            $null = Set-Mailbox -Identity $box.UserPrincipalName -Alias $Alias -Confirm:$false
        }
        if($PSBoundParameters.ContainsKey('DisplayName') -eq $true ){
            $null = Set-Mailbox -Identity $box.UserPrincipalName -DisplayName $DisplayName -Confirm:$false
        }
        if($PSBoundParameters.ContainsKey('FirstName') -eq $true ){
            $null = Set-User -Identity $box.UserPrincipalName -FirstName $FirstName -Confirm:$false
        }
        if($PSBoundParameters.ContainsKey('LastName') -eq $true ){
            $null = Set-User -Identity $box.UserPrincipalName -LastName $LastName -Confirm:$false
        }
        if($PSBoundParameters.ContainsKey('Office') -eq $true ){
            $null = Set-User -Identity $box.UserPrincipalName -Office  $Office -Confirm:$false
        }
        if($PSBoundParameters.ContainsKey('Phone') -eq $true ){
            $null = Set-User -Identity $box.UserPrincipalName -Phone $Phone -Confirm:$false
        }
        if($PSBoundParameters.ContainsKey('WindowsEmailAddress') -eq $true ){
            $null = Set-Mailbox -Identity $box.UserPrincipalName -WindowsEmailAddress $WindowsEmailAddress -Confirm:$false
        }
        $resultMessage = Get-Mailbox -Identity $box.UserPrincipalName | Select-Object $Properties

        LogExecution -CostSavingsSeconds $CostReduction
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