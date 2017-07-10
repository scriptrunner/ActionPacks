The use of the scripts requires the PowerShell Module MSOnline
This is the older MSOnline V1 PowerShell module for Azure Active Directory. 
Customers are encouraged to use the newer Azure Active Directory V2 PowerShell module instead of this module

Groups
-----------------------------------------------
Add-MsOMembersToGroups.ps1
	Connect to MS Online and adds members to Azure Active Directory groups
Get-MsOGroupMembers.ps1
	Connect to MS Online and gets the members from the Azure Active Directory group
Get-MsOGroupProperties.ps1
	Connect to MS Online and gets the properties from Azure Active Directory group
Get-MsOGroups.ps1
	Connect to MS Online and gets groups from Azure Active Directory
New-MsOGroup.ps1
	Connect to MS Online and adds a new group to the Azure Active Directory
Remove-MsOGroup.ps1
	Connect to MS Online and removes group from Azure Active Directory
Remove-MsOMembersFromGroups.ps1
	Connect to MS Online and remove members from Azure Active Directory groups
Set-MsOGroupProperties.ps1
	Connect to MS Online and updates the properties of a Azure Active Directory group
	
	
Users
-----------------------------------------------
Add-MsOUsersToRoles.ps1
	Connect to MS Online and adds members to Azure Active Directory roles
Get-MsOUserProperties.ps1 
	Connect to MS Online and gets the properties from Azure Active Directory user
Get-MsOUsers.ps1
	Connect to MS Online and gets list of users from Azure Active Directory
New-MsOUser.ps1
	Connect to MS Online and creates a user in Azure Active Directory
Remove-MsOUser.ps1
	Connect to MS Online and remove a user from Azure Active Directory
Remove-MsOUsersFromRoles.ps1
	Connect to MS Online and removes members from Azure Active Directory roles
Reset-MsOUserPassword.ps1
	Connect to MS Online and resets the password from Azure Active Directory user
Restore-MsOUser.ps1
	Connect to MS Online and restores a user from Azure Active Directory
Set-MsOUserBlockStatus.ps1
	 Connect to MS Online and sets user can log on Azure Active Directory
Set-O365UserProperties.ps1
	Connect to MS Online and modifies a user in Azure Active Directory