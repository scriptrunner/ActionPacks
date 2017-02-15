<#
    .SYNOPSIS 
    Change Attributes of a given user

    .PARAMETER cred
    MS Online credential
#>

param(
   [PSCredential]$cred,
   $UserPrincipleName,
   $Password
  
   )

# Requirements
# 64-bit OS for all Modules
# install - Microsoft Online Sign-In Assistant for IT Professionals 
# install - Azure Active Diretory Powershell Module
###################################################################
#Import-Module MsOnline
# Connect to Windows Azure Active Diretory
Connect-MsolService -Credential $cred -Verbose
# Examaple for user Password Reset
# 
# Variant 1 - PW-Admin set the password
# 
Set-MsolUserPassword -UserPrincipalName $UserPrincipleName -NewPassword $Password
#
# Variant 2 - System sets the password
# Set-MsolUserPassword -UserPrincipalName $UserPrincipleName -ForceChangePassword $true


#
