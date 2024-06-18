#Requires -Version 5.0
#requires -Modules Microsoft.Graph.DeviceManagement 

<#
    .SYNOPSIS        
        Get User Statuses from Device Management

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
        https://github.com/scriptrunner/ActionPacks/tree/master/MS%20Graph/DeviceManagement/Policies

    .Parameter PolicyId
        [sr-en] Id of device management compliance policy
        [sr-de] Id der Device Management Compliance Policy

    .Parameter UserStatusId 
        [sr-en] Id of device compliance user status
        [sr-de] Id des Gerätekonformität Benutzerstatus
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$PolicyId,
    [string]$UserStatusId 
)

Import-Module Microsoft.Graph.DeviceManagement 

try{
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                        'DeviceCompliancePolicyId' = $PolicyId
    }

    if($PSBoundParameters.ContainsKey('UserStatusId') -eq $true){
        $cmdArgs.Add('DeviceComplianceUserStatusId',$UserStatusId)
    }
    else{
        $cmdArgs.Add('All',$null)
    }
    $result = Get-MgDeviceManagementDeviceCompliancePolicyUserStatuses @cmdArgs | Select-Object *

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