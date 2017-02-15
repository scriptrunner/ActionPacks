<#
    .SYNOPSIS 
    Connect to MS Online and create a list of security groups

    .PARAMETER cred
    MS Online credential
#>

param(
   [PSCredential]$cred,
   $Filelocation
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
# Get all Groups - ObjectId 
#
# Get-MsolGroup -All | ft GroupType, DisplayName, ObjectId 

Get-MsolGroup -All | Export-csv $Filelocation