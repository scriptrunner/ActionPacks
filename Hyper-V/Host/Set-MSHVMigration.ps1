#Requires -Version 4.0
#Requires -Modules Hyper-V

<#
    .SYNOPSIS
        Enables/disables and configure migration on the Hyper-V host
    
    .DESCRIPTION  
        Use "Win2K12R2 or Win8.x" for execution on Windows Server 2012 R2 or on Windows 8.1,
        when execute on Windows Server 2016 / Windows 10 or newer, use "Newer Systems"

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
        © AppSphere AG

    .COMPONENT
        Requires Module Hyper-V

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/Hyper-V/Host
    
    .Parameter VMHostName
        Specifies the name of the Hyper-V host

    .Parameter HostName
        Specifies the name of the Hyper-V host

    .Parameter AccessAccount
        Specifies the user account that have permission to perform this action

    .Parameter Action
        Enables/disables the migration

    .Parameter MaxVirtualMachineMigrations
        Specifies the maximum number of live migrations that can be performed at the same time on the Hyper-V host

    .Parameter EnableUseAnyNetworkForMigration
        Specifies how networks are selected for incoming live migration traffic. 
        If set to $TRUE, any available network on the host can be used for this traffic. 
        If set to $FALSE, incoming live migration traffic is transmitted only on the networks specified in the MigrationNetworks property of the host

    .Parameter VMMigrationAuthenticationType
        Specifies the type of authentication to be used for live migrations

    .Parameter VMMigrationPerformanceOption
        Specifies the performance option to use for live migration

    .Parameter NetworksToAdd
        Specifies a string representing one or more IPv4 or IPv6 subnet masks that specifies the networks to be added for virtual machine migration. 
        Use comma to separate the addresses

    .Parameter NetworksToRemove
        Specifies a string representing one or more IPv4 or IPv6 subnet masks that specifies the networks to be removed from virtual machine migration. 
        Use comma to separate the addresses
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = "Win2K12R2 or Win8.x")]
    [string]$VMHostName,
    [Parameter(ParameterSetName = "Newer Systems")]
    [string]$HostName,
    [Parameter(ParameterSetName = "Newer Systems")]
    [PSCredential]$AccessAccount,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [ValidateSet('Enable','Disable')]
    [string]$Action = "Enable",
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [int]$MaxVirtualMachineMigrations,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [bool]$EnableUseAnyNetworkForMigration,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [ValidateSet('CredSSP', 'Kerberos')]
    [string]$VMMigrationAuthenticationType = "CredSSP",
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [ValidateSet('TCPIP', 'Compression', 'SMB')]
    [string]$VMMigrationPerformanceOption = "TCPIP",
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [string]$NetworksToAdd,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [string]$NetworksToRemove
)

Import-Module Hyper-V

try {
    [string[]]$Script:addAddr = @()
    [string[]]$Script:remAddr = @()
    [object[]]$Script:output = @()
    if($PSCmdlet.ParameterSetName  -eq "Win2K12R2 or Win8.x"){
        $HostName=$VMHostName
    }   
    if([System.String]::IsNullOrWhiteSpace($HostName)){
        $HostName = "."
    }    
    if(-not [System.String]::IsNullOrWhiteSpace($NetworksToAdd)){
        $Script:addAddr = $NetworksToAdd.Split(',')
    }    
    if(-not [System.String]::IsNullOrWhiteSpace($NetworksToRemove)){
        $Script:remAddr = $NetworksToRemove.Split(',')
    }
    [string]$Properties="Name,VirtualMachineMigrationEnabled,MaximumVirtualMachineMigrations,UseAnyNetworkForMigration,VirtualMachineMigrationAuthenticationType,VirtualMachineMigrationPerformanceOption"
    if($null -eq $AccessAccount){
        if($Action -eq 'Enable'){
            Enable-VMMigration -ComputerName $HostName -ErrorAction Stop
        }
        else {
            Disable-VMMigration -ComputerName $HostName-VMReplicationServer -ErrorAction Stop
        }
        if($PSBoundParameters.ContainsKey('MaxVirtualMachineMigrations') -eq $true ){
            Set-VMHost -ComputerName $HostName -MaximumVirtualMachineMigrations $MaxVirtualMachineMigrations -ErrorAction Stop
        }
        if($PSBoundParameters.ContainsKey('EnableUseAnyNetworkForMigration') -eq $true ){
            Set-VMHost -ComputerName $HostName -UseAnyNetworkForMigration $EnableUseAnyNetworkForMigration -ErrorAction Stop
        }
        if($PSBoundParameters.ContainsKey('VMMigrationAuthenticationType') -eq $true ){
            Set-VMHost -ComputerName $HostName -VirtualMachineMigrationAuthenticationType $VMMigrationAuthenticationType -ErrorAction Stop
        }
        if($PSBoundParameters.ContainsKey('VMMigrationPerformanceOption') -eq $true ){
            Set-VMHost -ComputerName $HostName -VirtualMachineMigrationPerformanceOption $VMMigrationPerformanceOption -ErrorAction Stop
        }
        foreach($mask in $Script:addAddr){
            Add-VMMigrationNetwork -ComputerName $HostName -Subnet $mask -ErrorAction Stop
        }
        foreach($maskR in $Script:remAddr){
            Remove-VMMigrationNetwork -ComputerName $HostName -Subnet $maskR -ErrorAction Stop
        }
        $Script:output = Get-VMHost -ComputerName $HostName -ErrorAction Stop | Select-Object $Properties.Split(',')
        $Script:output += Get-VMMigrationNetwork -ComputerName $HostName | Select-Object *
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $HostName -Credential $AccessAccount
        if($Action -eq 'Enable'){
            Enable-VMMigration -CimSession $Script:Cim -ErrorAction Stop
        }
        else {
            Disable-VMMigration -CimSession $Script:Cim -ErrorAction Stop
        }
        if($PSBoundParameters.ContainsKey('MaxVirtualMachineMigrations') -eq $true ){
            Set-VMHost -CimSession $Script:Cim -MaximumVirtualMachineMigrations $MaxVirtualMachineMigrations -ErrorAction Stop
        }
        if($PSBoundParameters.ContainsKey('EnableUseAnyNetworkForMigration') -eq $true ){
            Set-VMHost -CimSession $Script:Cim -UseAnyNetworkForMigration $EnableUseAnyNetworkForMigration -ErrorAction Stop
        }
        if($PSBoundParameters.ContainsKey('VMMigrationAuthenticationType') -eq $true ){
            Set-VMHost -CimSession $Script:Cim -VirtualMachineMigrationAuthenticationType $VMMigrationAuthenticationType -ErrorAction Stop
        }
        if($PSBoundParameters.ContainsKey('VMMigrationPerformanceOption') -eq $true ){
            Set-VMHost -CimSession $Script:Cim -VirtualMachineMigrationPerformanceOption $VMMigrationPerformanceOption -ErrorAction Stop
        }        
        foreach($mask in $Script:addAddr){
            Add-VMMigrationNetwork -CimSession $Script:Cim -Subnet $mask.Trim() -ErrorAction Stop
        }
        foreach($maskR in $Script:remAddr){
            Remove-VMMigrationNetwork -CimSession $Script:Cim -Subnet $maskR.Trim() -ErrorAction Stop
        }
        $Script:output = Get-VMHost -CimSession $Script:Cim -ErrorAction Stop | Select-Object $Properties.Split(',')
        $Script:output += Get-VMMigrationNetwork -CimSession $Script:Cim | Select-Object *
    }         
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:output
    }    
    else {
        Write-Output $Script:output
    }
}
catch {
    throw
}
finally{
    if($null -ne $Script:Cim){
        Remove-CimSession $Script:Cim 
    }
}