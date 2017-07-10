#Requires -Modules MSOnline

<#
    .SYNOPSIS
        Connect to MS Online and gets the properties from Azure Active Directory user
        Requirements 
        64-bit OS for all Modules 
        Microsoft Online Sign-In Assistant for IT Professionals  
        Azure Active Diretory Powershell Module v1
    
    .DESCRIPTION                        

    .Parameter O365Account
        Specifies the credential to use to connect to Azure Active Directory

    .Parameter UserObjectId
        Specifies the unique ID of the user from which to get properties

    .Parameter UserName
        Specifies the Display name, Sign-In Name or user principal name of the user from which to get properties

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
    [guid]$TenantId
)
 
#Import-Module MSOnline

#Clear

$ErrorActionPreference='Stop'

#Connect-MsolService -Credential $O365Account 

$Script:result = @()
$Script:Usr
if($PSCmdlet.ParameterSetName  -eq "User object id"){
    $Script:Usr = Get-MsolUser -ObjectId $UserObjectId -TenantId $TenantId  | Select-Object *
}
else{
    $Script:Usr = Get-MsolUser -TenantId $TenantId | `
    Where-Object {($_.DisplayName -eq $UserName) -or ($_.SignInName -eq $UserName) -or ($_.UserPrincipalName -eq $UserName)} | `
    Select-Object *
}
if($null -ne $Script:Usr){
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:Usr
    } 
    else{
        Write-Output $Script:Usr 
    }
}
else{
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "User not found"
    }    
    Write-Error "User not found"
}