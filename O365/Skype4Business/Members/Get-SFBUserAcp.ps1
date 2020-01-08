#Requires -Version 4.0
#Requires -Modules SkypeOnlineConnector

<#
    .SYNOPSIS
        Returns information about the audio conferencing providers assigned to a user or group of users
    
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
        Indicates the Identity of the user account to be retrieved. User Identities can be specified using one of four formats: 
        1) the user's SIP address; 
        2) the user's user principal name (UPN); 
        3) the user's domain name and logon name, in the form domain\logon 
        4) the user's Active Directory display name 

    .Parameter Properties
        List of properties to expand. Use * for all properties
#>

param(    
    [Parameter(Mandatory = $true)]
    [PSCredential]$SFBCredential,  
    [string]$User,
    [int]$ResultSize = 50,
    [string]$Properties = 'Name,DistinguishedName,Identity,Guid,IsValid'
)

Import-Module SkypeOnlineConnector

try{
    ConnectS4B -S4BCredential $SFBCredential

    if([System.String]::IsNullOrWhiteSpace($Properties)){
        $Properties = '*'
    }
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}      
    if([System.String]::IsNullOrWhiteSpace($User) -eq $false){
        $cmdArgs.Add('Identity',$User)
    }    
    $result = Get-CsUserAcp @cmdArgs | Select-Object $Properties.Split(',')

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