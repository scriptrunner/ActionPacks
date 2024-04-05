#Requires -Version 5.0
#Requires -Modules Microsoft.Online.SharePoint.PowerShell

<#
    .SYNOPSIS
        Sets or updates one or more properties' values for a site collection
    
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

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/SharePointOnline/Sites

    .Parameter Identity
        [sr-en] URL of the site collection to update

    .Parameter RemoveLabel

    .Parameter DisableSharingForNonOwners
        [sr-en] This parameter prevents non-owners from invited new users to the site

    .Parameter EnablePWA
        [sr-en] Determines whether site can include Project Web App

    .Parameter AllowEditing
        [sr-en] Prevents users from editing Office files in the browser and copying and pasting Office file contents out of the browser window

    .Parameter AllowSelfServiceUpgrade
        [sr-en] Determines whether site collection administrators can upgrade their site collections

    .Parameter AnonymousLinkExpirationInDays
        [sr-en] All anonymous/anyone links that have been created (or will be created) will expire after the set number of days

    .Parameter CommentsOnSitePagesDisabled

    .Parameter ConditionalAccessPolicy
        [sr-en] Conditional Access Policy usage in SharePoint Online

    .Parameter DefaultLinkPermission
        [sr-en] The default link permission for the site collection

    .Parameter DefaultSharingLinkType
        [sr-en] The default link type for the site collection

    .Parameter DenyAddAndCustomizePages
        [sr-en] Determines whether the Add And Customize Pages right is denied on the site collection

    .Parameter DisableAppViews
    
    .Parameter DisableCompanyWideSharingLinks

    .Parameter DisableFlows

    .Parameter LimitedAccessFileType

    .Parameter LocaleId
        [sr-en] Language of this site collection

    .Parameter LockState
        [sr-en] Sets the lock state on a site

    .Parameter NoWait
        [sr-en] Continue executing script immediately

    .Parameter OverrideTenantAnonymousLinkExpirationPolicy
        [sr-en] Choose whether to override the anonymous or anyone link expiration policy on this site
    
    .Parameter Owner
        [sr-en] Owner of the site collection
    
    .Parameter ResourceQuota
        [sr-en] Resource quota in megabytes of the site collection

    .Parameter ResourceQuotaWarningLevel
        [sr-en] Warning level in megabytes of the site collection to warn the site collection administrator that the site is approaching the resource quota

    .Parameter RestrictedToGeo

    .Parameter SandboxedCodeActivationCapability
 
    .Parameter SharingAllowedDomainList
        [sr-en] List of email domains that is allowed for sharing with the external collaborators

    .Parameter SharingBlockedDomainList
        [sr-en] List of email domains that is blocked or prohibited for sharing with the external collaborators

    .Parameter SharingCapability
        [sr-en] Determines what level of sharing is available for the site

    .Parameter SharingDomainRestrictionMode
        [sr-en] External sharing mode for domains

    .Parameter ShowPeoplePickerSuggestionsForGuestUsers
        [sr-en] To enable the option to search for existing guest users at Site Collection Level, set this parameter to $true

    .Parameter SocialBarOnSitePagesDisabled
        [sr-en] Disables or enables the Social Bar for Site Collection

    .Parameter StorageQuota
        [sr-en] Storage quota in megabytes of the site collection

    .Parameter StorageQuotaReset
        [sr-en] Resets the OneDrive for Business storage quota to the tenant’s new default storage space

    .Parameter StorageQuotaWarningLevel
        [sr-en] Warning level in megabytes of the site collection to warn the site collection administrator that the site is approaching the storage quota

    .Parameter Title
        [sr-en] Title of the site collection
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName="Common")]
    [Parameter(Mandatory = $true,ParameterSetName = "Enable PWA")]         
    [Parameter(Mandatory = $true,ParameterSetName = "Non owners")]        
    [Parameter(Mandatory = $true,ParameterSetName = "Remove label")]
    [string]$Identity, 
    [Parameter(Mandatory = $true,ParameterSetName = "Enable PWA")]
    [bool]$EnablePWA,
    [Parameter(Mandatory = $true,ParameterSetName = "Non owners")]
    [switch]$DisableSharingForNonOwners,
    [Parameter(Mandatory = $true,ParameterSetName = "Remove label")]
    [switch]$RemoveLabel,
    [Parameter(ParameterSetName="Common")]
    [bool]$AllowEditing,
    [Parameter(ParameterSetName="Common")]
    [bool]$AllowSelfServiceUpgrade,
    [Parameter(ParameterSetName="Common")]
    [int]$AnonymousLinkExpirationInDays,
    [Parameter(ParameterSetName="Common")]
    [bool]$CommentsOnSitePagesDisabled,
    [Parameter(ParameterSetName="Common")]
    [ValidateSet('AllowFullAccess','AllowLimitedAccess','BlockAccess')]
    [string]$ConditionalAccessPolicy,
    [Parameter(ParameterSetName="Common")]
    [ValidateSet('None','View','Edit')]
    [string]$DefaultLinkPermission,
    [Parameter(ParameterSetName="Common")]
    [ValidateSet('None','AnonymousAccess','Internal','Direct')]
    [string]$DefaultSharingLinkType,
    [Parameter(ParameterSetName="Common")]
    [bool]$DenyAddAndCustomizePages,
    [Parameter(ParameterSetName="Common")]
    [ValidateSet('Unknown','Disabled','NotDisabled')]
    [string]$DisableAppViews,
    [Parameter(ParameterSetName="Common")]
    [ValidateSet('Unknown','Disabled','NotDisabled')]
    [string]$DisableCompanyWideSharingLinks,
    [Parameter(ParameterSetName="Common")]
    [ValidateSet('Unknown','Disabled','NotDisabled')]
    [string]$DisableFlows,
    [Parameter(ParameterSetName="Common")]
    [ValidateSet('OfficeOnlineFilesOnly','WebPreviewableFiles','OtherFiles')]
    [string]$LimitedAccessFileType,
    [Parameter(ParameterSetName="Common")]
    [uint32]$LocaleId,
    [Parameter(ParameterSetName="Common")]
    [ValidateSet('NoAccess','ReadOnly','Unlock')]
    [string]$LockState,
    [Parameter(ParameterSetName="Common")]
    [switch]$NoWait,
    [Parameter(ParameterSetName="Common")]
    [bool]$OverrideTenantAnonymousLinkExpirationPolicy,
    [Parameter(ParameterSetName="Common")]
    [string]$Owner,
    [Parameter(ParameterSetName="Common")]
    [double]$ResourceQuota,
    [Parameter(ParameterSetName="Common")]
    [double]$ResourceQuotaWarningLevel,
    [Parameter(ParameterSetName="Common")]
    [ValidateSet('NoRestriction','ReadOnly','Unlock')]
    [string]$RestrictedToGeo,
    [Parameter(ParameterSetName="Common")]
    [ValidateSet('Unknown','Check','Disabled','Enabled')]
    [string]$SandboxedCodeActivationCapability,
    [Parameter(ParameterSetName="Common")]
    [string]$SharingAllowedDomainList,
    [Parameter(ParameterSetName="Common")]
    [string]$SharingBlockedDomainList,
    [Parameter(ParameterSetName="Common")]
    [ValidateSet('ExternalUserAndGuestSharing','Disabled','ExternalUserSharingOnly','ExistingExternalUserSharingOnly')]
    [string]$SharingCapability,
    [Parameter(ParameterSetName="Common")]
    [ValidateSet('None','AllowList','BlockList')]
    [string]$SharingDomainRestrictionMode,
    [Parameter(ParameterSetName="Common")]
    [bool]$ShowPeoplePickerSuggestionsForGuestUsers,
    [Parameter(ParameterSetName="Common")]
    [bool]$SocialBarOnSitePagesDisabled,
    [Parameter(ParameterSetName="Common")]
    [int64]$StorageQuota,
    [Parameter(ParameterSetName="Common")]
    [switch]$StorageQuotaReset,
    [Parameter(ParameterSetName="Common")]
    [int64]$StorageQuotaWarningLevel,
    [Parameter(ParameterSetName="Common")]
    [string]$Title
)

Import-Module Microsoft.Online.SharePoint.PowerShell

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Confirm' = $false
                            'Identity' = $Identity
                            }      
    
    If($PSCmdlet.ParameterSetName -eq 'Remove label'){
        $cmdArgs.Add('RemoveLabel',$RemoveLabel)
    }
    elseif ($PSCmdlet.ParameterSetName -eq 'Non owners'){
        $cmdArgs.Add('DisableSharingForNonOwners',$DisableSharingForNonOwners)
    }
    elseif($PSCmdlet.ParameterSetName -eq 'Enable PWA'){
        $cmdArgs.Add('EnablePWA',$EnablePWA)
    }
    else{
        if($PSBoundParameters.ContainsKey('AllowEditing')){
            $cmdArgs.Add('AllowEditing' , $AllowEditing)
        }
        if($PSBoundParameters.ContainsKey('AllowSelfServiceUpgrade')){
            $cmdArgs.Add('AllowSelfServiceUpgrade' , $AllowSelfServiceUpgrade)
        }
        if($PSBoundParameters.ContainsKey('CommentsOnSitePagesDisabled')){
            $cmdArgs.Add('CommentsOnSitePagesDisabled' , $CommentsOnSitePagesDisabled)
        }
        if($PSBoundParameters.ContainsKey('ConditionalAccessPolicy')){
            $cmdArgs.Add('ConditionalAccessPolicy' , $ConditionalAccessPolicy)
        }
        if($PSBoundParameters.ContainsKey('DefaultLinkPermission')){
            $cmdArgs.Add('DefaultLinkPermission' , $DefaultLinkPermission)
        }
        if($PSBoundParameters.ContainsKey('DefaultSharingLinkType')){
            $cmdArgs.Add('DefaultSharingLinkType' , $DefaultSharingLinkType)
        }
        if($PSBoundParameters.ContainsKey('DenyAddAndCustomizePages')){
            $cmdArgs.Add('DenyAddAndCustomizePages' , $DenyAddAndCustomizePages)
        }
        if($PSBoundParameters.ContainsKey('DisableAppViews')){
            $cmdArgs.Add('DisableAppViews' , $DisableAppViews)
        }
        if($PSBoundParameters.ContainsKey('DisableCompanyWideSharingLinks')){
            $cmdArgs.Add('DisableCompanyWideSharingLinks' , $DisableCompanyWideSharingLinks)
        }
        if($PSBoundParameters.ContainsKey('DisableFlows')){
            $cmdArgs.Add('DisableFlows' , $DisableFlows)
        }
        if($PSBoundParameters.ContainsKey('LockState')){
            $cmdArgs.Add('LockState' , $LockState)
        }
        if($PSBoundParameters.ContainsKey('NoWait')){
            $cmdArgs.Add('NoWait' , $NoWait)
        }
        if($PSBoundParameters.ContainsKey('OverrideTenantAnonymousLinkExpirationPolicy')){
            $cmdArgs.Add('OverrideTenantAnonymousLinkExpirationPolicy' , $OverrideTenantAnonymousLinkExpirationPolicy)
        }      
        if($PSBoundParameters.ContainsKey('Owner')){
            $cmdArgs.Add('Owner' , $Owner)
        }       
        if($PSBoundParameters.ContainsKey('RestrictedToGeo')){
            $cmdArgs.Add('RestrictedToGeo' , $RestrictedToGeo)
        }       
        if($PSBoundParameters.ContainsKey('SandboxedCodeActivationCapability')){
            $cmdArgs.Add('SandboxedCodeActivationCapability' , $SandboxedCodeActivationCapability)
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
        if($PSBoundParameters.ContainsKey('ShowPeoplePickerSuggestionsForGuestUsers')){
            $cmdArgs.Add('ShowPeoplePickerSuggestionsForGuestUsers' , $ShowPeoplePickerSuggestionsForGuestUsers)
        }          
        if($PSBoundParameters.ContainsKey('SocialBarOnSitePagesDisabled')){
            $cmdArgs.Add('SocialBarOnSitePagesDisabled' , $SocialBarOnSitePagesDisabled)
        }          
        if($PSBoundParameters.ContainsKey('StorageQuotaReset')){
            $cmdArgs.Add('StorageQuotaReset' , $StorageQuotaReset)
        }           
        if($PSBoundParameters.ContainsKey('Title')){
            $cmdArgs.Add('Title' , $Title)
        }  
        if($AnonymousLinkExpirationInDays -gt 0){
            $cmdArgs.Add('AnonymousLinkExpirationInDays' , $AnonymousLinkExpirationInDays)
        }
        if($LocaleId -gt 0){
            $cmdArgs.Add('LocaleId' , $LocaleId)
        }
        if($ResourceQuota -gt 0){
            $cmdArgs.Add('ResourceQuota' , $ResourceQuota)
        }
        if($ResourceQuotaWarningLevel -gt 0){
            $cmdArgs.Add('ResourceQuotaWarningLevel' , $ResourceQuotaWarningLevel)
        }
        if($StorageQuota -gt 0){
            $cmdArgs.Add('StorageQuota' , $StorageQuota)
        }
        if($StorageQuotaWarningLevel -gt 0){
            $cmdArgs.Add('StorageQuotaWarningLevel' , $StorageQuotaWarningLevel)
        }
    }

    $result = Set-SPOSite @cmdArgs | Select-Object *

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