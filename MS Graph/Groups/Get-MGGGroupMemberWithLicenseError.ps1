#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Groups

<#
    .SYNOPSIS
        Returns group members with license errors
    
    .DESCRIPTION          

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Modules Microsoft.Graph.Groups

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/MS%20Graph/Groups

    .Parameter GroupId
        [sr-en] Group identifier
        [sr-de] Gruppen ID

    .Parameter ResultType
        [sr-en] Type of the result
        [sr-de] Ergebnistyp
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$GroupId,
    [Validateset('AsApplication','AsDevice','AsGroup','AsOrgContact','AsServicePrincipal','AsUser')]
    [string]$ResultType
)

Import-Module Microsoft.Graph.Groups

try{
    $mships = $null
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'    
                        'GroupId'= $GroupId
                        'All' = $null
    }
    switch ($ResultType){
        'AsApplication'{
            $mships = Get-MgGroupMemberWithLicenseErrorAsApplication @cmdArgs | Select-Object *
        }
        'AsDevice'{
            $mships = Get-MgGroupMemberWithLicenseErrorAsDevice @cmdArgs | Select-Object *
        }
        'AsGroup'{
            $mships = Get-MgGroupMemberWithLicenseErrorAsGroup @cmdArgs | Select-Object *
        }
        'AsOrgContact'{
            $mships = Get-MgGroupMemberWithLicenseErrorAsOrgContact @cmdArgs | Select-Object *
        }
        'AsServicePrincipal'{
            $mships = Get-MgGroupMemberWithLicenseErrorAsServicePrincipal @cmdArgs | Select-Object *
        }
        'AsUser'{
            $mships = Get-MgGroupMemberWithLicenseErrorAsUser @cmdArgs | Select-Object *
        }
        default{
            $mships = Get-MgGroupMemberWithLicenseError @cmdArgs | Select-Object *
        }
    }
    [PSCustomObject]$result = @()
    # memberships
    foreach($itm in $mships){
        [PSCustomObject]$ship = [PSCustomObject] @{DisplayName='';MailNickname='';Type=''}
        if($itm.AdditionalProperties.ContainsKey('@odata.type')){
            $ship.Type = $itm.AdditionalProperties.Item('@odata.type').Replace('#microsoft.graph.','')
        }
        if($itm.AdditionalProperties.ContainsKey('displayName')){
            $ship.DisplayName = $itm.AdditionalProperties.displayName
        }
        if($itm.AdditionalProperties.ContainsKey('mailNickname')){
            $ship.MailNickname = $itm.AdditionalProperties.mailnickname
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