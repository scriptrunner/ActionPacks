#Requires -Version 4.0
#Requires -Modules Hyper-V

<#
    .SYNOPSIS
        Sets the size of a virtual hard disk for the virtual machine
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/Hyper-V/VMs

    .Parameter VMHostName
        Specifies the name of the Hyper-V host

    .Parameter HostName
        Specifies the name of the Hyper-V host

    .Parameter VMName
        Specifies the virtual machine to be configured

    .Parameter AccessAccount
        Specifies the user account that have permission to perform this action

    .Parameter ControllerType
        Specifies the type of the controller 

    .Parameter ControllerNumber
        Specifies the number of the controller

    .Parameter ControllerLocation
        Specifies the number of the location on the controller 

    .Parameter SizeofVHD
        Specifies the size to which the virtual hard disk is to be resized, in bytes

    .Parameter ResizeToMinimumSize
        Specifies that the virtual hard disk is to be resized to its minimum possible size
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
    [PSCredential]$AccessAccount ,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [ValidateSet('SCSI','IDE')]
    [string]$ControllerType = "SCSI",
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [int]$ControllerNumber,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [int]$ControllerLocation ,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [uint64]$SizeofVHD ,    
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [switch]$ResizeToMinimumSize
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
        $Script:VM = Get-VM -ComputerName $HostName -ErrorAction Stop | Where-Object {$_.VMName -eq $VMName -or $_.VMID -eq $VMName}
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $HostName -Credential $AccessAccount
        $Script:VM = Get-VM -CimSession $Script:Cim -ErrorAction Stop | Where-Object {$_.VMName -eq $VMName -or $_.VMID -eq $VMName}
    }        
    if($null -ne $Script:VM){
        if($ControllerType -eq "SCSI"){
            $Script:drvs = Get-VMScsiController -VM $Script:VM -ControllerNumber $ControllerNumber -ErrorAction Stop | Select-Object drives
        }
        else {
            $Script:drvs = Get-VMIdeController -VM $Script:VM -ControllerNumber $ControllerNumber -ErrorAction Stop | Select-Object drives
        }
        foreach($drive in $Script:drvs.Drives){
            if($drive.ControllerLocation -eq $ControllerLocation){
                if($ResizeToMinimumSize -eq $true){
                    if($null -eq $AccessAccount){
                        Resize-VHD -ComputerName $HostName -Path $drive.Path -ToMinimumSize -ErrorAction Stop 
                        $Script:output = Get-VHD -ComputerName $HostName -Path $drive.Path | Select-Object *
                    }
                    else {
                        Resize-VHD -CimSession $Script:Cim -Path $drive.Path -ToMinimumSize -ErrorAction Stop 
                        $Script:output = Get-VHD -CimSession $Script:Cim -Path $drive.Path | Select-Object *
                    }
                }
                else {
                    if($null -eq $AccessAccount){
                        Resize-VHD -ComputerName $HostName -Path $drive.Path -SizeBytes $SizeofVHD -ErrorAction Stop 
                        $Script:output = Get-VHD -ComputerName $HostName -Path $drive.Path | Select-Object *
                    }
                    else{
                        Resize-VHD -CimSession $Script:Cim -Path $drive.Path -SizeBytes $SizeofVHD -ErrorAction Stop 
                        $Script:output = Get-VHD -CimSession $Script:Cim -Path $drive.Path | Select-Object *
                    }
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