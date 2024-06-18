#Requires -Version 5.0
#Requires -Modules AzureAD

<#
    .SYNOPSIS
        Connect to Azure Active Directory and enables/disables user
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT       
        Azure Active Directory Powershell Module

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/AzureAD/Users

    .Parameter UserObjectId
        [sr-en] Unique ID of the user from which to get properties

    .Parameter UserName
        [sr-en] Display name or user principal name of the user from which to set status

    .Parameter Enabled
        [sr-en] Account is enabled
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = "User object id")]
    [guid]$UserObjectId,
    [Parameter(Mandatory = $true,ParameterSetName = "User name")]
    [string]$UserName,
    [Parameter(Mandatory = $true,ParameterSetName = "User name")]
    [Parameter(Mandatory = $true,ParameterSetName = "User object id")]    
    [bool]$Enabled
)

try{
    if($PSCmdlet.ParameterSetName  -eq "User object id"){
        $Script:Usr = Get-AzureADUser -ObjectId $UserObjectId | Select-Object ObjectID,DisplayName
    }
    else{
        $Script:Usr = Get-AzureADUser -All $true | `
            Where-Object {($_.DisplayName -eq $UserName) -or ($_.UserPrincipalName -eq $UserName)} | `
            Select-Object ObjectID,DisplayName
    }
    if($null -ne $Script:Usr){
        $null = Set-AzureADUser -ObjectId $Script:Usr.ObjectId -AccountEnabled $Enabled
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "User $($Script:Usr.DisplayName) enabled status is $($Enabled.toString())"
        } 
        else{
            Write-Output "User $($Script:Usr.DisplayName) enabled status is $($Enabled.toString())"
        }
    }
    else{
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "User not found"
        }
        Throw  "User not found"
    }
}
finally{
  
}    