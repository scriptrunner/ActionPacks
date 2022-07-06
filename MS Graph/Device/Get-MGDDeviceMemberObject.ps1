#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Identity.DirectoryManagement

<#
    .SYNOPSIS
        Returns member objects for the device
    
    .DESCRIPTION          

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Library script MS Graph\_LIB_\MGLibrary
        Requires Modules Microsoft.Graph.Identity.DirectoryManagement

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/MS%20Graph/Device

    .Parameter DeviceId
        [sr-en] Identifier of the device
        [sr-de] Geräte-ID

    .Parameter SecurityEnabledOnly
        [sr-en] Member must be a user or service principal
        [sr-de] Mitglied muss ein Benutzer oder Service principal sein
#>

param( 
    [parameter(Mandatory = $true)]
    [string]$DeviceId,
    [switch]$SecurityEnabledOnly
)          
   
Import-Module Microsoft.Graph.Identity.DirectoryManagement

try{
    ConnectMSGraph 
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                'DeviceId' = $DeviceId
                'SecurityEnabledOnly' = $SecurityEnabledOnly.IsPresent
    }
    $result = Get-MgDeviceMemberObject @cmdArgs | Select-Object *

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
    DisconnectMSGraph
}