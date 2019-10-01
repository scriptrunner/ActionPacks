#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Returns external users in the tenant
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module Microsoft.Online.SharePoint.PowerShell
        ScriptRunner Version 4.2.x or higher

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/SharePointOnline/Users

    .Parameter Filter
        Limits the results to only those users whose first name, last name, or email address 
        begins with the text in the string using a case-insensitive comparison

    .Parameter PageSize
        Specifies the maximum number of users to be returned in the collection

    .Parameter Position
        Use to specify the zero-based index of the position in the sorted collection of the first result to be returned

    .Parameter ShowOnlyUsersWithAcceptingAccountNotMatchInvitedAccount
        Shows users who have accepted an invite but not using the account the invite was sent to

    .Parameter SiteUrl
        Specifies the site to retrieve external users for

    .Parameter SortOrder
        Specifies the sort results in Ascending or Descending order on the SPOUser.Email property should occur
#>

param(            
    [string]$Filter,
    [ValidateRange(1,50)]
    [int]$PageSize,
    [int]$Position,
    [bool]$ShowOnlyUsersWithAcceptingAccountNotMatchInvitedAccount,
    [string]$SiteUrl,
    [ValidateSet('Ascending','Descending')]
    [string]$SortOrder
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'ShowOnlyUsersWithAcceptingAccountNotMatchInvitedAccount' = $ShowOnlyUsersWithAcceptingAccountNotMatchInvitedAccount
                            }      
                            
    if($PSBoundParameters.ContainsKey('Filter')){
        $cmdArgs.Add('Filter',$Filter)
    }
    if($PSBoundParameters.ContainsKey('PageSize')){
        $cmdArgs.Add('PageSize',$PageSize)
    }
    if($PSBoundParameters.ContainsKey('Position')){
        $cmdArgs.Add('Position',$Position)
    }
    if($PSBoundParameters.ContainsKey('SiteUrl')){
        $cmdArgs.Add('SiteUrl',$SiteUrl)
    }
    if($PSBoundParameters.ContainsKey('SortOrder')){
        $cmdArgs.Add('SortOrder',$SortOrder)
    }
    
    $result = Get-SPOExternalUser @cmdArgs | Select-Object *
      
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $result
    }
    else {
        Write-Output $result 
    }    
}
catch{
    throw
}
finally{
}