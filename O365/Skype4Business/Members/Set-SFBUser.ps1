#Requires -Version 4.0
#Requires -Modules SkypeOnlineConnector

<#
    .SYNOPSIS
        Modifies Skype for Business properties for an existing user account
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module SkypeOnlineConnector
        Requires Library script SFBLibrary.ps1
        ScriptRunner Version 4.2.x or higher

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/Skype4Business/Members

    .Parameter SFBCredential
        Credential object containing the Skype for Business user/password

    .Parameter User
        Indicates the Identity of the user account to be modified. User Identities can be specified using one of four formats: 
        1) the user's SIP address; 
        2) the user's user principal name (UPN); 
        3) the user's domain name and logon name, in the form domain\logon 
        4) the user's Active Directory display name 

    .Parameter AudioVideoDisabled
        Indicates whether the user is allowed to make audio/visual (A/V) calls by using Skype for Business
    
    .Parameter EnterpriseVoiceEnabled
        Indicates whether the user has been enabled for Enterprise Voice

    .Parameter HostedVoiceMail
        Enables a user's voice mail calls to be routed to a hosted version of Microsoft Exchange Server

    .Parameter LineURI
        Phone number assigned to the user

    .Parameter OnPremLineURI
        Specifies the phone number assigned to the user if no number is assigned to that user in the Skype for Business hybrid environment

    .Parameter PrivateLine
        Phone number for the user's private telephone line

    .Parameter RemoteCallControlTelephonyEnabled
        Indicates whether the user has been enabled for remote call control telephony

    .Parameter ExchangeArchivingPolicy
        Indicates where the user's instant messaging sessions are archived.
#>

param(    
    [Parameter(Mandatory = $true)]
    [PSCredential]$SFBCredential, 
    [Parameter(Mandatory = $true)] 
    [string]$User,
    [bool]$AudioVideoDisabled
<#    [bool]$EnterpriseVoiceEnabled,
    [bool]$HostedVoiceMail,
    [string]$LineURI,
    [string]$OnPremLineURI,
    [string]$PrivateLine,
    [bool]$RemoteCallControlTelephonyEnabled,
    [ValidateSet('Uninitialized','UseLyncArchivingPolicy','ArchivingToExchange','NoArchiving')]
    [string]$ExchangeArchivingPolicy
#>
)

Import-Module SkypeOnlineConnector

try{
    ConnectS4B -S4BCredential $SFBCredential

    [string]$Properties = @('Alias','DisplayName','Enabled','IsValid','SipAddress','ObjectID')

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Confirm' = $false
                            'Identity' = $User
                            }      

    if($PSBoundParameters.ContainsKey('AudioVideoDisabled') -eq $true){
        $cmdArgs.Add('AudioVideoDisabled',$AudioVideoDisabled)
        $Properties += 'AudioVideoDisabled'
    }  
    # https://docs.microsoft.com/en-us/skypeforbusiness/set-up-your-computer-for-windows-powershell/manage-user-accounts-using-the-online-connector    
<#     if($PSBoundParameters.ContainsKey('HostedVoiceMail') -eq $true){
        $cmdArgs.Add('HostedVoiceMail',$HostedVoiceMail)
        $Properties += 'HostedVoiceMail'
    } 
    if($PSBoundParameters.ContainsKey('ExchangeArchivingPolicy') -eq $true){
        $cmdArgs.Add('ExchangeArchivingPolicy',$ExchangeArchivingPolicy)
        $Properties += 'ExchangeArchivingPolicy'
    } 
    if([System.String]::IsNullOrWhiteSpace($OnPremLineURI) -eq $false){
        $cmdArgs.Add('OnPremLineURI',$OnPremLineURI)
        $Properties += 'OnPremLineURI'
    }   
    if($PSBoundParameters.ContainsKey('EnterpriseVoiceEnabled') -eq $true){
        $cmdArgs.Add('EnterpriseVoiceEnabled',$EnterpriseVoiceEnabled)
        $Properties += 'EnterpriseVoiceEnabled'
    }  
    if($PSBoundParameters.ContainsKey('RemoteCallControlTelephonyEnabled') -eq $true){
        $cmdArgs.Add('RemoteCallControlTelephonyEnabled',$RemoteCallControlTelephonyEnabled)
        $Properties += 'RemoteCallControlTelephonyEnabled'
    }      
    if([System.String]::IsNullOrWhiteSpace($LineURI) -eq $false){
        $cmdArgs.Add('LineURI',$LineURI)
        $Properties += 'LineURI'
    } 
    if([System.String]::IsNullOrWhiteSpace($PrivateLine) -eq $false){
        $cmdArgs.Add('PrivateLine',$PrivateLine)
        $Properties += 'PrivateLine'
    }    #>
    
    $result = Set-CsUser @cmdArgs 
    $result = Get-CsOnlineUser -Identity $User -ErrorAction Stop | Select-Object $Properties

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $result
    }
    else {
        Write-Output $result 
    }    
}
catch{
    throw
}
finally{
    DisconnectS4B
}