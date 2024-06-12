# Action Pack for PowerShell SecretManagement

+ [Get-PSSMSecret.ps1](./Get-PSSMSecret.ps1)

  Finds and returns a secret by name from registered vaults 

+ [Get-PSSMSecretInfo.ps1](./Get-PSSMSecretInfo.ps1)

  Finds and returns metadata information about secrets in registered vaults

+ [Get-PSSMSecretStoreConfiguration.ps1](./Get-PSSMSecretStoreConfiguration.ps1)

  Returns SecretStore configuration information

+ [Get-PSSMSecretVault.ps1](./Get-PSSMSecretVault.ps1)

  Finds and returns registered vault information

+ [Register-PSSMSecretVault.ps1](./Register-PSSMSecretVault.ps1)

  Registers a SecretManagement extension vault module for the current user

+ [Remove-PSSMSecret.ps1](./Remove-PSSMSecret.ps1)

  Removes a secret from a specified registered extension vault

+ [Reset-PSSMSecretStore.ps1](./Reset-PSSMSecretStore.ps1)

  Resets the SecretStore by deleting all secret data and configuring the store with default options

+ [Set-PSSMSecret.ps1](./Set-PSSMSecret.ps1)

  Adds a secret to a SecretManagement registered vault

+ [Set-PSSMSecretStoreConfiguration.ps1](./Set-PSSMSecretStoreConfiguration.ps1)

  Configures the SecretStore

+ [Set-PSSMSecretStorePassword.ps1](./Set-PSSMSecretStorePassword.ps1)

  Replaces the current SecretStore password with a new one

+ [Set-PSSMSecretVault.ps1](./Set-PSSMSecretVault.ps1)

  Sets the provided vault name as the default vault for the current user

+ [Test-PSSMSecretVault.ps1](./Test-PSSMSecretVault.ps1)

  Runs an extension vault self test

+ [Unlock-PSSMSecretStore.ps1](./Unlock-PSSMSecretStore.ps1)

  Unlocks SecretStore with the provided password

+ [Unlock-PSSMSecretVault.ps1](./Unlock-PSSMSecretVault.ps1)

  Unlocks an extension vault so that it can be access in the current session

+ [Unregister-PSSMSecretVault.ps1](./Unregister-PSSMSecretVault.ps1)

  Un-registers an extension vault from SecretManagement for the current user


## [Queries](./_QUERY_)

+ [QRY_Get-PSSMSecretVault.ps1](./_QUERY_/QRY_Get-PSSMSecretVault.ps1)

  Finds and returns registered vaults