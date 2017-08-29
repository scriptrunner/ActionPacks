#Requires -Modules AzureAD

<#
    .SYNOPSIS
        Connect to Azure Active Directory and gets the properties from the user
        Requirements 
        ScriptRunner Version 4.x or higher
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
        Specifies the unique ID of the user from which to get properties

    .Parameter UserName
        Specifies the Display name or user principal name of the user from which to get properties
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = "User object id")]
    [guid]$UserObjectId,
    [Parameter(Mandatory = $true,ParameterSetName = "User name")]
    [string]$UserName
)

try{
    $Script:result = @()
    $Script:Usr
    if($PSCmdlet.ParameterSetName  -eq "User object id"){
        $Script:Usr = Get-AzureADUser -ObjectId $UserObjectId | Select-Object *
    }
    else{
        $Script:Usr = Get-AzureADUser -All $true  | `
            Where-Object {($_.DisplayName -eq $UserName) -or ($_.UserPrincipalName -eq $UserName)} | `
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
        Throw "User not found"
    }
}
finally{
 
}