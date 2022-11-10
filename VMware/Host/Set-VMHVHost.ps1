#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Modifies the configuration of the host

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
        https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Host

    .Parameter VIServer
        [sr-en] IP address or the DNS name of the vSphere server to which you want to connect
        [sr-de] IP Adresse oder DNS des vSphere Servers

    .Parameter VICredential
        [sr-en] PSCredential object that contains credentials for authenticating with the server
        [sr-de] Benutzerkonto für die Ausführung

    .Parameter ID
        [sr-en] ID of the host you want to modify
        [sr-de] Id des Host
        
    .Parameter Name
        [sr-en] Name of the host you want to modify
        [sr-de] Hostname

    .Parameter State
        [sr-en] State of the host
        [sr-de] Status des Hosts

    .Parameter Evacuate
        [sr-en] If the value is $true, vCenter automatically reregisters the virtual machines that are compatible for reregistration
        [sr-de] Erneute Registrierung aktivieren

    .Parameter LicenseKey
        [sr-en] License key to be used by the host
        [sr-de] Lizenz

    .Parameter TimeZoneName
        [sr-en] Time zone for the host by using its name
        [sr-de] Zeitzone des Hosts
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [string]$VIServer,
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true,ParameterSetName = "byID")]
    [string]$ID,
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [string]$Name,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [ValidateSet("Connected", "Disconnected","Maintenance")]
    [string]$State,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [switch]$Evacuate,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [string]$LicenseKey,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [string]$TimeZoneName
)

Import-Module VMware.VimAutomation.Core

try{
    [string[]]$Properties = @('Name','Id','PowerState','ConnectionState','IsStandalone','LicenseKey')
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Server' = $Script:vmServer
                            }                                
    if($PSCmdlet.ParameterSetName  -eq "byID"){
        $Script:vmHost = Get-VMHost @cmdArgs -ID $ID
    }
    else{
        $Script:vmHost = Get-VMHost cmdArgs -Name $Name
    }
    $cmdArgs.Add('VMHost', $Script:vmHost)
    $cmdArgs.Add('Confirm', $false)
    if($PSBoundParameters.ContainsKey('State') -eq $true){
        $null = Set-VMHost @cmdArgs -State $State
    }
    if($PSBoundParameters.ContainsKey('LicenseKey') -eq $true){
        $null = Set-VMHost  @cmdArgs -LicenseKey $LicenseKey
    }
    if($PSBoundParameters.ContainsKey('TimeZoneName') -eq $true){
        $timezone = Get-VMHostAvailableTimeZone -Server $Script:vmServer -Name $TimeZoneName -ErrorAction Stop
        $null = Set-VMHost @cmdArgs -TimeZone $timezone
    }
    if($PSBoundParameters.ContainsKey('Evacuate') -eq $true){
        $null = Set-VMHost @cmdArgs $Script:vmHost -Evacuate:$Evacuate
    }
    
    $result = Get-VMHost -Server $Script:vmServer -Name $Name -NoRecursion:$true -ErrorAction Stop | Select-Object $Properties
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