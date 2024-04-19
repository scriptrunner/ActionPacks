#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Users

<#
    .SYNOPSIS
        Returns the memberships of the user
    
    .DESCRIPTION          

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Modules Microsoft.Graph.Users

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/MS%20Graph/Users

    .Parameter UserId
        [sr-en] User identifier
        [sr-de] Benutzer ID

    .PARAMETER Transitive
        [sr-en] Groups, including nested groups, and directory roles that a user is a member of
        [sr-de] Gruppen, einschließlich verschachtelter Gruppen, und Verzeichnisrollen, in denen ein Benutzer Mitglied ist
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$UserId,
    [switch]$Transitive
)

Import-Module Microsoft.Graph.Users

try{
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'    
                        'UserId'= $UserId
                        'All' = $null
    }
    if($Transitive.IsPresent -eq $true){
        $mships = Get-MgUserTransitiveMemberOf @cmdArgs | Select-Object *
    }
    else{
        $mships = Get-MgUserMemberOf @cmdArgs | Select-Object *
    }  

    [PSCustomObject]$result = @()
    # memberships
    foreach($itm in $mships){
        [PSCustomObject]$ship = [PSCustomObject] @{DisplayName='';Mail='';Type=''}
        if($itm.AdditionalProperties.ContainsKey('@odata.type')){
            $ship.Type = $itm.AdditionalProperties.Item('@odata.type').Replace('#microsoft.graph.','')
        }
        if($itm.AdditionalProperties.ContainsKey('displayName')){
            $ship.DisplayName = $itm.AdditionalProperties.displayName
        }
        if($itm.AdditionalProperties.ContainsKey('mail')){
            $ship.Mail = $itm.AdditionalProperties.mail
        }
        $result += $ship
    }
    $result = $result | Sort-Object DisplayName

    if (Get-Command 'ConvertTo-ResultHtml' -ErrorAction Ignore) {
        ConvertTo-ResultHtml -Result $result
    }
    if($null -ne $SRXEnv) {
        $SRXEnv.ResultMessage = $result
    }
    else{
        Write-Output $result
    }    
}
catch{
    throw 
}
finally{
}