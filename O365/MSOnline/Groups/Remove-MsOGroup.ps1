#Requires -Modules MSOnline

<#
    .SYNOPSIS
        Connect to MS Online and removes group from Azure Active Directory
        Requirements 
        64-bit OS for all Modules 
        Microsoft Online Sign-In Assistant for IT Professionals  
        Azure Active Diretory Powershell Module v1

    .DESCRIPTION         

    .Parameter O365Account
        Specifies the credential to use to connect to Azure Active Directory

    .Parameter GroupObjectId
        Specifies the unique ID of the group from which to get members

    .Parameter GroupName
        Specifies the name of the group from which to get members
    
    .Parameter TenantId
        Specifies the unique ID of the tenant on which to perform the operation
#>

param(
<#
    [Parameter(Mandatory = $true,ParameterSetName = "Group name")]
    [Parameter(Mandatory = $true,ParameterSetName = "Group object id")]
    [PSCredential]$O365Account,
#>
    [Parameter(Mandatory = $true,ParameterSetName = "Group object id")]
    [guid]$GroupObjectId,
    [Parameter(Mandatory = $true,ParameterSetName = "Group name")]
    [string]$GroupName,
    [Parameter(ParameterSetName = "Group name")]
    [Parameter(ParameterSetName = "Group object id")]
    [guid]$TenantId
)

# Import-Module MSOnline

#Clear
$ErrorActionPreference='Stop'

# Connect-MsolService -Credential $O365Account 

if($PSCmdlet.ParameterSetName  -eq "Group object id"){
    $Script:Grp = Get-MsolGroup -ObjectId $GroupObjectId -TenantId $TenantId  
}
else{
    $Script:Grp = Get-MsolGroup -TenantId $TenantId  | Where-Object {$_.Displayname -eq $GroupName} 
}
if($null -ne $Script:Grp){
    Remove-MsolGroup -ObjectId $Script:Grp.ObjectId -TenantId $TenantId -Force
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Group $($Script:Grp.DisplayName) removed"
    } 
    else{
        Write-Output "Group $($Script:Grp.DisplayName) removed"
    }
}
else {
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Group not found"
    } 
    Write-Error "Group not found"
}