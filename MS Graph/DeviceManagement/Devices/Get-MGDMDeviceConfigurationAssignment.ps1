#Requires -Version 5.0
#requires -Modules Microsoft.Graph.DeviceManagement 

<#
    .SYNOPSIS        
        Get assignments from device management

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

    .Parameter ConfigurationId 
        [sr-en] Id of device category
        [sr-de] Id der Device Kategorie

    .Parameter AssignmentId 
        [sr-en] Id of device configuration assignment
        [sr-de] Id der Device Konfigurationszuweisung
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$ConfigurationId,
    [string]$AssignmentId
)

Import-Module Microsoft.Graph.DeviceManagement 

try{
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                'DeviceConfigurationId' = $ConfigurationId
    }
    if($PSBoundParameters.ContainsKey('AssignmentId') -eq $true){
        $cmdArgs.Add('DeviceConfigurationAssignmentId',$AssignmentId)
    }
    else{
        $cmdArgs.Add('All',$null)
    }

    $result = Get-MgDeviceManagementDeviceConfigurationAssignment @cmdArgs | Select-Object *

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