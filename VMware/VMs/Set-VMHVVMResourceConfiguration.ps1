#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Configures resource allocation between the virtual machine

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
        [sr-de] IP-Adresse oder DNS des vSphere Servers

    .Parameter VICredential
        [sr-en] PSCredential object that contains credentials for authenticating with the server
        [sr-de] Anmeldedaten für die Authentifizierung beim Server
        
    .Parameter VMId
        [sr-en] ID of the virtual machine
        [sr-de] ID der VM

    .Parameter VMName
        [sr-en] Name of the virtual machine
        [sr-de] Name der VM

    .Parameter DiskName
        [sr-en] Name of the virtual hard disk you want to configure
        [sr-de] Name der Disk

    .Parameter CpuLimitMhz
        [sr-en] Limit on CPU usage in MHz
        [sr-de] Begrenzung der CPU-Nutzung in MHz

    .Parameter CpuReservationMhz
        [sr-en] Number of CPU MHz that are guaranteed to be available
        [sr-de] Garantierte Anzahl der CPU-MHz

    .Parameter CpuSharesLevel
        [sr-en] CPU allocation level
        [sr-de] CPU-Zuordnungsebene

    .Parameter MemLimitGB
        [sr-en] Memory usage limit in gigabytes
        [sr-de] Speicher Limit in Gigabyte

    .Parameter MemReservationGB
        [sr-en] Guaranteed available memory in gigabytes 
        [sr-de] Garantiert verfügbarer Speicher in Gigabyte

    .Parameter MemSharesLevel
        [sr-en] Memory allocation level for this pool
        [sr-de] Speicher-Zuordnungsebene für diesen Pool

    .Parameter NumCpuShares
        [sr-en] CPU allocation level for this pool
        [sr-de] CPU-Zuordnungsebene für diesen Pool

    .Parameter NumMemShares
        [sr-en] Number of memory shares allocated
        [sr-de] Anzahl der zugewiesenen Speicheranteile
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
    [string]$VMId,
    [Parameter(Mandatory = $true,ParameterSetName = "byName")]
    [string]$VMName,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [string]$DiskName,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [int64]$CpuLimitMhz,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [int64]$CpuReservationMhz,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [ValidateSet("Custom", "High", "Low", "Normal")]
    [string]$CpuSharesLevel,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [decimal]$MemLimitGB,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [decimal]$MemReservationGB,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [ValidateSet("Custom", "High", "Low", "Normal")]
    [string]$MemSharesLevel,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [int32]$NumCpuShares,
    [Parameter(ParameterSetName = "byID")]
    [Parameter(ParameterSetName = "byName")]
    [int32]$NumMemShares

)

Import-Module VMware.VimAutomation.Core

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    if($PSCmdlet.ParameterSetName  -eq "byID"){
        $Script:machine = Get-VM -Server $Script:vmServer -Id $VMId -ErrorAction Stop
    }
    else{
        $Script:machine = Get-VM -Server $Script:vmServer -Name $VMName -ErrorAction Stop
    }
    $Script:disk = $null
    $Script:resConfig = Get-VMResourceConfiguration -Server $Script:vmServer -VM $Script:machine -ErrorAction Stop
    if([System.String]::IsNullOrWhiteSpace($DiskName) -eq $false){
        $Script:disk = Get-HardDisk -VM $Script:machine -Name $DiskName -Server $Script:vmServer -ErrorAction Stop
    }
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Configuration' = $Script:resConfig                            
                            'Confirm' = $false}
                            
    if($null -ne $Script:disk){
        $cmdArgs.Add('Disk' , $Script:disk)
    }
    if($PSBoundParameters.ContainsKey('CpuLimitMhz') -eq $true){
        $Script:resConfig = Set-VMResourceConfiguration $cmdArgs -CpuLimitMhz $CpuLimitMhz
    }
    if($PSBoundParameters.ContainsKey('CpuReservationMhz') -eq $true){
        $Script:resConfig = Set-VMResourceConfiguration $cmdArgs -CpuReservationMhz $CpuReservationMhz
    }
    if($PSBoundParameters.ContainsKey('CpuSharesLevel') -eq $true){
        $Script:resConfig = Set-VMResourceConfiguration $cmdArgs -CpuSharesLevel $CpuSharesLevel
    }
    if($PSBoundParameters.ContainsKey('MemLimitGB') -eq $true){
        $Script:resConfig = Set-VMResourceConfiguration $cmdArgs -MemLimitGB $MemLimitGB
    }
    if($PSBoundParameters.ContainsKey('MemReservationGB') -eq $true){
        $Script:resConfig = Set-VMResourceConfiguration $cmdArgs -MemReservationGB $MemReservationGB
    }
    if($PSBoundParameters.ContainsKey('MemSharesLevel') -eq $true){
        $Script:resConfig = Set-VMResourceConfiguration $cmdArgs -MemSharesLevel $MemSharesLevel
    }
    if($PSBoundParameters.ContainsKey('NumCpuShares') -eq $true){
        $Script:resConfig = Set-VMResourceConfiguration $cmdArgs -NumCpuShares $NumCpuShares
    }
    if($PSBoundParameters.ContainsKey('NumMemShares') -eq $true){        
        $Script:resConfig = Set-VMResourceConfiguration $cmdArgs -NumMemShares $NumMemShares
    }

    if($SRXEnv) {
        $SRXEnv.ResultMessage = ($Script:resConfig | Select-Object *)
    }
    else{
        Write-Output ($Script:resConfig | Select-Object *)
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