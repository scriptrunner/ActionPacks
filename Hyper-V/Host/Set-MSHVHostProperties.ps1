#Requires -Version 4.0
#Requires -Modules Hyper-V

<#
    .SYNOPSIS
        Sets the properties for the Hyper-V host.
        Only parameters with value are set
    
    .DESCRIPTION  
        Use "Win2K12R2 or Win8.x" for execution on Windows Server 2012 R2 or on Windows 8.1,
        when execute on Windows Server 2016 / Windows 10 or newer, use "Newer Systems"

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

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

    .Parameter PathVirtualHardDisks
        Specifies the default folder to store virtual hard disks on the Hyper-V host

    .Parameter PathVirtualMachines
        Specifies the default folder to store virtual machine configuration files on the Hyper-V host

    .Parameter EnableNumaSpanning
        Specifies whether virtual machines on the Hyper-V host can use resources from more than one NUMA node

    .Parameter MaximumStorageMigrations
        Specifies the maximum number of storage migrations that can be performed at the same time on the Hyper-V host

    .Parameter EnableEnhancedSessionMode
        Indicates whether users can use enhanced mode when they connect to virtual machines on this server by using Virtual Machine Connection
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
    [string]$PathVirtualHardDisks,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [string]$PathVirtualMachines,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [bool]$EnableNumaSpanning,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [int]$MaximumStorageMigrations,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [bool]$EnableEnhancedSessionMode
)

Import-Module Hyper-V

try {
    [string[]]$Properties = @('ComputerName','VirtualHardDiskPath','VirtualMachinePath','NumaSpanningEnabled','MaximumStorageMigrations','EnableEnhancedSessionMode')
    if($PSCmdlet.ParameterSetName  -eq "Win2K12R2 or Win8.x"){
        $HostName=$VMHostName
    }   
    if([System.String]::IsNullOrWhiteSpace($HostName)){
        $HostName = "."
    }   
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}
    if($null -eq $AccessAccount){
        $cmdArgs.Add('ComputerName',$HostName)
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $HostName -Credential $AccessAccount
        $cmdArgs.Add('CimSession',$Script:Cim)
    } 
    
    if($PSBoundParameters.ContainsKey('PathVirtualHardDisks') -eq $true ){
        Set-VMHost @cmdArgs -VirtualHardDiskPath $PathVirtualHardDisks
    }
    if($PSBoundParameters.ContainsKey('PathVirtualMachines') -eq $true ){
        Set-VMHost @cmdArgs -VirtualMachinePath $PathVirtualMachines
    }
    if($PSBoundParameters.ContainsKey('EnableNumaSpanning') -eq $true ){
        Set-VMHost @cmdArgs -NumaSpanningEnabled $EnableNumaSpanning
    }
    if($PSBoundParameters.ContainsKey('MaximumStorageMigrations') -eq $true ){
        Set-VMHost @cmdArgs -MaximumStorageMigrations $MaximumStorageMigrations
    }
    if($PSBoundParameters.ContainsKey('EnableEnhancedSessionMode') -eq $true ){
        Set-VMHost @cmdArgs -EnableEnhancedSessionMode $EnableEnhancedSessionMode
    }
    $output = Get-VMHost @cmdArgs | Select-Object $Properties
        
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $output
    }    
    else {
        Write-Output $output
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