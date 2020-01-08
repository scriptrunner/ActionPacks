#Requires -Version 4.0
#Requires -Modules MSOnline

<#
    .SYNOPSIS
        Connect to MS Online and resets the password from Azure Active Directory user
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT       
        Azure Active Directory Powershell Module v1
        ScriptRunner Version 4.x or higher

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/MSOnline/Users

    .Parameter UserObjectId
        Specifies the unique ID of the user for which to set the password

    .Parameter UserName
        Specifies the Display name, Sign-In Name or user principal name of the user for which to set the password

    .Parameter NewPassword
        Specifies a new password for the user

    .Parameter ForceChangePassword
        Indicates whether the user must change the password the next time they sign in

    .Parameter ForceChangePasswordOnly
        Sets only user must change the password on the next logon.
        The new password will be ignored

    .Parameter TenantId
        Specifies the unique ID of the tenant on which to perform the operation
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
    [switch]$ForceChangePassword,
    [Parameter(ParameterSetName = "User name")]
    [Parameter(ParameterSetName = "User object id")]
    [switch]$ForceChangePasswordOnly,
    [Parameter(ParameterSetName = "User name")]
    [Parameter(ParameterSetName = "User object id")]
    [guid]$TenantId
)

try{
    $Script:User 

    if($PSCmdlet.ParameterSetName  -eq "User object id"){
        $Script:User = Get-MsolUser -ObjectId $UserObjectId -TenantId $TenantId  | Select-Object *
    }
    else{
        $Script:User = Get-MsolUser -TenantId $TenantId | `
                                Where-Object {($_.DisplayName -eq $UserName) -or ($_.SignInName -eq $UserName) -or ($_.UserPrincipalName -eq $UserName)} | `
                                Select-Object *
    }
    if($null -ne $Script:User){
        $res=@()
        if($ForceChangePasswordOnly){
            $null = Set-MsolUserPassword -ObjectId $Script:User.ObjectID -ForceChangePasswordOnly $true -ForceChangePassword $true -TenantId $TenantId 
            $res = "User must change the password next time they sign in"
        }
        else {
            $null = Set-MsolUserPassword -ObjectId $Script:User.ObjectID -ForceChangePassword $ForceChangePassword.ToBool() -NewPassword $NewPassword -TenantId $TenantId 
            $res = "New password of user $($Script:User.DisplayName) is set. "
            if($ForceChangePassword){
                $res += "User must change the password next time they sign in."
            }
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