#Requires -Modules AzureAD

<#
    .SYNOPSIS
        Connect to Azure Active Directory and resets the password from the user
        ScriptRunner Version 4.x or higher
        Requirements 
        64-bit OS for all Modules 
        Microsoft Online Sign-In Assistant for IT Professionals  
        Azure Active Directory Powershell Module v2
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
        © AppSphere AG

    .Parameter UserObjectId
        Specifies the unique ID of the user for which to set the password

    .Parameter UserName
        Specifies the Display name or user principal name of the user for which to set the password

    .Parameter NewPassword
        Specifies a new password for the user

    .Parameter ForceChangePasswordNextLogin
        Forces a user to change their password during their next log in
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = "User object id")]
    [guid]$UserObjectId,
    [Parameter(Mandatory = $true,ParameterSetName = "User name")]
    [string]$UserName,
    [Parameter(ParameterSetName = "User name")]
    [Parameter(ParameterSetName = "User object id")]
    [string]$NewPassword,
    [Parameter(ParameterSetName = "User name")]
    [Parameter(ParameterSetName = "User object id")]
    [bool]$ForceChangePasswordNextLogin
)

try{
    $Script:User 

    if($PSCmdlet.ParameterSetName  -eq "User object id"){
        $Script:User = Get-AzureADUser -ObjectId $UserObjectId   | Select-Object *
    }
    else{
        $Script:User = Get-AzureADUser -All $true  | `
            Where-Object {($_.DisplayName -eq $UserName) -or ($_.UserPrincipalName -eq $UserName)} | `
            Select-Object *
    }
    if($null -ne $Script:User){
        $Script:NPwd = ConvertTo-SecureString $NewPassword -AsPlainText -Force
        $res=@()
        if($PSBoundParameters.ContainsKey('ForceChangePasswordNextLogin') -eq $true ){
            Set-AzureADUserPassword -ObjectId $Script:User.ObjectID -Password $Script:NPwd -ForceChangePasswordNextLogin $ForceChangePasswordNextLogin
            $res = "New password of user $($Script:User.DisplayName) is set. "
            $res += "User must change the password next time they sign in = $($ForceChangePasswordNextLogin)"
        }
        else {
            Set-AzureADUserPassword -ObjectId $Script:User.ObjectID -Password $Script:NPwd 
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
finally{
 
}