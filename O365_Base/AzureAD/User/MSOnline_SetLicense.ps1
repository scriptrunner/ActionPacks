<#
    .SYNOPSIS 
    Add UsageLocation with predefiend values and add license for a given User

    .PARAMETER cred
    MS Online credential
#>

param(
   [PSCredential]$cred,
   $UserPrincipleName,
      [ValidateSet("DE","CH")]
   $UsageLocation,
   [ValidateSet("Testlab100:ENTERPRISEPACK")]
   $AddLicenses
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
Set-MsolUser -UserPrincipalName $UserPrincipleName -UsageLocation $UsageLocation
Set-MsolUserLicense -UserPrincipalName $UserPrincipleName -AddLicenses $AddLicenses