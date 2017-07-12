#Requires -Modules MSOnline

<#
    .SYNOPSIS
        Connect to MS Online and sets user can log on Azure Active Directory
        Requirements 
        64-bit OS for all Modules 
        Microsoft Online Sign-In Assistant for IT Professionals  
        Azure Active Diretory Powershell Module v1
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
        © AppSphere AG

    .Parameter O365Account
        Specifies the credential to use to connect to Azure Active Directory

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
<#   
    [Parameter(Mandatory = $true,ParameterSetName = "User name")]
    [Parameter(Mandatory = $true,ParameterSetName = "User object id")]
    [PSCredential]$O365Account,    
#>
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
 
# Import-Module MSOnline

#Clear

$ErrorActionPreference='Stop'

# Connect-MsolService -Credential $O365Account 

if($PSCmdlet.ParameterSetName  -eq "User object id"){
    $Script:Usr = Get-MsolUser -ObjectId $UserObjectId -TenantId $TenantId  | Select-Object ObjectID
}
else{
    $Script:Usr = Get-MsolUser -TenantId $TenantId | `
    Where-Object {($_.DisplayName -eq $UserName) -or ($_.SignInName -eq $UserName) -or ($_.UserPrincipalName -eq $UserName)} | `
    Select-Object ObjectID,DisplayName
}
if($null -ne $Script:Usr){
    Set-MsolUser -ObjectId $Script:Usr.ObjectId -BlockCredential (-not $Enabled) -TenantId $TenantId 
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
    Write-Error  "User not found"
}