#Requires -Version 4.0
#Requires -Modules Hyper-V

<#
    .SYNOPSIS
        Gets the size of a virtual hard disk for the virtual machines
    
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

    .Parameter VMNames
        Specifies the virtual machines

    .Parameter AccessAccount
        Specifies the user account that have permission to perform this action

    .Parameter ControllerType
        Specifies the type of the controlle
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = "Win2K12R2 or Win8.x")]
    [string]$VMHostName,
    [Parameter(Mandatory = $true,ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(Mandatory = $true,ParameterSetName = "Newer Systems")]
    [string[]]$VMNames, 
    [Parameter(ParameterSetName = "Newer Systems")]
    [string]$HostName,
    [Parameter(ParameterSetName = "Newer Systems")]
    [PSCredential]$AccessAccount ,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [ValidateSet('SCSI','IDE')]
    [string]$ControllerType = "SCSI"
)

Import-Module Hyper-V

$Script:drv
$Script:output = @()

try {
    if($PSCmdlet.ParameterSetName  -eq "Win2K12R2 or Win8.x"){
        $HostName=$VMHostName
    }    
    if([System.String]::IsNullOrWhiteSpace($HostName)){
        $HostName = "."
    }
    foreach($vmItem in $VMNames){
        if($null -eq $AccessAccount){
            $Script:VM = Get-VM -ComputerName $HostName -ErrorAction Stop | Where-Object {$_.VMName -eq $vmItem -or $_.VMID -eq $vmItem}
        }
        else {
            $Script:Cim = New-CimSession -ComputerName $HostName -Credential $AccessAccount
            $Script:VM = Get-VM -CimSession $Script:Cim -ErrorAction Stop | Where-Object {$_.VMName -eq $vmItem -or $_.VMID -eq $vmItem}
        }
        if($null -ne $Script:VM){
            if($ControllerType -eq "SCSI"){
                $Script:drvs = Get-VMScsiController -VM $Script:VM -ErrorAction SilentlyContinue | Select-Object drives
            }
            else {
                $Script:drvs = Get-VMIdeController -VM $Script:VM -ErrorAction SilentlyContinue | Select-Object drives
            }
            foreach($drive in $Script:drvs.Drives){
                if(($null -eq $drive) -or [System.String]::IsNullOrWhiteSpace($drive.Path)){
                    continue
                }
                if($null -eq $AccessAccount){
                    $Script:drv = Get-VHD -ComputerName $HostName -Path $drive.Path
                }
                else{
                    $Script:drv = Get-VHD -CimSession $Script:Cim -Path $drive.Path 
                }
                $Script:output += "VM: $($vmItem) - Drive-Path: $($drive.Path) - Size: $($Script:drv.Size)"
            }
        }
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