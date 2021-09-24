#Requires -Version 5.0
#Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Copies files and folders from and to the guest OS

    .DESCRIPTION

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module VMware.VimAutomation.Core

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/VMware/VMs

    .Parameter VIServer
        [sr-en] IP address or the DNS name of the vSphere server to which you want to connect
        [sr-de] IP Adresse oder Name des vSphere Servers

    .Parameter VICredential
        [sr-en] PSCredential object that contains credentials for authenticating with the server
        [sr-de] Benutzerkonto um diese Aktion durchzuführen

    .Parameter VMName
        [sr-en] Name of the virtual machine where the file is located
        [sr-de] Name der VM der Datei

    .Parameter Source
        [sr-en] File name
        If the file is on a virtual machine, specifies the absolute file path. Relative file paths are supported only when copying files from a local storage. 
        [sr-de] Name der Datei
        Ist die Datei in einer VM, muss der absolute Pfad angegeben werden. Relative Pfade werden nur beim Kopieren vom lokalen System unterstützt

    .Parameter Destination
        [sr-en] Destination path
        If the path is on a virtual machine, specifies the absolute path. Relative paths are supported only when copying files from a local storage. 
        [sr-de] Zielpfad
        Ist das Ziel in einer VM, muss der absolute Pfad angegeben werden. Relative Pfade werden nur beim Kopieren zum lokalen System unterstützt

    .Parameter ToolsWaitSecs
        [sr-en] Time in seconds to wait for a response from the VMware Tools
        [sr-de] Sekunden, die auf eine Antwort von den VMware Tools gewartet wird

    .Parameter HostCredential
        [sr-en] PSCredential object that contains credentials for authenticating with the host where the file is to be copied
        [sr-de] Benutzerkonto, das Anmeldeinformationen für die Authentifizierung bei dem Host enthält, auf den die Datei kopiert werden soll
        
    .Parameter GuestCredential
        [sr-en] PSCredential object that contains credentials for authenticating with the guest OS where the file to be copied is located
        [sr-de] Benutzerkonto, das Anmeldedaten für die Authentifizierung beim Gastbetriebssystem enthält, in dem sich die zu kopierende Datei befindet

    .Parameter HostUser
        [sr-en] User name you want to use for authenticating with the host where the file is to be copied
        [sr-de] Benutzername für die Authentifizierung bei dem Host, auf den die Datei kopiert werden soll

    .Parameter GuestName
        [sr-en] User name you want to use for authenticating with the guest OS where the file to be copied is located
        [sr-de] Benutzername, für die Authentifizierung beim Gastbetriebssystem, in dem sich die zu kopierende Datei befindet

    .Parameter HostPassword
        [sr-en] Password you want to use for authenticating with the host where the file is to be copied
        [sr-de] Kennwort für die Authentifizierung bei dem Host, auf den die Datei kopiert werden soll

    .Parameter GuestName
        [sr-en] Password you want to use for authenticating with the guest OS where the file to be copied is located
        [sr-de] Kennwort, für die Authentifizierung beim Gastbetriebssystem, in dem sich die zu kopierende Datei befindet
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "LocalToGuest")]
    [Parameter(Mandatory = $true,ParameterSetName = "GuestToLocal")]
    [string]$VIServer,
    [Parameter(Mandatory = $true,ParameterSetName = "LocalToGuest")]
    [Parameter(Mandatory = $true,ParameterSetName = "GuestToLocal")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true,ParameterSetName = "LocalToGuest")]
    [Parameter(Mandatory = $true,ParameterSetName = "GuestToLocal")]
    [string]$VMName,
    [Parameter(Mandatory = $true,ParameterSetName = "LocalToGuest")]
    [Parameter(Mandatory = $true,ParameterSetName = "GuestToLocal")]
    [string]$Source,
    [Parameter(Mandatory = $true,ParameterSetName = "LocalToGuest")]
    [Parameter(Mandatory = $true,ParameterSetName = "GuestToLocal")]
    [string]$Destination,
    [int]$ToolsWaitSecs = 300,
    [pscredential]$HostCredential,
    [pscredential]$GuestCredential,
    [string]$HostUser,
    [string]$GuestUser,
    [securestring]$HostPassword,
    [securestring]$GuestPassword
)

Import-Module VMware.VimAutomation.Core

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Server' = $Script:vmServer
                            'Source' = $Source
                            'Destination' = $Destination
                            'Confirm' = $false
                            'Force' = $null
                            'ToolsWaitSecs' = $ToolsWaitSecs
    }       
    if($PSCmdlet.ParameterSetName  -eq "LocalToGuest"){
        $cmdArgs.Add("LocalToGuest",$null)
    }
    else{
        $cmdArgs.Add("GuestToLocal",$null)
    }
    $vm = Get-VM -VM $VMName -Server $Script:vmServer -ErrorAction Stop
    $cmdArgs.Add('VM',$vm)
    if($PSBoundParameters.ContainsKey('HostCredential') -eq $true){
        $cmdArgs.Add('HostCredential',$HostCredential)
    }
    if($PSBoundParameters.ContainsKey('HostPassword') -eq $true){
        $cmdArgs.Add('HostPassword',$HostPassword)
    }
    if($PSBoundParameters.ContainsKey('HostUser') -eq $true){
        $cmdArgs.Add('HostUser',$HostUser)
    }
    if($PSBoundParameters.ContainsKey('GuestCredential') -eq $true){
        $cmdArgs.Add('GuestCredential',$GuestCredential)
    }
    if($PSBoundParameters.ContainsKey('GuestUser') -eq $true){
        $cmdArgs.Add('GuestUser',$GuestUser)
    }
    if($PSBoundParameters.ContainsKey('GuestUser') -eq $true){
        $cmdArgs.Add('GuestUser',$GuestUser)
    }

    $result = Copy-VMGuestFile @cmdArgs
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
    if($null -ne $Script:vmServer){
        Disconnect-VIServer -Server $Script:vmServer -Force -Confirm:$false
    }
}