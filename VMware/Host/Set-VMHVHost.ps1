#Requires -Version 4.0
# Requires -Modules VMware.PowerCLI

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
    Requires Module VMware.PowerCLI

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/VMware/Host

.Parameter VIServer
    Specifies the IP address or the DNS name of the vSphere server to which you want to connect

.Parameter VICredential
    Specifies a PSCredential object that contains credentials for authenticating with the server

.Parameter ID
    Specifies the ID of the host you want to modify

.Parameter Name
    Specifies the name of the host you want to modify

.Parameter State
    Specifies the state of the host

.Parameter Evacuate
     the value is $true, vCenter automatically reregisters the virtual machines that are compatible for reregistration

.Parameter LicenseKey
    Specifies the license key to be used by the host

.Parameter TimeZoneName
    Specifies the time zone for the host by using its name
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

Import-Module VMware.PowerCLI

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