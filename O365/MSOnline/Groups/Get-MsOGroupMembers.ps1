#Requires -Version 4.0
#Requires -Modules MSOnline

<#
    .SYNOPSIS
        Connect to MS Online and gets the members from the Azure Active Directory group
    
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
        ScriptRunner Version 4.x or higher

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/MSOnline/Groups

    .Parameter GroupObjectId
        Specifies the unique ID of the group from which to get members

    .Parameter GroupName
        Specifies the display name of the group from which to get members

    .Parameter Nested
        Shows group members nested 

    .Parameter MemberObjectTypes
        Specifies the member object types

    .Parameter TenantId
        Specifies the unique ID of the tenant on which to perform the operation
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
        $Script:Members += "Group: $($group.DisplayName)" 
        if(($MemberObjectTypes -eq 'All' ) -or ($MemberObjectTypes -eq 'Users')){
            Get-MsolGroupMember -GroupObjectId $group.ObjectId -MemberObjectTypes 'User' -TenantId $TenantId | `
                Sort-Object -Property DisplayName | ForEach-Object{
                    $Script:Members += "User: $($_.DisplayName)"
                }
        }
        if(($MemberObjectTypes -eq 'All' ) -or ($MemberObjectTypes -eq 'Groups')){
            Get-MsolGroupMember -GroupObjectId $group.ObjectId -MemberObjectTypes 'Group' -TenantId $TenantId | `
                Sort-Object -Property DisplayName | ForEach-Object{
                    if($Nested -eq $true){
                        Get-NestedGroupMember $_
                    }
                    else {
                        $Script:Members += "Group: $($_.DisplayName)"
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
        if($SRXEnv) {
            $SRXEnv.ResultMessage = $Script:Members
        } 
        else{
            Write-Output $Script:Members 
        }
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