#Requires -Version 5.0
#requires -Modules Microsoft.Graph.DeviceManagement 

<#
    .SYNOPSIS        
        Update the navigation property device categories in device management

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

    .Parameter CategoryId
        [sr-en] Id of device category
        [sr-de] Id der Device Kategorie

    .Parameter CategoryName
        [sr-en] Name of the device management category
        [sr-de] Name der Device Management Kategorie

    .Parameter Description
        [sr-en] Description of the device management category
        [sr-de] Beschreibung der Device Management Kategorie
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$CategoryId,
    [string]$CategoryName,
    [string]$Description
)

Import-Module Microsoft.Graph.DeviceManagement 

try{
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                            'DeviceCategoryId' = $CategoryId
                            'Confirm' = $false
                            'PassThru' = $null
    }
    if($PSBoundParameters.ContainsKey('CategoryName') -eq $true){
        $cmdArgs.Add('DisplayName',$CategoryName)
    }
    if($PSBoundParameters.ContainsKey('Description') -eq $true){
        $cmdArgs.Add('Description',$Description)
    }
    $null = Update-MgDeviceManagementDeviceCategory @cmdArgs

    $result = Get-MgDeviceManagementDeviceCategory -DeviceCategoryId $CategoryId -ErrorAction Stop | Select-Object *
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