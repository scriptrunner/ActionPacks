<#
    .SYNOPSIS 
    Change Attributes of a given user

    .PARAMETER cred
    MS Online credential
#>

param(
   [PSCredential]$cred,
   $UserPrincipleName,
   $UsageLocation,
   $Phonenumber,
   [ValidateSet("de-DE","en-US")]
   $Preferredlanguage,
   [ValidateSet($True,$False)]
   $BlockCredential
   )

# Requirements
# 64-bit OS for all Modules
# install - Microsoft Online Sign-In Assistant for IT Professionals 
# install - Azure Active Diretory Powershell Module
###################################################################
#Import-Module MsOnline
# Connect to Windows Azure Active Diretory
Connect-MsolService -Credential $cred -Verbose
# Examaple for user attribute manipulations
# Attribute values are transformted to a variable e.g. $UserPrincipleName. All variables must be added to the param( ... ) section
# The param order defines the sequence. You can add or remove valid attribute values.
Set-MsolUser -UserPrincipalName $UserPrincipleName -UsageLocation $UsageLocation -PhoneNumber $Phonenumber -PreferredLanguage $Preferredlanguage -BlockCredential $BlockCredential

