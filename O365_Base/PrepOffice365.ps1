# Requirements
# 64-bit OS for all Modules
# install - Microsoft Online Sign-In Assistant for IT Professionals 
# install - Azure Active Diretory Powershell Module
###################################################################
# Connect to Windows Azure Active Diretory
connect-MsolService
# or with ADFS
connect-MsolService -CurrentCredential
#
###################################################################
# SharePoint Online Management Shell
# install - SharePoint Online Management Shell
# connect to SharePoint Online
connect-SPOService -url https://tenantname-admin.sharepoint.com
#
###################################################################
# Lync Online Connector Module
# install - Lync Online Connector Module
# connect to Lync Online 3 steps
# 1. Create Credetial Object
$cred = Get-Credential
# 2.Create Seesion to Lync Online
$session = New-CsolenSessio -Credential $cred
# 3. Import Session
Import-PSSession $session
###################################################################
# Exchange Online Remote PowerShell
# Requires .Net Framework 4.5
# no addional install!
# connect to Exchange Online 3 steps
# 1. Create Credetial Object
$cred = Get-Credential
# 2. Create Session to Exchange Online
$session = NewPSSession -ConfigurationName Microsoft.Exchange -ConnetionUri https://outlook.office365.com/powershell-liveid/ -Credential $cred -Authencation Basic -AllowRedirection
# 3. Import Session 
Import-PSSession $session
