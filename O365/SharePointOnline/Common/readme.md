# Common

> Note: The use of the scripts requires the PowerShell Module Microsoft.Online.SharePoint.PowerShell.


+ [Add-SPOGeoAdministrator.ps1](./Add-SPOGeoAdministrator.ps1)

  Adds a new SharePoint user or security group as GeoAdministrator to a multi-geo tenant
  
+ [Add-SPOOrg​Assets​Library.ps1](./Add-SPOOrg​Assets​Library.ps1)
    
  Designates a library to be used as a central location for organization assets across the tenant  
  
+ [ConvertTo-SPOMigrationEncryptedPackage.ps1](./ConvertTo-SPOMigrationEncryptedPackage.ps1)
    
  Convert your XML files into a new encrypted migration package 
  
+ [ConvertTo-SPOMigrationTargetedPackage.ps1](./ConvertTo-SPOMigrationTargetedPackage.ps1)
    
  Convert your XML files into a new migration package
  
+ [Enable-SPOCommSite.ps1](./Enable-SPOCommSite.ps1)
    
  Enables the modern communication site experience on an existing site

+ [Get-SPOGeoAdministrator.ps1](./Get-SPOGeoAdministrator.ps1)

  Returns the SharePoint Online user or security group accounts with global administrative privileges in the current Multi-Geographics tenant    

+ [Get-SPOGeoMoveCrossCompatibilityStatus.ps1](./Get-SPOGeoMoveCrossCompatibilityStatus.ps1)
    
  Returns the compatibility between sites and locations for a move in a multi-geo SharePoint Online tenant

+ [Get-SPOGeoStorageQuota.ps1](./Get-SPOGeoStorageQuota.ps1)

  Gets the storage quota on a multi-geo tenant   

+ [Get-SPOHide​Default​Themes.ps1](./Get-SPOHide​Default​Themes.ps1)
    
  Queries the current SPOHideDefaultThemes setting  

+ [Get-SPOMigrationJobProgress.ps1](./Get-SPOMigrationJobProgress.ps1)
    
  Report on SPO migration jobs that are in progress

+ [Get-SPOMigrationJobStatus.ps1](./Get-SPOMigrationJobStatus.ps1)
    
  Monitor the status of a submitted SharePoint Online migration job

+ [Get-SPOOrgAssetsLibrary.ps1](./Get-SPOOrgAssetsLibrary.ps1)
    
  Displays information about all libraries designated as locations for organization assets

+ [Get-SPOOrg​News​Site.ps1](./Get-SPOOrg​News​Site.ps1)
    
  Lists URLs of all the configured organizational news sites. Requires Tenant administrator permissions

+ [Get-SPOPublicCdnOrigins.ps1](./Get-SPOPublicCdnOrigins.ps1)
    
  Returns a list of CDN Origins in your SharePoint Online Tenant

+ [Get-SPOTheme.ps1](./Get-SPOTheme.ps1)
    
  Retrieves settings for an existing theme

+ [Get-SPOWebTemplate.ps1](./Get-SPOWebTemplate.ps1)
    
  Displays all site templates that match the given identity

+ [New-SPOMigrationPackage.ps1](./New-SPOMigrationPackage.ps1)
    
  Create a new migration package based on source files in a local or network shared folder

+ [New-SPOPublicCdnOrigin.ps1](./New-SPOPublicCdnOrigin.ps1)
    
  Creates a new public CDN on a document library in your Sharepoint Online Tenant

+ [New-SPOSdnProvider.ps1](./New-SPOSdnProvider.ps1)
    
  Adds a new Software-Defined Networking (SDN) provider

+ [Remove-SPOGeoAdministrator.ps1](./Remove-SPOGeoAdministrator.ps1)

  Removes a new SharePoint user or security Group in the current Multi-Geo Tenant

+ [Remove-SPOMigrationJob.ps1](./Remove-SPOMigrationJob.ps1)

  Remove a previously created migration job from the specified site collection

+ [Remove-SPOOrgAssetsLibrary.ps1](./Remove-SPOOrgAssetsLibrary.ps1)
    
  Removes a library that was designated as a central location for organization assets across the tenant

+ [Remove-SPOOrg​News​Site.ps1](./Remove-SPOOrg​News​Site.ps1)

  Removes a given site from the list of organizational news sites based on its URL in your Sharepoint Online Tenant

+ [Remove-SPOPublicCdnOrigin.ps1](./Remove-SPOPublicCdnOrigin.ps1)
    
  Removes a given public CDN origin based on its identity (id) in your Sharepoint Online Tenant

+ [Remove-SPOSdnProvider.ps1](./Remove-SPOSdnProvider.ps1)

  Removes Software-Defined Networking (SDN) Support in your SharePoint Online tenant

+ [Remove-SPOTheme.ps1](./Remove-SPOTheme.ps1)

  Removes a theme from the theme gallery

+ [Set-SPOGeoStorageQuota.ps1](./Set-SPOGeoStorageQuota.ps1)
    
  Sets the Storage quota on a multi-geo tenant

+ [Set-SPOHide​Default​Themes.ps1](./Set-SPOHide​Default​Themes.ps1)
    
  Specifies whether the default themes should be available

+ [Set-SPOMigration​Package​Azure​Source.ps1](./Set-SPOMigration​Package​Azure​Source.ps1)
    
  Create Azure containers, upload migration package files into the appropriate containers and snapshot the uploaded content

+ [Set-SPOOrgAssetsLibrary.ps1](./Set-SPOOrgAssetsLibrary.ps1)

  Updates information for a library that is designated as a location for organization assets

+ [Set-SPOOrg​News​Site.ps1](./Set-SPOOrg​News​Site.ps1)
    
  Marks a site as one of multiple possible tenant's organizational news sites

+ [Submit-SPOMigrationJob.ps1](./Submit-SPOMigrationJob.ps1)
    
  Submit a new migration job referenced to a previously uploaded package in Azure Blob storage into to a site collection