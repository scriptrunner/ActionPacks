#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Identity.DirectoryManagement

<#
    .SYNOPSIS
        Returns entities from devices
    
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

    .Parameter Properties
        [sr-en] List of properties to expand. Use * for all properties
        [sr-de] Liste der zu anzuzeigenden Eigenschaften. Verwenden Sie * für alle Eigenschaften
#>

param( 
    [string]$DeviceId,
    [ValidateSet('DisplayName','Id','AccountEnabled','ApproximateLastSignInDateTime','ComplianceExpirationDateTime','DeletedDateTime',
                'DeviceId','DeviceVersion','IsCompliant','IsManaged','OnPremisesLastSyncDateTime','OnPremisesLastSyncDateTime',
                'OnPremisesSyncEnabled','OperatingSystem','OperatingSystemVersion','ProfileType','RegisteredOwners','RegisteredUsers','TrustType')]
    [string[]]$Properties = @('DisplayName','Id','AccountEnabled','OperatingSystem','DeviceId')
)          
   
Import-Module Microsoft.Graph.Identity.DirectoryManagement

try{
    ConnectMSGraph 
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'}
    if($PSBoundParameters.ContainsKey('DeviceId') -eq $true){
        $cmdArgs.Add('DeviceId',$DeviceId)
    }
    $result = Get-MgDevice @cmdArgs | Sort-Object DisplayName | Select-Object $Properties

    if (Get-Command 'ConvertTo-ResultHtml' -ErrorAction Ignore) {
        ConvertTo-ResultHtml -Result $result
    }
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