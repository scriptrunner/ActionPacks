#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Sets properties on the SharePoint Online organization
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module Microsoft.Online.SharePoint.PowerShell
        ScriptRunner Version 4.2.x or higher

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/SharePointOnline/Tenant

    .Parameter AllowEditing
        Prevents users from editing Office files in the browser and copying and pasting Office file contents out of the browser window

    .Parameter ApplyAppEnforcedRestrictionsToAdHocRecipients
        When the feature is enabled, all guest users are subject to conditional access policy

    .Parameter BccExternalSharingInvitations
        When the feature is enabled, all external sharing invitations that are sent will blind copy the e-mail messages listed in the BccExternalSharingsInvitationList

    .Parameter BccExternalSharingsInvitationList
        Specifies a list of e-mail addresses to be BCC'd when the BCC for External Sharing feature is enabled

    .Parameter CommentsOnSitePagesDisabled

    .Parameter ConditionalAccessPolicy
        Control access from unmanaged devices

    .Parameter DefaultSharingLinkType
        Lets administrators choose what type of link appears is selected in the “Get a link” sharing dialog box in OneDrive for Business and SharePoint Online

    .Parameter DisabledWebPartIds
        Allows administrators prevent certain, specific web parts from being added to pages or rendering on pages on which they were previously added

    .Parameter DisallowInfectedFileDownload
        Prevents the Download button from being displayed on the Virus Found warning page

    .Parameter DisplayStartASiteOption
        Determines whether tenant users see the Start a Site menu option

    .Parameter EnableAzureADB2BIntegration
        Enables the preview for OneDrive and SharePoint integration with Azure AD B2B

    .Parameter EnableGuestSignInAcceleration
        Accelerates guest-enabled site collections as well as member-only site collections when the SignInAccelerationDomain parameter is set

    .Parameter ExternalServicesEnabled
        Enables external services for a tenant

    .Parameter FileAnonymousLinkType

    .Parameter FolderAnonymousLinkType

    .Parameter IPAddressAllowList
        Configures multiple IP addresses or IP address ranges (IPv4 or IPv6)

    .Parameter IPAddressEnforcement
        Allows access from network locations that are defined by an administrator

    .Parameter IPAddressWACTokenLifetime

    .Parameter LegacyAuthProtocolsEnabled
        By default this value is set to $True, which means that authentication using legacy protocols is enabled

    .Parameter MaxCompatibilityLevel
        Specifies the upper bound on the compatibility level for new sites

    .Parameter MinCompatibilityLevel
        Specifies the lower bound on the compatibility level for new sites

    .Parameter NoAccessRedirectUrl
        Specifies the URL of the redirected site for those site collections which have the locked state "NoAccess."

    .Parameter NotificationsInOneDriveForBusinessEnabled

    .Parameter NotificationsInSharePointEnabled

    .Parameter NotifyOwnersWhenInvitationsAccepted
        When this parameter is set to $true and when an external user accepts an invitation to a resource in a user’s OneDrive for Business, the OneDrive for Business owner is notified by e-mail

    .Parameter NotifyOwnersWhenItemsReshared
        When this parameter is set to $true and another user re-shares a document from a user’s OneDrive for Business, the OneDrive for Business owner is notified by e-mail

    .Parameter ODBAccessRequests
        Lets administrators set policy on access requests and requests to share in OneDrive for Business

    .Parameter ODBMembersCanShare
        Lets administrators set policy on re-sharing behavior in OneDrive for Business

    .Parameter OfficeClientADALDisabled
        When set to true this will disable the ability to use Modern Authentication that leverages ADAL across the tenant

    .Parameter OneDriveForGuestsEnabled
        Lets OneDrive for Business creation for administrator managed guest users. 
        Administrator managed Guest users use credentials in the resource tenant to access the resources

    .Parameter OneDriveStorageQuota
        Sets a default OneDrive for Business storage quota for the tenant

    .Parameter OrphanedPersonalSitesRetentionPeriod
        Specifies the number of days after a user's Active Directory account is deleted that their OneDrive for Business content will be deleted

    .Parameter OwnerAnonymousNotification

    .Parameter PermissiveBrowserFileHandlingOverride
        Enables the Permissive browser file handling. By default, the browser file handling is set to Strict

    .Parameter PreventExternalUsersFromResharing

    .Parameter ProvisionSharedWithEveryoneFolder
        Creates a Shared with Everyone folder in every user's new OneDrive for Business document library

    .Parameter PublicCdnAllowedFileTypes

    .Parameter PublicCdnEnabled

    .Parameter RequireAcceptingAccountMatchInvitedAccount
        Ensures that an external user can only accept an external sharing invitation with an account matching the invited email address 
        It may take up to 24 hours to take effect

    .Parameter RequireAnonymousLinksExpireInDays
        Specifies all anonymous links that have been created (or will be created) will expire after the set number of days

    .Parameter SearchResolveExactEmailOrUPN
        Removes the search capability from People Picker

    .Parameter SharingAllowedDomainList
        Specifies a list of email domains that is allowed for sharing with the external collaborators

    .Parameter SharingBlockedDomainList
        Specifies a list of email domains that is blocked or prohibited for sharing with the external collaborators

    .Parameter SharingCapability
        Determines what level of sharing is available for the site.

    .Parameter SharingDomainRestrictionMode
        Specifies the external sharing mode for domains

    .Parameter ShowAllUsersClaim
        Enables the administrator to hide the All Users claim groups in People Picker

    .Parameter ShowEveryoneClaim
        Enables the administrator to hide the Everyone claim in the People Picker

    .Parameter ShowEveryoneExceptExternalUsersClaim
        Enables the administrator to hide the "Everyone except external users" claim in the People Picker

    .Parameter ShowPeoplePickerSuggestionsForGuestUsers
        Enable the option to search for existing guest users at Tenant Level

    .Parameter SignInAccelerationDomain
        Specifies the home realm discovery value to be sent to Azure Active Directory (AAD) during the user sign-in process

    .Parameter SocialBarOnSitePagesDisabled
        Disables or enables the Social Bar

    .Parameter SpecialCharactersStateInFileFolderNames
        Permits the use of special characters in file and folder names in SharePoint Online and OneDrive for Business document libraries

    .Parameter StartASiteFormUrl
        Specifies URL of the form to load in the Start a Site dialog. 
        Example: "https://contoso.sharepoint.com/path/to/form"

    .Parameter UseFindPeopleInPeoplePicker
        This feature enables tenant admins to enable ODB and SPO to respect Exchange supports Address Book Policy (ABP) policies in the people picker

    .Parameter UsePersistentCookiesForExplorerView
        Lets SharePoint issue a special cookie that will allow this feature to work even when "Keep Me Signed In" is not selected

    .Parameter UserVoiceForFeedbackEnabled
        "Feedback" link will be shown at the bottom of all modern SharePoint Online pages

    .Parameter CustomizedExternalSharingServiceUrl
        Specifies a URL that will be appended to the error message that is surfaced when a user is blocked from sharing externally by policy. 
        An example value is "https://www.contoso.com/sharingpolicies".

#>

param( 
    [Parameter(Mandatory = $true,ParameterSetName = 'MultipleSites')]
    [bool]$AllowEditing,
    [Parameter(Mandatory = $true,ParameterSetName = 'MultipleSites')]
    [ValidateSet('AllowFullAccess','LimitedAccess','BlockAccess')]
    [string]$ConditionalAccessPolicy,
    [Parameter(ParameterSetName = 'MultipleSites')]
    [ValidateSet('OfficeOnlineFilesOnly','WebPreviewableFiles','OtherFiles')]
    [string]$LimitedAccessFileType,
    [Parameter(ParameterSetName = 'Common')]
    [Parameter(ParameterSetName = 'MultipleSites')]
    [bool]$ApplyAppEnforcedRestrictionsToAdHocRecipients,
    [bool]$BccExternalSharingInvitations,
    [string]$BccExternalSharingsInvitationList,
    [bool]$CommentsOnSitePagesDisabled,
    [string]$CustomizedExternalSharingServiceUrl,
    [ValidateSet('None','Direct','Internal','AnonymousAccess')]
    [string]$DefaultSharingLinkType,
    [string]$DisabledWebPartIds,
    [bool]$DisallowInfectedFileDownload,
    [bool]$DisplayStartASiteOption,
    [bool]$EnableAzureADB2BIntegration,
    [bool]$EnableGuestSignInAcceleration,
    [bool]$ExternalServicesEnabled,
    [ValidateSet('None','View','Edit')]
    [string]$FileAnonymousLinkType,
    [ValidateSet('None','View','Edit')]
    [string]$FolderAnonymousLinkType,
    [string]$IPAddressAllowList,
    [bool]$IPAddressEnforcement,
    [int]$IPAddressWACTokenLifetime,
    [bool]$LegacyAuthProtocolsEnabled = $true,
    [int]$MaxCompatibilityLevel,
    [int]$MinCompatibilityLevel,
    [string]$NoAccessRedirectUrl,
    [bool]$NotificationsInOneDriveForBusinessEnabled,
    [bool]$NotificationsInSharePointEnabled,
    [bool]$NotifyOwnersWhenInvitationsAccepted,
    [bool]$NotifyOwnersWhenItemsReshared,
    [ValidateSet('On','Off','Unspecified')]
    [string]$ODBAccessRequests,
    [ValidateSet('On','Off','Unspecified')]
    [string]$ODBMembersCanShare,
    [bool]$OfficeClientADALDisabled,
    [bool]$OneDriveForGuestsEnabled,
    [int64]$OneDriveStorageQuota,
 <#   [ValidateRange(30 , 3650)]
    [int]$OrphanedPersonalSitesRetentionPeriod = 30,#>
    [bool]$OwnerAnonymousNotification,
    [bool]$PermissiveBrowserFileHandlingOverride,
    [bool]$PreventExternalUsersFromResharing,
    [bool]$ProvisionSharedWithEveryoneFolder,
    [string]$PublicCdnAllowedFileTypes,
    [bool]$PublicCdnEnabled,
    [bool]$RequireAcceptingAccountMatchInvitedAccount,
    [int]$RequireAnonymousLinksExpireInDays,
    [bool]$SearchResolveExactEmailOrUPN,
    [string]$SharingAllowedDomainList,
    [string]$SharingBlockedDomainList,             
    [ValidateSet('ExternalUserAndGuestSharing','Disabled','ExternalUserSharingOnly')]
    [string]$SharingCapability,
    [ValidateSet('None','AllowList','BlockList')]
    [string]$SharingDomainRestrictionMode,
    [bool]$ShowAllUsersClaim,
    [bool]$ShowEveryoneClaim,
    [bool]$ShowEveryoneExceptExternalUsersClaim,
    [bool]$ShowPeoplePickerSuggestionsForGuestUsers,
    [string]$SignInAccelerationDomain,
    [bool]$SocialBarOnSitePagesDisabled ,
    [ValidateSet('NoPreference','Allowed','Disallowed')]
    [string]$SpecialCharactersStateInFileFolderNames,
    [string]$StartASiteFormUrl,
    [bool]$UseFindPeopleInPeoplePicker,
    [bool]$UsePersistentCookiesForExplorerView,
    [bool]$UserVoiceForFeedbackEnabled
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{
    [string[]]$Properties = @('AllowEditing','PublicCdnAllowedFileTypes','ExternalServicesEnabled','StorageQuotaAllocated','ResourceQuotaAllocated','OneDriveStorageQuota')
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'LegacyAuthProtocolsEnabled' = $LegacyAuthProtocolsEnabled
#                            'OrphanedPersonalSitesRetentionPeriod' = $OrphanedPersonalSitesRetentionPeriod
                            } 
    if($PSBoundParameters.ContainsKey('AllowEditing')){
        $cmdArgs.Add('AllowEditing' , $AllowEditing)
    }
    if($PSBoundParameters.ContainsKey('CustomizedExternalSharingServiceUrl')){
        $cmdArgs.Add('CustomizedExternalSharingServiceUrl' , $CustomizedExternalSharingServiceUrl)
    }
    if($PSBoundParameters.ContainsKey('LimitedAccessFileType')){
        $cmdArgs.Add('LimitedAccessFileType' , $LimitedAccessFileType)
    }
    if($PSBoundParameters.ContainsKey('ApplyAppEnforcedRestrictionsToAdHocRecipients')){
        $cmdArgs.Add('ApplyAppEnforcedRestrictionsToAdHocRecipients' , $ApplyAppEnforcedRestrictionsToAdHocRecipients)
    }
    if($PSBoundParameters.ContainsKey('BccExternalSharingInvitations')){
        $cmdArgs.Add('BccExternalSharingInvitations' , $BccExternalSharingInvitations)
    }
    if($PSBoundParameters.ContainsKey('CommentsOnSitePagesDisabled')){
        $cmdArgs.Add('CommentsOnSitePagesDisabled' , $CommentsOnSitePagesDisabled)
    }
    if($PSBoundParameters.ContainsKey('BccExternalSharingsInvitationList')){
        $cmdArgs.Add('BccExternalSharingsInvitationList' , $BccExternalSharingsInvitationList.Trim())
    }
    if($PSBoundParameters.ContainsKey('ConditionalAccessPolicy')){
        $cmdArgs.Add('ConditionalAccessPolicy' , $ConditionalAccessPolicy)
    }
    if($PSBoundParameters.ContainsKey('DefaultSharingLinkType')){
        $cmdArgs.Add('DefaultSharingLinkType' , $DefaultSharingLinkType)
    }
    if($PSBoundParameters.ContainsKey('DisabledWebPartIds')){
        $cmdArgs.Add('DisabledWebPartIds' , $DisabledWebPartIds)
    }
    if($PSBoundParameters.ContainsKey('DisallowInfectedFileDownload')){
        $cmdArgs.Add('DisallowInfectedFileDownload' , $DisallowInfectedFileDownload)
    }
    if($PSBoundParameters.ContainsKey('DisplayStartASiteOption')){
        $cmdArgs.Add('DisplayStartASiteOption' , $DisplayStartASiteOption)
    }
    if($PSBoundParameters.ContainsKey('EnableAzureADB2BIntegration')){
        $cmdArgs.Add('EnableAzureADB2BIntegration' , $EnableAzureADB2BIntegration)
    }
    if($PSBoundParameters.ContainsKey('EnableGuestSignInAcceleration')){
        $cmdArgs.Add('EnableGuestSignInAcceleration' , $EnableGuestSignInAcceleration)
    }
    if($PSBoundParameters.ContainsKey('ExternalServicesEnabled')){
        $cmdArgs.Add('ExternalServicesEnabled' , $ExternalServicesEnabled)
    }
    if($PSBoundParameters.ContainsKey('FileAnonymousLinkType')){
        $cmdArgs.Add('FileAnonymousLinkType' , $FileAnonymousLinkType)
    }
    if($PSBoundParameters.ContainsKey('FolderAnonymousLinkType')){
        $cmdArgs.Add('FolderAnonymousLinkType' , $FolderAnonymousLinkType)
    }
    if($PSBoundParameters.ContainsKey('IPAddressAllowList')){
        $cmdArgs.Add('IPAddressAllowList' , $IPAddressAllowList)
    }
    if($PSBoundParameters.ContainsKey('IPAddressEnforcement')){
        $cmdArgs.Add('IPAddressEnforcement' , $IPAddressEnforcement)
    }
    if($PSBoundParameters.ContainsKey('NotificationsInOneDriveForBusinessEnabled')){
        $cmdArgs.Add('NotificationsInOneDriveForBusinessEnabled' , $NotificationsInOneDriveForBusinessEnabled)
    }
    if($PSBoundParameters.ContainsKey('NoAccessRedirectUrl')){
        $cmdArgs.Add('NoAccessRedirectUrl' , $NoAccessRedirectUrl.Trim())
    }
    if($PSBoundParameters.ContainsKey('NotificationsInSharePointEnabled')){
        $cmdArgs.Add('NotificationsInSharePointEnabled' , $NotificationsInSharePointEnabled)
    }
    if($PSBoundParameters.ContainsKey('NotifyOwnersWhenInvitationsAccepted')){
        $cmdArgs.Add('NotifyOwnersWhenInvitationsAccepted' , $NotifyOwnersWhenInvitationsAccepted)
    }
    if($PSBoundParameters.ContainsKey('NotifyOwnersWhenItemsReshared')){
        $cmdArgs.Add('NotifyOwnersWhenItemsReshared' , $NotifyOwnersWhenItemsReshared)
    }
    if($PSBoundParameters.ContainsKey('ODBAccessRequests')){
        $cmdArgs.Add('ODBAccessRequests' , $ODBAccessRequests)
    }
    if($PSBoundParameters.ContainsKey('ODBAccessRequests')){
        $cmdArgs.Add('ODBAccessRequests' , $ODBAccessRequests)
    }
    if($PSBoundParameters.ContainsKey('ODBMembersCanShare')){
        $cmdArgs.Add('ODBMembersCanShare' , $ODBMembersCanShare)
    }
    if($PSBoundParameters.ContainsKey('OneDriveForGuestsEnabled')){
        $cmdArgs.Add('OneDriveForGuestsEnabled' , $OneDriveForGuestsEnabled)
    }
    if($PSBoundParameters.ContainsKey('OfficeClientADALDisabled')){
        $cmdArgs.Add('OfficeClientADALDisabled' , $OfficeClientADALDisabled)
    }
    if($PSBoundParameters.ContainsKey('OwnerAnonymousNotification')){
        $cmdArgs.Add('OwnerAnonymousNotification' , $OwnerAnonymousNotification)
    }
    if($PSBoundParameters.ContainsKey('PermissiveBrowserFileHandlingOverride')){
        $cmdArgs.Add('PermissiveBrowserFileHandlingOverride' , $PermissiveBrowserFileHandlingOverride)
    }
    if($PSBoundParameters.ContainsKey('PreventExternalUsersFromResharing')){
        $cmdArgs.Add('PreventExternalUsersFromResharing' , $PreventExternalUsersFromResharing)
    }
    if($PSBoundParameters.ContainsKey('ProvisionSharedWithEveryoneFolder')){
        $cmdArgs.Add('ProvisionSharedWithEveryoneFolder' , $ProvisionSharedWithEveryoneFolder)
    }
    if($PSBoundParameters.ContainsKey('PublicCdnAllowedFileTypes')){
        $cmdArgs.Add('PublicCdnAllowedFileTypes' , $PublicCdnAllowedFileTypes)
    }
    if($PSBoundParameters.ContainsKey('PublicCdnEnabled')){
        $cmdArgs.Add('PublicCdnEnabled' , $PublicCdnEnabled)
    }
    if($PSBoundParameters.ContainsKey('RequireAcceptingAccountMatchInvitedAccount')){
        $cmdArgs.Add('RequireAcceptingAccountMatchInvitedAccount' , $RequireAcceptingAccountMatchInvitedAccount)
    }
    if($PSBoundParameters.ContainsKey('RequireAnonymousLinksExpireInDays')){
        $cmdArgs.Add('RequireAnonymousLinksExpireInDays' , $RequireAnonymousLinksExpireInDays)
    }
    if($PSBoundParameters.ContainsKey('SearchResolveExactEmailOrUPN')){
        $cmdArgs.Add('SearchResolveExactEmailOrUPN' , $SearchResolveExactEmailOrUPN)
    }
    if($PSBoundParameters.ContainsKey('SharingAllowedDomainList')){
        $cmdArgs.Add('SharingAllowedDomainList' , $SharingAllowedDomainList)
    }
    if($PSBoundParameters.ContainsKey('SharingBlockedDomainList')){
        $cmdArgs.Add('SharingBlockedDomainList' , $SharingBlockedDomainList)
    }    
    if($PSBoundParameters.ContainsKey('SharingCapability')){
        $cmdArgs.Add('SharingCapability' , $SharingCapability)
    }
    if($PSBoundParameters.ContainsKey('SharingDomainRestrictionMode')){
        $cmdArgs.Add('SharingDomainRestrictionMode' , $SharingDomainRestrictionMode)
    }    
    if($PSBoundParameters.ContainsKey('ShowAllUsersClaim')){
        $cmdArgs.Add('ShowAllUsersClaim' , $ShowAllUsersClaim)
    }     
    if($PSBoundParameters.ContainsKey('ShowEveryoneClaim')){
        $cmdArgs.Add('ShowEveryoneClaim' , $ShowEveryoneClaim)
    }    
    if($PSBoundParameters.ContainsKey('ShowEveryoneExceptExternalUsersClaim')){
        $cmdArgs.Add('ShowEveryoneExceptExternalUsersClaim' , $ShowEveryoneExceptExternalUsersClaim)
    }     
    if($PSBoundParameters.ContainsKey('ShowPeoplePickerSuggestionsForGuestUsers')){
        $cmdArgs.Add('ShowPeoplePickerSuggestionsForGuestUsers' , $ShowPeoplePickerSuggestionsForGuestUsers)
    }     
    if($PSBoundParameters.ContainsKey('SignInAccelerationDomain')){
        $cmdArgs.Add('SignInAccelerationDomain' , $SignInAccelerationDomain)
    }     
    if($PSBoundParameters.ContainsKey('SocialBarOnSitePagesDisabled')){
        $cmdArgs.Add('SocialBarOnSitePagesDisabled' , $SocialBarOnSitePagesDisabled)
    }    
    if($PSBoundParameters.ContainsKey('SpecialCharactersStateInFileFolderNames')){
        $cmdArgs.Add('SpecialCharactersStateInFileFolderNames' , $SpecialCharactersStateInFileFolderNames)
    }     
    if($PSBoundParameters.ContainsKey('StartASiteFormUrl')){
        $cmdArgs.Add('StartASiteFormUrl' , $StartASiteFormUrl)
    }     
    if($PSBoundParameters.ContainsKey('UseFindPeopleInPeoplePicker')){
        $cmdArgs.Add('UseFindPeopleInPeoplePicker' , $UseFindPeopleInPeoplePicker)
    }    
    if($PSBoundParameters.ContainsKey('UsePersistentCookiesForExplorerView')){
        $cmdArgs.Add('UsePersistentCookiesForExplorerView' , $UsePersistentCookiesForExplorerView)
    }      
    if($PSBoundParameters.ContainsKey('UserVoiceForFeedbackEnabled')){
        $cmdArgs.Add('UserVoiceForFeedbackEnabled' , $UserVoiceForFeedbackEnabled)
    }  
    if($IPAddressWACTokenLifetime -gt 0){
        $cmdArgs.Add('IPAddressWACTokenLifetime' , $IPAddressWACTokenLifetime)
    }
    if($MaxCompatibilityLevel -gt 0){
        $cmdArgs.Add('MaxCompatibilityLevel' , $MaxCompatibilityLevel)
    }
    if($MinCompatibilityLevel -gt 0){
        $cmdArgs.Add('MinCompatibilityLevel' , $MinCompatibilityLevel)
    }
    if($OneDriveStorageQuota -gt 0){
        $cmdArgs.Add('OneDriveStorageQuota' , $OneDriveStorageQuota)
    }

    $null = Set-SPOTenant @cmdArgs
    $result = Get-SPOTenant -ErrorAction Stop | Select-Object $Properties
      
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $result
    }
    else {
        Write-Output $result 
    }    
}
catch{
    throw
}
finally{
}