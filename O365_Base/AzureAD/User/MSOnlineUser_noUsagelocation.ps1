<#
    .SYNOPSIS 
    Connect to MS Online and create a list of security groups

    .PARAMETER cred
    MS Online credential
#>

param(
   [PSCredential]$cred
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
# Get all Users that are not licensed
#
# Get-Msoluser -all -UnlicensedUsersOnly
#
# Get all Users with UsageLocation not set
#
# Get all unlicesed User with UsageLocation not set
#
Get-Msoluser -all -UnlicensedUsersOnly | Where-Object {$_.UsageLocation -eq $null}



