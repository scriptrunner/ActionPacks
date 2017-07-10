#Requires -Modules MSOnline

<#
    .SYNOPSIS
        Connect to MS Online and updates the properties of a Azure Active Directory group.
        Only parameters with value are set
        Requirements 
        64-bit OS for all Modules 
        Microsoft Online Sign-In Assistant for IT Professionals  
        Azure Active Diretory Powershell Module
    
    .DESCRIPTION                        

    .Parameter O365Account
        Specifies the credential to use to connect to Azure Active Directory

    .Parameter GroupObjectId
        Specifies the unique ID of the group to update

    .Parameter GroupIds
        Specifies the name of the group to update

    .Parameter Description
        Specifies a description of the group

    .Parameter DisplayName
        Specifies a display name of the group

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
    [string]$Description,
    [Parameter(ParameterSetName = "Group name")]
    [Parameter(ParameterSetName = "Group object id")]
    [string]$DisplayName,
    [Parameter(ParameterSetName = "Group name")]
    [Parameter(ParameterSetName = "Group object id")]
    [guid]$TenantId
)
 
# Import-Module MSOnline

#Clear

$ErrorActionPreference='Stop'

# Connect-MsolService -Credential $O365Account 

$Script:Grp
if($PSCmdlet.ParameterSetName  -eq "Group object id"){
    $Script:Grp = Get-MsolGroup -ObjectId $GroupObjectId -TenantId $TenantId 
}
else{
    $Script:Grp = Get-MsolGroup -TenantId $TenantId | Where-Object {$_.Displayname -eq $GroupName} 
}
if($null -ne $Script:Grp){
    if(-not [System.String]::IsNullOrWhiteSpace($Description)){
        Set-MsolGroup -ObjectId $Script:Grp.ObjectId -TenantId $TenantId -Description $Description
    }
    if(-not [System.String]::IsNullOrWhiteSpace($DisplayName)){
        Set-MsolGroup -ObjectId $Script:Grp.ObjectId -TenantId $TenantId -DisplayName $DisplayName
    }
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Group $($Script:Grp.DisplayName) changed"
    } 
    else{
        Write-Output  "Group $($Script:Grp.DisplayName) changed"
    }
}
else{
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Group not found"
    }    
    Write-Error "Group not found"
}