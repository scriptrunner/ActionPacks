#Requires -Version 5.0
#Requires -Modules AzureAD

<#
    .SYNOPSIS
        Gets the users from the group
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/AzureAD/Query

    .Parameter GroupObjectId
        [sr-en] Unique ID of the group from which to get members
        [sr-de] Gruppen Id
#>

param(
    [Parameter(Mandatory = $true)]
    [guid]$GroupObjectId
)

try{
    $members = Get-AzureADGroupMember -ObjectId $GroupObjectId | Where-Object {$_.ObjectType -eq 'User'} | `
                Sort-Object -Property DisplayName

    foreach($usr in $members){
        if($null -ne $SRXEnv) {
            $SRXEnv.ResultList.Add($usr.ObjectId)
            $SRXEnv.ResultList2.Add($usr.DisplayName)
        } 
        else{
            Write-Output $usr.DisplayName
        }
    }
}
catch{
    throw
}
finally{
}