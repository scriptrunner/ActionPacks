#Requires -Version 4.0
#Requires -Modules MSOnline

<#
    .SYNOPSIS
        Connect to MS Online and sets user can log on Azure Active Directory
    
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
        Specifies the unique ID of the user from which to get properties

    .Parameter UserName
        Specifies the Display name, Sign-In Name or user principal name of the user from which to get properties

    .Parameter Enabled
        Specifies whether the user is able to log on using their user ID

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
    [switch]$Enabled,
    [Parameter(ParameterSetName = "User name")]
    [Parameter(ParameterSetName = "User object id")]    
    [guid]$TenantId
)
 
try{
    if($PSCmdlet.ParameterSetName  -eq "User object id"){
        $Script:Usr = Get-MsolUser -ObjectId $UserObjectId -TenantId $TenantId  | Select-Object ObjectID,DisplayName
    }
    else{
        $Script:Usr = Get-MsolUser -TenantId $TenantId | `
                            Where-Object {($_.DisplayName -eq $UserName) -or ($_.SignInName -eq $UserName) -or ($_.UserPrincipalName -eq $UserName)} | `
                            Select-Object ObjectID,DisplayName
    }
    if($null -ne $Script:Usr){
        $null = Set-MsolUser -ObjectId $Script:Usr.ObjectId -BlockCredential (-not $Enabled) -TenantId $TenantId 
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "User $($Script:Usr.DisplayName) lock on state set to $($Enabled.toString())"
        } 
        else{
            Write-Output "User $($Script:Usr.DisplayName) lock on state set to $($Enabled.toString())"
        }
    }
    else{
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "User not found"
        }
        Throw  "User not found"
    }
}
catch{
    throw
}