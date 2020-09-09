#Requires -Version 5.0
#Requires -Modules SkypeOnlineConnector

<#
    .SYNOPSIS
        Generates a report with the status of sip domains in the Office 365 tenant
    
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
        Requires Library Script ReportLibrary from the Action Pack Reporting\_LIB_

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/Skype4Business/_REPORTS_

    .Parameter SFBCredential
        [sr-en] Credential object containing the Skype for Business user/password
        [sr-de] Benutzername und Passwort für die Anmeldung

    .Parameter Domain
        [sr-en] A specific domain to get the status of
        [sr-de] Domänennamen

    .Parameter DomainStatus
        [sr-en] This indicates the status of an online sip domain, which can be either enabled or disabled
        [sr-de] Status der Online-Sip-Domain
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
    [string[]]$Properties = @('PSComputerName','RunspaceId','PSShowComputerName','Capacity','Count','IsFixedSize','IsReadOnly','IsSynchronized')
    ConnectS4B -S4BCredential $SFBCredential

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}  
    if([System.String]::IsNullOrWhiteSpace($Domain) -eq $false){
        $cmdArgs.Add('Domain',$Domain)
    }     
    if([System.String]::IsNullOrWhiteSpace($DomainStatus) -eq $false){
        $cmdArgs.Add('DomainStatus',$DomainStatus)
    }      
    $result = Get-CsOnlineSipDomain @cmdArgs | Select-Object $Properties

    if($SRXEnv) {
        ConvertTo-ResultHtml -Result $result    
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