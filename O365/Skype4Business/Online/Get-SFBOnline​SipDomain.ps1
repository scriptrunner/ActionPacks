#Requires -Version 4.0
#Requires -Modules SkypeOnlineConnector

<#
    .SYNOPSIS
        Returns the status of sip domains in the Office 365 tenant
    
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

    .Parameter Domain
        A specific domain to get the status of

    .Parameter DomainStatus
        This indicates the status of an online sip domain, which can be either enabled or disabled.
#>

param(    
    [Parameter(Mandatory = $true)]
    [PSCredential]$SFBCredential, 
    [string]$Domain,
    [ValidateSet('All','Enabled','Disabled')]
    [string]$DomainStatus
)

Import-Module SkypeOnlineConnector

try{
    ConnectS4B -S4BCredential $SFBCredential

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}  
    if([System.String]::IsNullOrWhiteSpace($Domain) -eq $false){
        $cmdArgs.Add('Domain',$Domain)
    }     
    if([System.String]::IsNullOrWhiteSpace($DomainStatus) -eq $false){
        $cmdArgs.Add('DomainStatus',$DomainStatus)
    }      
    $result = Get-CsOnlineSipDomain @cmdArgs | Select-Object *

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