#Requires -Version 5.0
#Requires -Modules SkypeOnlineConnector

<#
    .SYNOPSIS
        Retrieve a voice user's telephone number and location
    
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

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/Skype4Business/Online

    .Parameter SFBCredential
        [sr-en] Credential object containing the Skype for Business user/password

    .Parameter Identity
        [sr-en] the identity of the target user

    .Parameter ExpandLocation
        [sr-en] Displays the location parameter with its value

    .Parameter CivicAddressId
        [sr-en] Identity of the civic address that is assigned to the target users

    .Parameter EnterpriseVoiceStatus    
        [sr-en] Find enabled users based on EnterpriseVoiceEnabled    

    .Parameter GetFromAAD
        [sr-en] Get the users from Azure Active Directory
    
    .Parameter GetPendingUsers
        [sr-en] Get only the users in pending state

    .Parameter LocationId
        [sr-en] Location identity of the location whose users will be returned

    .Parameter NumberAssigned
        [sr-en] Return users who have a phone number assigned

    .Parameter NumberNotAssigned
        [sr-en] Return users who do not have a phone number assigned

    .Parameter PSTNConnectivity
        [sr-en] Find enabled users with PhoneSystem (OnPremises) or CallingPlan (Online)

    .Parameter Skip
        [sr-en] Number of users to skip
#>

param(    
    [Parameter(Mandatory = $true)]
    [PSCredential]$SFBCredential, 
    [Parameter(Mandatory = $true)]
    [string]$Identity, 
    [ValidateSet('All', 'Enabled','Disabled')]
    [string]$EnterpriseVoiceStatus,
    [switch]$ExpandLocation,
    [string]$CivicAddressId,
    [int]$First,
    [switch]$GetFromAAD,
    [switch]$GetPendingUsers,
    [string]$LocationId,
    [switch]$NumberAssigned,
    [switch]$NumberNotAssigned,
    [ValidateSet('All', 'Online','OnPremises')]
    [string]$PSTNConnectivity,
    [int]$Skip
)

Import-Module SkypeOnlineConnector

try{
    ConnectS4B -S4BCredential $SFBCredential

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Identity' = $Identity
                            'ExpandLocation' = $ExpandLocation
                            'Force' = $true
                            'NumberNotAssigned' = $NumberNotAssigned
                            'NumberAssigned' = $NumberAssigned
                            'GetFromAAD' = $GetFromAAD
                            'GetPendingUsers' = $GetPendingUsers
                            }  
    if([System.String]::IsNullOrWhiteSpace($EnterpriseVoiceStatus) -eq $false){
        $cmdArgs.Add('EnterpriseVoiceStatus',$EnterpriseVoiceStatus)
    }     
    if([System.String]::IsNullOrWhiteSpace($CivicAddressId) -eq $false){
        $cmdArgs.Add('CivicAddressId',$CivicAddressId)
    }      
    if([System.String]::IsNullOrWhiteSpace($LocationId) -eq $false){
        $cmdArgs.Add('LocationId',$LocationId)
    }    
    if([System.String]::IsNullOrWhiteSpace($PSTNConnectivity) -eq $false){
        $cmdArgs.Add('PSTNConnectivity',$PSTNConnectivity)
    } 
    if($First -gt 0){
        $cmdArgs.Add('First',$First)
    }     
    if($Skip -gt 0){
        $cmdArgs.Add('Skip',$Skip)
    }    

    $result = Get-CsOnlineVoiceUser @cmdArgs | Select-Object *

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