#Requires -Version 4.0
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
        ScriptRunner Version 4.2.x or higher

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/Skype4Business/Online

    .Parameter SFBCredential
        Credential object containing the Skype for Business user/password

    .Parameter Identity
        Specifies the identity of the target user

    .Parameter ExpandLocation
        Displays the location parameter with its value

    .Parameter CivicAddressId
        Specifies the identity of the civic address that is assigned to the target users

    .Parameter EnterpriseVoiceStatus        

    .Parameter GetFromAAD
        Get the users from Azure Active Directory
    
    .Parameter GetPendingUsers
        Get only the users in pending state

    .Parameter LocationId
        Specifies the location identity of the location whose users will be returned

    .Parameter NumberAssigned
        Return users who have a phone number assigned

    .Parameter NumberNotAssigned
        Return users who do not have a phone number assigned

    .Parameter PSTNConnectivity

    .Parameter Skip
        Specifies the number of users to skip
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