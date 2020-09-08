#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Generates a report with external users in the tenant
    
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
        Requires Library Script ReportLibrary from the Action Pack Reporting\_LIB_

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/SharePointOnline/_REPORTS_

    .Parameter Filter
        [sr-en] Limits the results to only those users whose first name, last name, or email address 
        begins with the text in the string using a case-insensitive comparison
        [sr-de] Ergebnisse für nur diejenigen Benutzer, deren Vorname, Nachname oder e-Mail-Adresse 
        mit dem Text in der Zeichenfolge beginnt, ohne Berücksichtigung der Groß-/Kleinschreibung

    .Parameter PageSize
        [sr-en] Specifies the maximum number of users to be returned in the collection
        [sr-de] Maximale Anzahl der zurückzugebenden Benutzer 

    .Parameter Position
        [sr-en] Use to specify the zero-based index of the position in the sorted collection of the first result to be returned
        [sr-de] Nullbasierter Index des ersten zurückzugebenden Ergebnisses in der sortierten Auflistung

    .Parameter ShowOnlyUsersWithAcceptingAccountNotMatchInvitedAccount
        [sr-en] Shows users who have accepted an invite but not using the account the invite was sent to
        [sr-de] Benutzer, die eine Einladung akzeptiert haben, jedoch nicht das Konto verwenden, an das die Einladung gesendet wurde

    .Parameter SiteUrl
        [sr-en] Specifies the site to retrieve external users for
        [sr-de] Website zum Abrufen von externen Benutzern

    .Parameter SortOrder
        [sr-en] Specifies the sort results in Ascending or Descending order on the SPOUser.Email property should occur
        [sr-de] Sortierergebnisse in aufsteigender oder absteigender Reihenfolge
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
        ConvertTo-ResultHtml -Result $result    
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