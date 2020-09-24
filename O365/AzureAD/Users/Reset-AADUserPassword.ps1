#Requires -Version 4.0
#Requires -Modules AzureAD

<#
    .SYNOPSIS
        Connect to Azure Active Directory and resets the password from the user
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT       
        Azure Active Directory Powershell Module v2
        ScriptRunner Version 4.2.x or higher

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/AzureAD/Users

    .Parameter UserObjectId
        [sr-en] Specifies the unique ID of the user for which to set the password
        [sr-de] Die eindeutige ID des Benutzers dessen Passwort gesetzt werden soll

    .Parameter UserName
        [sr-en] Specifies the Display name or user principal name of the user for which to set the password
        [sr-de] Anzeigename oder UPN des Benutzers dessen Passwort gesetzt werden soll

    .Parameter NewPassword
        [sr-en] Specifies a new password for the user
        [sr-de] Das neue Passwort

    .Parameter ForceChangePasswordNextLogin
        [sr-en] Forces a user to change their password during their next log in
        [sr-de] Benutzer muss beim nächsten Anmelden das Passwort ändern
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = "User object id")]
    [guid]$UserObjectId,
    [Parameter(Mandatory = $true,ParameterSetName = "User name")]
    [string]$UserName,
    [Parameter(ParameterSetName = "User name")]
    [Parameter(ParameterSetName = "User object id")]
    [securestring]$NewPassword,
    [Parameter(ParameterSetName = "User name")]
    [Parameter(ParameterSetName = "User object id")]
    [bool]$ForceChangePasswordNextLogin
)

try{
    $Script:User 

    if($PSCmdlet.ParameterSetName  -eq "User object id"){
        $Script:User = Get-AzureADUser -ObjectId $UserObjectId -ErrorAction Stop  | Select-Object *
    }
    else{
        $Script:User = Get-AzureADUser -All $true -ErrorAction Stop  | `
            Where-Object {($_.DisplayName -eq $UserName) -or ($_.UserPrincipalName -eq $UserName)} | `
            Select-Object *
    }
    if($null -ne $Script:User){
        $res=@()
        if($PSBoundParameters.ContainsKey('ForceChangePasswordNextLogin') -eq $true ){
            $null = Set-AzureADUserPassword -ObjectId $Script:User.ObjectID -Password $NewPassword -ForceChangePasswordNextLogin $ForceChangePasswordNextLogin -ErrorAction Stop
            $res = "New password of user $($Script:User.DisplayName) is set. "
            $res += "User must change the password next time they sign in = $($ForceChangePasswordNextLogin)"
        }
        else {
            $null = Set-AzureADUserPassword -ObjectId $Script:User.ObjectID -Password $NewPassword -ErrorAction Stop
            $res = "New password of user $($Script:User.DisplayName) is set"
        }
        if($SRXEnv) {
            $SRXEnv.ResultMessage =$res
        }
        else {
            Write-Output $res
        }
    }
    else{
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "User not found"
        }    
        Throw "User not found"
    }
}
catch{
    throw
}
finally{
 
}