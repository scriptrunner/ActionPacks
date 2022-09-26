#Requires -Version 5.0
#requires -Modules Microsoft.Graph.Identity.DirectoryManagement

<#
    .SYNOPSIS
        Updates the device
    
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

    .Parameter AccountEnabled
        [sr-en] The account is enabled
        [sr-de] Geräte-Konto ist aktiv

    .Parameter IsCompliant
        [sr-en] Device complies with Mobile Device Management (MDM) policies
        [sr-de] Gerät entspricht den Richtlinien für Mobile Device Management (MDM)

    .Parameter IsManaged
        [sr-en] Device is managed by a Mobile Device Management (MDM) app
        [sr-de] Gerät wird von einer Mobile Device Management (MDM)-App verwaltet

    .Parameter DisplayName
        [sr-en] Display name for the device
        [sr-de] Anzeigenamen des Geräts

    .Parameter DeviceVersion
        [sr-en] Version of the device
        [sr-de] Version des Geräts

    .Parameter OperatingSystem
        [sr-en] Operating system
        [sr-de] Betriebssystem

    .Parameter OperatingSystemVersion
        [sr-en] Version of the operating system
        [sr-de] Betriebssystemversion

    .Parameter ProfileType
        [sr-en] Profile type of the device
        [sr-de] Profil-Typ des Geräts
#>

param( 
    [Parameter(Mandatory= $true)]
    [string]$DeviceId,
    [switch]$AccountEnabled,
    [bool]$IsCompliant,
    [bool]$IsManaged,
    [string]$DisplayName,
    [string]$DeviceVersion,
    [string]$OperatingSystem,
    [string]$OperatingSystemVersion,
    [ValidateSet('RegisteredDevice','SecureVM','Printer','Shared','IoT')]
    [string]$ProfileType = 'RegisteredDevice'
)          
   
Import-Module Microsoft.Graph.Identity.DirectoryManagement

try{
    ConnectMSGraph 
    [hashtable]$cmdArgs = @{ErrorAction = 'Stop'
                        'PassThru' = $null
                        'Confirm' = $false
                        'DeviceId' = $DeviceId
                        'ProfileType' = $ProfileType
    }
    if($AccountEnabled.IsPresent){
        $cmdArgs.Add('AccountEnabled',$null)
    }
    if($PSBoundParameters.ContainsKey('IsCompliant') -eq $true){
        $cmdArgs.Add('IsCompliant',$IsCompliant)
    }
    if($PSBoundParameters.ContainsKey('IsManaged') -eq $true){
        $cmdArgs.Add('IsManaged',$IsManaged)
    }
    if($PSBoundParameters.ContainsKey('DisplayName') -eq $true){
        $cmdArgs.Add('DisplayName',$DisplayName)
    }
    if($PSBoundParameters.ContainsKey('DeviceVersion') -eq $true){
        $cmdArgs.Add('DeviceVersion',$DeviceVersion)
    }
    if($PSBoundParameters.ContainsKey('OperatingSystem') -eq $true){
        $cmdArgs.Add('OperatingSystem',$OperatingSystem)
    }
    if($PSBoundParameters.ContainsKey('OperatingSystemVersion') -eq $true){
        $cmdArgs.Add('OperatingSystemVersion',$OperatingSystemVersion)
    }
    $null = Update-MgDevice @cmdArgs 

    $result = Get-MgDevice -DeviceId $DeviceId -ErrorAction Stop | Select-Object *
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