#Requires -Version 4.0
#Requires -Modules Hyper-V

<#
    .SYNOPSIS
        Configures a virtual DVD drive
    
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
        Specifies the name of the virtual machine on which the DVD drive is to be configured

    .Parameter ControllerType
        Specifies the type of the controller, IDE or SCSI 

    .Parameter ControllerNumber
        Specifies the IDE controller of the DVD drives to be configured. 
        If not specified, DVD drives attached to all controllers are configured.

    .Parameter ToControllerNumber
        Specifies the controller number to which this VMDvdDrive should be moved.
        Use -1 for don´t move the drive

    .Parameter ToControllerLocation
        Specifies the controller location to which this virtual DVD drive should be moved

    .Parameter Path
        Specifies the path to the ISO file or physical DVD drive that will serve as media for the virtual DVD drive
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
    [ValidateSet('SCSI','IDE')]
    [string]$ControllerType = "SCSI",
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [int]$ControllerNumber,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [int]$ToControllerNumber = -1,    
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [int]$ToControllerLocation = 0,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [string]$Path
)

Import-Module Hyper-V

try {
    [string]$Properties = @('Name','DvdMediaType','Path','ControllerNumber','ControllerType','VMId','VMName')
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
        if($ControllerType -eq 'SCSI'){
            $Script:controller = Get-VMScsiController -VM $Script:VM -ControllerNumber $ControllerNumber
        }
        else {
            $Script:controller = Get-VMIdeController -VM $Script:VM -ControllerNumber $ControllerNumber
        }
        if([System.String]::IsNullOrWhiteSpace($Path)){
            $Path = $null
        }
        $Script:drive = Get-VMDvdDrive -VMDriveController $Script:controller -ErrorAction Stop
        if($ToControllerNumber -ge 0){
            $Script:drive = Set-VMDvdDrive -VMDvdDrive $drive -ToControllerLocation $ToControllerLocation -ToControllerNumber $ToControllerNumber -Passthru -ErrorAction Stop
            if($ControllerType -eq 'SCSI'){
                $Script:controller = Get-VMScsiController -VM $Script:VM -ControllerNumber $ToControllerNumber  -ErrorAction Stop
            }
            else {
                $Script:controller = Get-VMIdeController -VM $Script:VM -ControllerNumber $ToControllerNumber -ErrorAction Stop
            }
        }
        $Script:drive = Set-VMDvdDrive -VMDvdDrive $drive -Path $Path -ErrorAction Stop
        $output = Get-VMDvdDrive -VMDriveController $Script:controller | Select-Object $Properties
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