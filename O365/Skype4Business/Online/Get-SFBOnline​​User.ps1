#Requires -Version 4.0
#Requires -Modules SkypeOnlineConnector

<#
    .SYNOPSIS
        Returns information about users who have accounts homed on Skype for Business Online
    
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
        Indicates the Identity of the user account to be retrieved

    .Parameter OnModernServer
        Returns a collection of users homed on Skype for Business

    .Parameter ResultSize
        Enables you to limit the number of records returned by the cmdlet

    .Parameter UnassignedUser
        Enables you to return a collection of all the users who have been enabled for Skype for Business but are not currently assigned to a Registrar pool
#>

param(    
    [Parameter(Mandatory = $true)]
    [PSCredential]$SFBCredential, 
    [string]$Identity,
    [switch]$OnModernServer,
    [int]$ResultSize,
    [switch]$UnassignedUser
)

Import-Module SkypeOnlineConnector

try{
    ConnectS4B -S4BCredential $SFBCredential

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'OnModernServer' = $OnModernServer
                            'UnassignedUser' = $UnassignedUser
                            }  
    if([System.String]::IsNullOrWhiteSpace($Identity) -eq $false){
        $cmdArgs.Add('Identity',$Identity)
    }    
    if($ResultSize -gt 0){
        $cmdArgs.Add('ResultSize',$ResultSize)
    }

    $result = Get-CsOnlineUser @cmdArgs | Select-Object *

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