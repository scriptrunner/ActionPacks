#Requires -Version 4.0
#Requires -Modules Hyper-V

<#
    .SYNOPSIS
        Configures the BIOS of a Generation 1 virtual machine
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/Hyper-V/VMs

    .Parameter VMHostName
        Specifies the name of the Hyper-V host

    .Parameter HostName
        Specifies the name of the Hyper-V host

    .Parameter AccessAccount
        Specifies the user account that have permission to perform this action

    .Parameter VMName
        Specifies the name or identifier of the virtual machine whose BIOS is to be retrieved

    .Parameter NumLock
        Specifies that NumLock is to be enabled or disabled in the BIOS of the virtual machine

    .Parameter StartUpOrder1
        Specifies the boot device #1 in the BIOS of the virtual machine

    .Parameter StartUpOrder2
        Specifies the boot device #2 in the BIOS of the virtual machine

    .Parameter StartUpOrder3
        Specifies the boot device #3 in the BIOS of the virtual machine

    .Parameter StartUpOrder4
        Specifies the boot device #4 in the BIOS of the virtual machine

    .Parameter StartUpOrder5
        Specifies the boot device #5 in the BIOS of the virtual machine

    .Parameter StartUpOrder6
        Specifies the boot device #6 in the BIOS of the virtual machine
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = "Win2K12R2 or Win8.x")]
    [string]$VMHostName,
    [Parameter(Mandatory = $true,ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(Mandatory = $true,ParameterSetName = "Newer Systems")]
    [string]$VMName,
    [Parameter(ParameterSetName = "Newer Systems")]
    [string]$HostName,
    [Parameter(ParameterSetName = "Newer Systems")]
    [PSCredential]$AccessAccount,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [ValidateSet('Enable','Disable')]
    [string]$NumLock,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [ValidateSet('CD', 'IDE', 'LegacyNetworkAdapter', 'Floppy')]
    [string]$StartUpOrder1 = "CD",
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [ValidateSet('CD', 'IDE', 'LegacyNetworkAdapter', 'Floppy')]
    [string]$StartUpOrder2 = "IDE",
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [ValidateSet('CD', 'IDE', 'LegacyNetworkAdapter', 'Floppy')]
    [string]$StartUpOrder3 = "LegacyNetworkAdapter",
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [ValidateSet('CD', 'IDE', 'LegacyNetworkAdapter', 'Floppy')]
    [string]$StartUpOrder4 = "Floppy"
)

Import-Module Hyper-V

try {
    $Script:output
    if($PSCmdlet.ParameterSetName  -eq "Win2K12R2 or Win8.x"){
        $HostName=$VMHostName
    }    
    if([System.String]::IsNullOrWhiteSpace($HostName)){
        $HostName = "."
    }
    if($null -eq $AccessAccount){
        $Script:VM = Get-VM -ComputerName $HostName -ErrorAction Stop | Where-Object {$_.VMName -eq $VMName -or $_.VMID -eq $VMName}
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $HostName -Credential $AccessAccount
        $Script:VM = Get-VM -CimSession $Script:Cim -ErrorAction Stop | Where-Object {$_.VMName -eq $VMName -or $_.VMID -eq $VMName}
    }        
    if($null -ne $Script:VM){
        [string[]]$Script:start = @($StartUpOrder1,$StartUpOrder2,$StartUpOrder3,$StartUpOrder4)
        if($NumLock -eq 'Enable'){
            Set-VMBios -VM $Script:VM -EnableNumLock -StartupOrder $Script:start -ErrorAction Stop
        }
        else {
            Set-VMBios -VM $Script:VM -DisableNumLock -StartupOrder $Script:start -ErrorAction Stop
        }
        $Script:output = Get-VMBios -VM $Script:VM | Select-Object *
        if($SRXEnv) {
            $SRXEnv.ResultMessage = $Script:output
        }    
        else {
            Write-Output $Script:output
        }
    }
    else{
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "Virtual machine $($VMName) not found"
        }    
        Throw "Virtual machine $($VMName) not found"
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