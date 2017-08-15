# Action Pack for Active Directory

> Note: The use of the scripts requires the PowerShell Module ActiveDirectory.

## [Manage Computers](./Computers)

+ `Get-ADComputerProperties.ps1`

  Gets the properties of the Active Directory computer.

+ `Get-ADComputersWithDefinedStatus.ps1`

  Lists computers where disabled or inactive.

+ `Remove-ADComputer.ps1`

  Removes Active Directory computer.

+ `Set-ADComputerDefinedStatus.ps1`

  Enable or disable a Active Directory computer.

+ `Set-ADComputerProperties.ps1`

  Sets the properties of the Active Directory computer.

## [Manage Groups](./Groups)

+ `Get-ADEmptyGroups.ps1`

  Gets the Active Directory groups without members.

+ `Get-ADGroupMembers.ps1`

  Gets the members of the Active Directory group.

+ `Get-ADGroupProperties.ps1`

  Gets the properties of the Active Directory group.

+ `Get-ADGroups.ps1`

  Gets all groups from the OU path.

+ `New-ADGroup.ps1`

  Creates a group in the OU path.

+ `Remove-ADGroup.ps1`

   Removes the Active Directory group.

+ `Set-ADGroupProperties.ps1`

  Sets the properties of the Active Directory group.

## [Manage Users](./Users)

+ `Add-ADUsersToGroups.ps1`

  Adds users to Active Directory groups.

+ `Get-ADUserMemberships.ps1`

  Gets the memberships of the Active Directory account.

+ `Get-ADUserProperties.ps1`

  Gets the properties of the Active Directory account.

+ `Get-ADUsersWithDefinedStatus.ps1`

  Lists users where disabled, inactive, locked out and/or account is expired.

+ `New-ADUser.ps1`

  Creates a user in the OU path.

+ `Remove-ADServiceAccount.ps1`

  Removes Active Directory service account.

+ `Remove-ADUser.ps1`

  Removes Active Directory account.

+ `Remove-ADUsersFromGroups.ps1`

  Removes users to Active Directory groups.

+ `Reset-ADUserPassword.ps1`

  Resets the password of the Active Directory account.

+ `Set-ADUserDefinedStatus.ps1`

  Enable, disable and/or unlock a Active Directory account.

+ `Set-ADUserProperties.ps1`

  Sets the properties of the Active Directory user.
