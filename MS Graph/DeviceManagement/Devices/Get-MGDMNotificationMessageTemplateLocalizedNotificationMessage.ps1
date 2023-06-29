#Requires -Version 5.0
#requires -Modules Microsoft.Graph.DeviceManagement 

<#
    .SYNOPSIS        
        Get localized notification messages from device management

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

    .Parameter MessageId 
        [sr-en] Id of localized notification message 
        [sr-de] Id der Benachrichtigungsmeldung

    .Parameter TemplateId
        [sr-en] Id of notification message template 
        [sr-de] Id der Vorlage für Benachrichtigungsmeldungen
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$TemplateId,
    [string]$MessageId
)

Import-Module Microsoft.Graph.DeviceManagement 

try{
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
            'NotificationMessageTemplateId' = $TemplateId
    }
    if($PSBoundParameters.ContainsKey('MessageId') -eq $true){
        $cmdArgs.Add('LocalizedNotificationMessageId',$MessageId)
    }
    else{
        $cmdArgs.Add('All',$null)
    }

    $result = Get-MgDeviceManagementNotificationMessageTemplateLocalizedNotificationMessage @cmdArgs | Select-Object *

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