#Requires -Version 4.0
#Requires -Modules AzureAD

<#
    .SYNOPSIS
        Generates a report with the properties of the members from the group
    
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
        Requires Library Script ReportLibrary from the Action Pack Reporting\_LIB_

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/AzureAD/_REPORTS_

    .Parameter GroupObjectId
        [sr-en] Specifies the unique ID of the group from which to get members
        [sr-en] Eindeutige ID der Gruppe

    .Parameter GroupName
        [sr-en] Specifies the display name of the group from which to get members
        [sr-en] Anzeigename der Gruppe

    .Parameter Nested
        [sr-en] Shows group members nested 
        [sr-de] Gruppenmitglieder rekursiv anzeigen

    .Parameter MemberObjectTypes
        [sr-en] Specifies the member object types
        [sr-de] Gruppen, Benutzer oder alle anzeigen

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
    [string]$MemberObjectTypes='All'
)

try{
    $Script:Members=@()

    function Get-NestedGroupMember($group) { 
        $Script:Members += [PSCustomObject] @{Type = 'Group';DisplayName=$group.DisplayName}
        if(($MemberObjectTypes -eq 'All' ) -or ($MemberObjectTypes -eq 'Users')){
            Get-AzureADGroupMember -ObjectId $group.ObjectId | Where-Object {$_.ObjectType -eq 'User'} | `
                Sort-Object -Property DisplayName | ForEach-Object{
                    $Script:Members += [PSCustomObject] @{Type = 'User'; DisplayName=$_.DisplayName}
                }
        }
        if(($MemberObjectTypes -eq 'All' ) -or ($MemberObjectTypes -eq 'Groups')){
            Get-AzureADGroupMember -ObjectId $group.ObjectId | Where-Object {$_.ObjectType -eq 'Group'} | `
                Sort-Object -Property DisplayName | ForEach-Object{
                    if($Nested -eq $true){
                        Get-NestedGroupMember $_
                    }
                    else {
                        $Script:Members += [PSCustomObject] @{Type = 'Group';DisplayName=$group.DisplayName}
                    }                
                }
        }
    }

    if($PSCmdlet.ParameterSetName  -eq "Group object id"){
        $Script:Grp = Get-AzureADGroup -ObjectId $GroupObjectId
    }
    else{
        $Script:Grp = Get-AzureADGroup -All $true | Where-Object {$_.Displayname -eq $GroupName} 
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
finally{

}