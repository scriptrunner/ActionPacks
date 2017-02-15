<#
    .SYNOPSIS 
    Connect to MS Online and create a list of security groups

    .PARAMETER cred
    MS Online credential
    
    .Parameter Groupname
    MS Online Gruppen Displaynamen

    .Paramete Username
    MS Online Anwender Benutzernamen

#>

param(
   [PSCredential]$cred,
   $Groupname,
   $Username
   
   )

# Requirements
# 64-bit OS for all Modules
# install - Microsoft Online Sign-In Assistant for IT Professionals 
# install - Azure Active Diretory Powershell Module
###################################################################
#Import-Module MsOnline
# Connect to Windows Azure Active Diretory
Connect-MsolService -Credential $cred -Verbose
#
# Get for a given group ObjectId and for a given user ObjectId
# Add user to group
#
$obj1 = (Get-MsolGroup -Searchstring $Groupname).ObjectId
$obj2 = (Get-Msoluser -UserPrincipalName $Username).ObjectID
Add-MsolGroupMember -GroupObjectId $obj1 -GroupMemberObjectId $obj2
