#Requires -Modules MSOnline

<#
    .SYNOPSIS
        Connect to MS Online and remove members from Azure Active Directory group
        Requirements 
        64-bit OS for all Modules 
        Microsoft Online Sign-In Assistant for IT Professionals  
        Azure Active Diretory Powershell Module
    
    .DESCRIPTION                        

    .Parameter O365Account
        Specifies the credential to use to connect to Azure Active Directory

    .Parameter GroupObjectIds
        Specifies the unique IDs of the groups to which to remove members

    .Parameter GroupIds
        Specifies the unique object IDs of the groups to remove from the group

    .Parameter UserIds
        Specifies the unique object IDs of the users to remove from the group

    .Parameter TenantId
        Specifies the unique ID of the tenant on which to perform the operation
#>

param(
<#
    [Parameter(Mandatory = $true)]
    [PSCredential]$O365Account,
#>
    [Parameter(Mandatory = $true)]
    [guid[]]$GroupObjectIds,
    [guid[]]$GroupIds,
    [guid[]]$UserIds,
    [guid]$TenantId
)
 
# Import-Module MSOnline

#Clear

$ErrorActionPreference='Stop'

# Connect-MsolService -Credential $O365Account 

$Script:result = @()
$Script:err = $false
forEach($gid in $GroupObjectIds){
    try{
        $grp = Get-MsolGroup -ObjectId $gid -TenantId $TenantId
    }
    catch{
        $Script:result += "Error: GroupObjectID $($gid) $($_.Exception.Message)"
        $Script:err = $true
        continue
    }
    if($null -ne $grp){
        if($null -ne $GroupIds){
            $addGrp
            forEach($itm in $GroupIds){
                try{
                    $addGrp=Get-MsolGroup -ObjectId $itm -TenantId $TenantId
                }
                catch{
                    $Script:result += "Error: GroupID $($itm) $($_.Exception.Message)"
                    $Script:err = $true
                    continue
                }
                if($null -ne $addGrp){
                    try{
                        Remove-MsolGroupMember  -GroupObjectId $gid -GroupMemberObjectId $itm -GroupMemberType 'Group' -TenantId $TenantId
                        $Script:result += "Group $($addGrp.DisplayName) removed from Group $($grp.DisplayName)"
                    }
                    catch{
                        $Script:result += "Error: GroupID $($itm) $($_.Exception.Message)"
                        $Script:err = $true
                        continue
                    }
                }                
            }
        }
        if($null -ne $UserIds){
            $usr
            forEach($itm in $UserIds){
                try{
                    $usr=Get-MsolUser -ObjectId $itm -TenantId $TenantId
                }
                catch{
                    $Script:result += "Error: UserID $($itm) $($_.Exception.Message)"
                    $Script:err = $true
                    continue
                }
                if($null -ne $usr){
                    try{
                        Remove-MsolGroupMember -GroupObjectId $gid -GroupMemberObjectId $itm -GroupMemberType 'User' -TenantId $TenantId
                        $Script:result += "User $($usr.DisplayName) removed from Group $($grp.DisplayName)"
                    }
                    catch{
                        $Script:result += "Error: UserID $($itm) $($_.Exception.Message)"
                        $Script:err = $true
                        continue
                    }
                }
            }
        }
    }
    else {
        $Script:result += "Group $($gid) not found"
        $Script:err = $true
    }
}
if($SRXEnv) {
    $SRXEnv.ResultMessage = $Script:result
    if($Script:err -eq $true){
        Write-Error $Script:result
    }
} 
else{    
    Write-Output $Script:result 
}