<#
    .SYNOPSIS 
    Connect to MS Online and create a list of security groups

    .PARAMETER cred
    MS Online credential
#>

param(
   [PSCredential]$cred,
   $ImportFile
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
# Creates for every lin in .csv file a security group with DISPLAYNANE and DESCRIPTION
#
Import-Csv $ImportFile | ForEach-Object { New-MsolGroup -DisplayName $_.DisplayName -Description $_.Description }
