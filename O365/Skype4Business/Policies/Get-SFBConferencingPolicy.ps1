#Requires -Version 4.0
#Requires -Modules SkypeOnlineConnector

<#
    .SYNOPSIS
        Returns information about the conferencing policies that have been configured for use in your organization
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/Skype4Business/Policies

    .Parameter SFBCredential
        Credential object containing the Skype for Business user/password

    .Parameter Identity
        Unique identifier for the conferencing policy to be retrieved

    .Parameter LocalStore
        Retrieves the conferencing policy data from the local replica of the Central Management store rather than from the Central Management store itself

    .Parameter TenantID
        Unique identifier for the tenant
#>

param(    
    [Parameter(Mandatory = $true)]
    [PSCredential]$SFBCredential,  
    [string]$Identity,
    [ValidateSet('Automatic','All','SubscriptionDefaults','TenantDefinedOnly')]
    [string]$Include,
    [switch]$LocalStore,
    [string]$TenantID
)

Import-Module SkypeOnlineConnector

try{
    ConnectS4B -S4BCredential $SFBCredential

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'LocalStore' =$LocalStore
                            }      
    if([System.String]::IsNullOrWhiteSpace($Identity) -eq $false){
        $cmdArgs.Add('Identity',$Identity)
    } 
    if([System.String]::IsNullOrWhiteSpace($Include) -eq $false){
        $cmdArgs.Add('Include',$Include)
    } 
    if([System.String]::IsNullOrWhiteSpace($TenantID) -eq $false){
        $cmdArgs.Add('Tenant',$TenantID)
    }    

    $result = Get-CsConferencingPolicy @cmdArgs | Select-Object *

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