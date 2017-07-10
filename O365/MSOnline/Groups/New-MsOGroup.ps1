#Requires -Modules MSOnline
<#
    .SYNOPSIS
        Connect to MS Online and adds a new group to the Azure Active Directory
        Requirements 
        64-bit OS for all Modules 
        Microsoft Online Sign-In Assistant for IT Professionals  
        Azure Active Diretory Powershell Module

    .DESCRIPTION         

    .Parameter O365Account
        Specifies the credential to use to connect to Azure Active Directory

    .Parameter GroupName
        Specifies the display name of the group

    .Parameter Description
        Specifies a description of the group
    
    .Parameter TenantId
        Specifies the unique ID of the tenant on which to perform the operation
#>

param(
<#
    [Parameter(Mandatory = $true)]
    [PSCredential]$O365Account,
#>
    [Parameter(Mandatory = $true)]
    [string]$GroupName,
    [string]$Description,
    [guid]$TenantId
)

# Import-Module MSOnline

#Clear
$ErrorActionPreference='Stop'

# Connect-MsolService -Credential $O365Account 

$Script:Grp = New-MsolGroup -DisplayName $GroupName -Description $Description -TenantId $TenantId | Select-Object *
if($null -ne $Script:Grp){
    $res=@("Group $($GroupName) created",$Script:Grp)
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Group $($GroupName) created"
    } 
    else{
        Write-Output $res
    }
}
else{
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Group not created"
    }    
    Write-Error "Group not created"
}