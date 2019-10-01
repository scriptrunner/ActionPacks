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
        ScriptRunner Version 4.2.x or higher

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/O365/SharePointOnline/Sites

    .Parameter Identity
        Specifies the URL of the site collection to update

    .Parameter RemoveLabel

    .Parameter DisableSharingForNonOwners
        This parameter prevents non-owners from invited new users to the site

    .Parameter EnablePWA
        Determines whether site can include Project Web App

    .Parameter AllowEditing
        Prevents users from editing Office files in the browser and copying and pasting Office file contents out of the browser window

    .Parameter AllowSelfServiceUpgrade
        Determines whether site collection administrators can upgrade their site collections

    .Parameter AnonymousLinkExpirationInDays
        Specifies all anonymous/anyone links that have been created (or will be created) will expire after the set number of days

    .Parameter CommentsOnSitePagesDisabled

    .Parameter ConditionalAccessPolicy
        Conditional Access Policy usage in SharePoint Online

    .Parameter DefaultLinkPermission
        The default link permission for the site collection

    .Parameter DefaultSharingLinkType
        The default link type for the site collection

    .Parameter DenyAddAndCustomizePages
        Determines whether the Add And Customize Pages right is denied on the site collection

    .Parameter DisableAppViews
    
    .Parameter DisableCompanyWideSharingLinks

    .Parameter DisableFlows

    .Parameter LimitedAccessFileType

    .Parameter LocaleId
        Specifies the language of this site collection

    .Parameter LockState
        Sets the lock state on a site

    .Parameter NoWait
        Specifies to continue executing script immediately

    .Parameter OverrideTenantAnonymousLinkExpirationPolicy
        Choose whether to override the anonymous or anyone link expiration policy on this site
    
    .Parameter Owner
        Specifies the owner of the site collection
    
    .Parameter ResourceQuota
        Specifies the resource quota in megabytes of the site collection

    .Parameter ResourceQuotaWarningLevel
        Specifies the warning level in megabytes of the site collection to warn the site collection administrator that the site is approaching the resource quota

    .Parameter RestrictedToGeo

    .Parameter SandboxedCodeActivationCapability
 
    .Parameter SharingAllowedDomainList
        Specifies a list of email domains that is allowed for sharing with the external collaborators

    .Parameter SharingBlockedDomainList
        Specifies a list of email domains that is blocked or prohibited for sharing with the external collaborators

    .Parameter SharingCapability
        Determines what level of sharing is available for the site

    .Parameter SharingDomainRestrictionMode
        Specifies the external sharing mode for domains

    .Parameter ShowPeoplePickerSuggestionsForGuestUsers
        To enable the option to search for existing guest users at Site Collection Level, set this parameter to $true

    .Parameter SocialBarOnSitePagesDisabled
        Disables or enables the Social Bar for Site Collection

    .Parameter StorageQuota
        Specifies the storage quota in megabytes of the site collection

    .Parameter StorageQuotaReset
        Resets the OneDrive for Business storage quota to the tenant’s new default storage space

    .Parameter StorageQuotaWarningLevel
        Specifies the warning level in megabytes of the site collection to warn the site collection administrator that the site is approaching the storage quota

    .Parameter Title
        Specifies the title of the site collection
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