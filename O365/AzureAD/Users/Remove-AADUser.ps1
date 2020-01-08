#Requires -Version 4.0
#Requires -Modules AzureAD

<#
    .SYNOPSIS
        Connect to Azure Active Directory and removes the user
    
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
        ScriptRunner Version 4.x or higher

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/AzureAD/Users

    .Parameter UserObjectId
        Specifies the unique object ID of the user to remove

    .Parameter UserName
        Specifies the Display name or user principal name of the user to remove
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = "User object id")]
    [guid]$UserObjectId,
    [Parameter(Mandatory = $true,ParameterSetName = "User name")]
    [string]$UserName
)

try{
    $Script:User
    if($PSCmdlet.ParameterSetName  -eq "User object id"){
        $Script:User = Get-AzureADUser -ObjectId $UserObjectId | Select-Object ObjectID,DisplayName
    }
    else{
        $Script:User = Get-AzureADUser -All $true | `
        Where-Object {($_.DisplayName -eq $UserName) -or ($_.UserPrincipalName -eq $UserName)} | `
            Select-Object ObjectID,DisplayName
    }
    if($null -ne $Script:User){
        $null = Remove-AzureADUser -ObjectId $Script:User.ObjectID -ErrorAction Stop
        if($SRXEnv) {
            $SRXEnv.ResultMessage ="User $($Script:User.DisplayName) removed"
        }
        else {
            Write-Output "User $($Script:User.DisplayName) removed"
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