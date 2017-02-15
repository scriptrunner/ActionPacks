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
#
#
Import-Csv $ImportFile | ForEach-Object { New-MsolUser -UserPrincipalName $_.UserPrincipalName -FirstName $_.FirstName -LastName $_.LastName -DisplayName $_.DisplayName -Title $_.Title -Department $_.Department -Office $_.Office -MobilePhone  $_.MobilePhone -StreetAddress $_.StreetAddress -City $_.City -State $_.State -PostalCode $_.PostalCode -Country $_.Country -Password $_.PassWord }
