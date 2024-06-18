#Requires -Version 5.0
# Requires -Modules VMware.VimAutomation.Core

<#
    .SYNOPSIS
        Creates a new resource pool

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
        https://github.com/scriptrunner/ActionPacks/tree/master/VMware/ResourcePool

    .Parameter VIServer
        [sr-en] IP address or the DNS name of the vSphere server to which you want to connect
        [sr-de] IP Adresse oder DNS des vSphere Servers

    .Parameter VICredential
        [sr-en] PSCredential object that contains credentials for authenticating with the server
        [sr-de] Benutzerkonto für die Ausführung

    .Parameter Name
        [sr-en] Name for the new resource pool
        [sr-de] Name des Ressourcen Pool

    .Parameter VMHost
        [sr-en] Host on which you want to create the new resource pool
        [sr-de] Host

    .Parameter CpuExpandableReservation
        [sr-en] CPU reservation can grow beyond the specified value if the parent resource pool has unreserved resources
        [sr-de] CPU-Reservierung kann über den angegebenen Wert hinausgehen

    .Parameter CpuLimitMhz
        [sr-en] CPU usage limit in MHz
        [sr-de] CPU Limit in Mhz

    .Parameter CpuReservationMhz
        [sr-en] CPU size in MHz that is guaranteed to be available
        [sr-de] CPU Größe in Mhz

    .Parameter CpuSharesLevel
        [sr-en] CPU allocation level for this pool
        [sr-de] Ebene der CPU-Zuweisung

    .Parameter MemExpandableReservation
        [sr-en] If the value is $true, the memory reservation can grow beyond the specified value if the parent resource pool has unreserved resources
        [sr-de] Speicherreservierung über den angegebenen Wert hinaus wachsen

    .Parameter MemLimitGB
        [sr-en] Memory usage limit in gigabytes (GB)
        [sr-de] Mindest verfügbarer Speicher in Gigabyte

    .Parameter MemReservationGB
        [sr-en] Guaranteed available memory in gigabytes (GB)
        [sr-de] Garantierte Speicher in Gigabyte

    .Parameter MemSharesLevel
        [sr-en] Memory allocation level for this pool
        [sr-de] Ebene der Speicherzuweisung

    .Parameter NumCpuShares
        [sr-en] CPU allocation level for this pool
        [sr-de] Ebene der CPU-Zuweisung

    .Parameter NumMemShares
        [sr-en] Memory allocation level for this pool
        [sr-de] Ebene der Speicherzuweisung
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$VIServer,
    [Parameter(Mandatory = $true)]
    [pscredential]$VICredential,
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [Parameter(Mandatory = $true)]
    [string]$VMHost,
    [bool]$CpuExpandableReservation,
    [int64]$CpuLimitMhz,
    [int64]$CpuReservationMhz,
    [ValidateSet("Custom", "High", "Low","Normal")]
    [string]$CpuSharesLevel,
    [bool]$MemExpandableReservation,
    [decimal]$MemLimitGB,
    [decimal]$MemReservationGB,
    [ValidateSet("Custom", "High", "Low","Normal")]
    [string]$MemSharesLevel,
    [int32]$NumCpuShares,
    [int32]$NumMemShares
)

Import-Module VMware.VimAutomation.Core

try{
    $Script:vmServer = Connect-VIServer -Server $VIServer -Credential $VICredential -ErrorAction Stop

    $Script:pool = New-ResourcePool -Server $Script:vmServer -Location $VMHost -Name $Name -Confirm:$false -ErrorAction Stop
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Server' = $Script:vmServer
                            'ResourcePool' = $Script:pool
                            'Confirm' = $false
                            }                            

    if($PSBoundParameters.ContainsKey('CpuExpandableReservation') -eq $true){
        $Script:pool = Set-ResourcePool @cmdArgs -CpuExpandableReservation $CpuExpandableReservation
    }
    if($PSBoundParameters.ContainsKey('CpuLimitMhz') -eq $true){
        $Script:pool = Set-ResourcePool @cmdArgs -CpuLimitMhz $CpuLimitMhz
    }
    if($PSBoundParameters.ContainsKey('CpuReservationMhz') -eq $true){
        $Script:pool = Set-ResourcePool @cmdArgs -CpuReservationMhz $CpuReservationMhz
    }
    if($PSBoundParameters.ContainsKey('CpuSharesLevel') -eq $true){
        $Script:pool = Set-ResourcePool @cmdArgs -CpuSharesLevel $CpuSharesLevel
    }
    if($PSBoundParameters.ContainsKey('MemExpandableReservation') -eq $true){
        $Script:pool = Set-ResourcePool @cmdArgs -MemExpandableReservation $MemExpandableReservation
    }
    if($PSBoundParameters.ContainsKey('MemLimitGB') -eq $true){
        $Script:pool = Set-ResourcePool @cmdArgs -MemLimitGB $MemLimitGB
    }
    if($PSBoundParameters.ContainsKey('MemReservationGB') -eq $true){
        $Script:pool = Set-ResourcePool @cmdArgs -MemReservationGB $MemReservationGB
    }
    if($PSBoundParameters.ContainsKey('MemSharesLevel') -eq $true){
        $Script:pool = Set-ResourcePool @cmdArgs -MemSharesLevel $MemSharesLevel
    }
    if($PSBoundParameters.ContainsKey('NumCpuShares') -eq $true){
        $Script:pool = Set-ResourcePool @cmdArgs -NumCpuShares $NumCpuShares
    }
    if($PSBoundParameters.ContainsKey('NumMemShares') -eq $true){
        $Script:pool = Set-ResourcePool @cmdArgs -NumMemShares $NumMemShares
    }
   
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:pool | Select-Object * 
    }
    else{
        Write-Output $Script:pool | Select-Object *
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