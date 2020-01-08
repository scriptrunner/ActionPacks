#Requires -Version 4.0
#Requires -Modules AzureAD

<#
    .SYNOPSIS
        Connect to  Azure Active Directory and gets a list of users
    
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

    .Parameter SearchString
        Specifies a search string
#>

param(
    [string]$SearchString
)
 
try{
    $Script:result = @()
    $Script:Users = Get-AzureADUser -All $true -SearchString $SearchString | `
        Select-Object DisplayName, ObjectID,UserPrincipalName,AccountEnabled -Unique | Sort-Object -Property DisplayName
    if($null -ne $Script:Users){
        foreach($usr in $Script:Users){
            $Script:result += $usr
        }
        if($SRXEnv) {
            $SRXEnv.ResultMessage = $Script:result | Format-List
        } 
        else{
            Write-Output $Script:result | Format-List
        }
    }
    else{
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "No users found"
        }
        else{
            Write-Output "No users found"
        }
    }
}
finally{
 
}