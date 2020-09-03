#Requires -Version 4.0
#Requires -Modules MSOnline

<#
    .SYNOPSIS
        Generates a report with the members from the Azure Active Directory group
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT       
        Azure Active Directory Powershell Module v1
        Requires Library Script ReportLibrary from the Action Pack Reporting\_LIB_

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/MSOnline/_REPORTS_

    .Parameter GroupObjectId
        [sr-en] Specifies the unique ID of the group from which to get members
        [sr-de] Gibt die eindeutige ID der Gruppe an

    .Parameter GroupName
        [sr-en] Specifies the display name of the group from which to get members
        [sr-de] Gibt den Namen der Gruppe an

    .Parameter Nested
        [sr-en] Shows group members nested 
        [sr-de] Gruppenmitglieder rekursiv anzeigen

    .Parameter MemberObjectTypes
        [sr-en] Specifies the member object types
        [sr-de] Gruppen, Benutzer oder alle anzeigen

    .Parameter TenantId
        [sr-en] Specifies the unique ID of a tenant
        [sr-de] Die eindeutige ID eines Mandanten
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = "Group object id")]
    [guid]$GroupObjectId,
    [Parameter(Mandatory = $true,ParameterSetName = "Group name")]
    [string]$GroupName,
    [Parameter(ParameterSetName = "Group name")]
    [Parameter(ParameterSetName = "Group object id")]
    [switch]$Nested,
    [Parameter(ParameterSetName = "Group name")]
    [Parameter(ParameterSetName = "Group object id")]
    [ValidateSet('All','Users', 'Groups')]
    [string]$MemberObjectTypes='All',
    [Parameter(ParameterSetName = "Group name")]
    [Parameter(ParameterSetName = "Group object id")]
    [guid]$TenantId
)

try{
    $Script:Members=@()

    function Get-NestedGroupMember($group) { 
        $Script:Members += [PSCustomObject] @{Type = 'Group';DisplayName = $group.DisplayName }
        if(($MemberObjectTypes -eq 'All' ) -or ($MemberObjectTypes -eq 'Users')){
            Get-MsolGroupMember -GroupObjectId $group.ObjectId -MemberObjectTypes 'User' -TenantId $TenantId | `
                Sort-Object -Property DisplayName | ForEach-Object{
                    $Script:Members += [PSCustomObject] @{Type = 'User';DisplayName = $_.DisplayName }
                }
        }
        if(($MemberObjectTypes -eq 'All' ) -or ($MemberObjectTypes -eq 'Groups')){
            Get-MsolGroupMember -GroupObjectId $group.ObjectId -MemberObjectTypes 'Group' -TenantId $TenantId | `
                Sort-Object -Property DisplayName | ForEach-Object{
                    if($Nested -eq $true){
                        Get-NestedGroupMember $_
                    }
                    else {
                        $Script:Members += [PSCustomObject] @{Type = 'Group';DisplayName = $_.DisplayName }
                    }                
                }
        }
    }

    if($PSCmdlet.ParameterSetName  -eq "Group object id"){
        $Script:Grp = Get-MsolGroup -ObjectId $GroupObjectId -TenantId $TenantId  
    }
    else{
        $Script:Grp = Get-MsolGroup -TenantId $TenantId  | Where-Object {$_.Displayname -eq $GroupName} 
    }
    if($null -ne $Script:Grp){
        Get-NestedGroupMember $Script:Grp
    }
    else {
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "Group not found"
        } 
        Throw "Group not found"
    }

    if($null -ne $Script:Members){
        ConvertTo-ResultHtml -Result $Script:Members
    }
    else {
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "No members found"
        } 
        else{
            Write-Output "No members found"
        }
    }
}
catch{
    throw
}