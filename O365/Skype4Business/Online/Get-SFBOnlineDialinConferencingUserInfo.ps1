#Requires -Version 4.0
#Requires -Modules SkypeOnlineConnector

<#
    .SYNOPSIS
        Returns the properties and settings of users that are enabled for dial-in conferencing and are using Microsoft or third-party provider as their PSTN conferencing provider
    
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
        Specifies the user to retrieve

    .Parameter Select
        Filter the output

    .Parameter Skip
        Skips (does not select) the specified number of items

    .Parameter SortDescending
        Indicates that the cmdlet sorts the objects in descending order

    .Parameter First
        Returns the first X number of users from the list of all the users enabled for dial-in conferencing

    .Parameter TenantID
        Unique identifier for the tenant
#>

param(    
    [Parameter(Mandatory = $true)]
    [PSCredential]$SFBCredential,  
    [string]$Identity,
    [ValidateSet('DialInConferencingOn','DialInConferencingOff','ConferencingProviderMS','ConferencingProviderOther','ReadyForMigrationToCPC','NoFilter')]
    [string]$Select,
    [int]$Skip,
    [switch]$SortDescending,
    [int]$First,
    [string]$TenantID
)

Import-Module SkypeOnlineConnector

try{
    ConnectS4B -S4BCredential $SFBCredential

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Force' = $true
                            'SortDescending' = $SortDescending
                            }      
    if([System.String]::IsNullOrWhiteSpace($Identity) -eq $false){
        $cmdArgs.Add('Identity',$Identity)
    } 
    if([System.String]::IsNullOrWhiteSpace($Select) -eq $false){
        $cmdArgs.Add('Select',$Select)
    }   
    if([System.String]::IsNullOrWhiteSpace($TenantID) -eq $false){
        $cmdArgs.Add('Tenant',$TenantID)
    }   
    if($Skip -gt 0){
        $cmdArgs.Add('Skip',$Skip)
    }  
    if($First -gt 0){
        $cmdArgs.Add('First',$First)
    }    

    $result = Get-CsOnlineDialInConferencingUserInfo @cmdArgs | Select-Object *

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