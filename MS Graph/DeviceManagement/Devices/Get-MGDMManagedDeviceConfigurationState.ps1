#Requires -Version 5.0
#requires -Modules Microsoft.Graph.DeviceManagement 

<#
    .SYNOPSIS        
        Get device configuration states from device management

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

    .Parameter ConfigurationId 
        [sr-en] Id of device configuration state
        [sr-de] Id des Device Konfiguration Status
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$DeviceId,
    [string]$ConfigurationId
)

Import-Module Microsoft.Graph.DeviceManagement 

try{
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                'ManagedDeviceId' = $DeviceId
    }

    if($PSBoundParameters.ContainsKey('ConfigurationId') -eq $true){
        $cmdArgs.Add('DeviceConfigurationId',$ConfigurationId)
    }
    else{
        $cmdArgs.Add('All',$null)
    }
    $result = Get-MgDeviceManagementManagedDeviceConfigurationState @cmdArgs | Select-Object *
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