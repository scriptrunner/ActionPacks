<#
    .SYNOPSIS 
    Connect to MS Online and get all users

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
# Get-MsolUser -all | fl
# you can toggle betwenn list or table view by setting the # sign
# the table view can be customized by adding other valid attributes or removing exiting attributes from the table
Get-MsolUser -all | ft UserPrincipalName, Displayname, Country, City, isLicensed, ObjectId