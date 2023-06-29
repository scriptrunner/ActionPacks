#Requires -Version 5.0
#requires -Modules Microsoft.Graph.DeviceManagement 

<#
    .SYNOPSIS        
        Get managed devices from device management

    .DESCRIPTION          

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Modules Microsoft.Graph.DeviceManagement 

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/MS%20Graph/DeviceManagement/Devices

    .Parameter DeviceId
        [sr-en] Id of the managed device
        [sr-de] Id des Geräts

    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param( 
    [string]$DeviceId,
    [ValidateSet('ActivationLockBypassCode','AndroidSecurityPatchLevel','AzureAdDeviceId','AzureAdRegistered',
                'ComplianceGracePeriodExpirationDateTime','ComplianceState','DeviceActionResults','DeviceCategoryDisplayName','DeviceCompliancePolicyStates',
                'DeviceConfigurationStates','DeviceEnrollmentType','DeviceName','DeviceRegistrationState','EasActivated','EasActivationDateTime','EasDeviceId',
                'EmailAddress','EnrolledDateTime','EthernetMacAddress','ExchangeAccessState','ExchangeAccessStateReason','ExchangeLastSuccessfulSyncDateTime',
                'FreeStorageSpaceInBytes','Iccid','Id','Imei','IsEncrypted','IsSupervised','JailBroken','LastSyncDateTime','ManagedDeviceName','ManagedDeviceOwnerType',
                'ManagementAgent','Manufacturer','Meid','Model','Notes','OSVersion','OperatingSystem','PartnerReportedThreatState','PhoneNumber','PhysicalMemoryInBytes',
                'RemoteAssistanceSessionErrorDetails','RemoteAssistanceSessionUrl','SerialNumber','SubscriberCarrier','TotalStorageSpaceInBytes','Udid',
                'UserDisplayName','UserId','UserPrincipalName','WiFiMacAddress')]
    [string[]]$Properties = @('DeviceName','Id','Manufacturer','DeviceRegistrationState','IsEncrypted')
)

Import-Module Microsoft.Graph.DeviceManagement 

try{
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'}
    if($PSBoundParameters.ContainsKey('DeviceId') -eq $true){
        $cmdArgs.Add('ManagedDeviceId',$DeviceId)
    }

    $result = Get-MgDeviceManagementManagedDevice @cmdArgs | Select-Object *
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $result
    }
    else{
        Write-Output $result
    }
}
catch{
    throw 
}
finally{
}