#Requires -Version 4.0
#Requires -Modules Hyper-V

<#
    .SYNOPSIS
        Sets a virtual switch to the virtual machine
    
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
        Specifies the name or identifier of the virtual machine to be retrieved

    .Parameter SwitchName
        Specifies the name of the virtual switch to which the virtual network adapter is to be connected

    .Parameter DisconnectExistingAdapters
        Disconnects existing network adapters from the virtual machine
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
    [string]$SwitchName,    
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [switch]$DisconnectExistingAdapters
)

Import-Module Hyper-V

try {
    if($PSCmdlet.ParameterSetName  -eq "Win2K12R2 or Win8.x"){
        $HostName=$VMHostName
    }    
    if([System.String]::IsNullOrWhiteSpace($HostName)){
        $HostName = "."
    }
    if($null -eq $AccessAccount){
        $Script:VM = Get-VM -ErrorAction Stop | Where-Object {$_.VMName -eq $VMName -or $_.VMID -eq $VMName}
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $HostName -Credential $AccessAccount
        $Script:VM = Get-VM -CimSession $Script:Cim -ErrorAction Stop | Where-Object {$_.VMName -eq $VMName -or $_.VMID -eq $VMName}
    }        
    if($null -ne $Script:VM){
        if($DisconnectExistingAdapters -eq $true){
            Get-VMNetworkAdapter -VM $Script:VM | Disconnect-VMNetworkAdapter -ErrorAction Stop
        }
        if(-not [System.String]::IsNullOrWhiteSpace( $SwitchName)){
            if($null -eq $Script:Cim){
                Connect-VMNetworkAdapter -ComputerName $HostName -VMName $Script:VM.VMname -SwitchName $SwitchName -Confirm:$false -ErrorAction Stop
            }
            else {
                Connect-VMNetworkAdapter -CimSession $Script:Cim -VMName $Script:VM.VMname -SwitchName $SwitchName -Confirm:$false -ErrorAction Stop
            }
        }
        [string[]]$Properties = @('Name','VMName','MacAddress','DynamicMacAddressEnabled','IPAddresses','Connected','SwitchName','AdapterId','Status','StatusDescription','IsManagementOs','IsExternalAdapter')
        $output = Get-VMNetworkAdapter -VM $Script:VM | Select-Object $Properties | Where-Object {$_.Connected -eq $true}
        if($SRXEnv) {
            $SRXEnv.ResultMessage = $output
        }    
        else {
            Write-Output $output
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