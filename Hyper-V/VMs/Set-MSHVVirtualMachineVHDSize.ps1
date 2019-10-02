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
    $Script:output = @()    
    if($PSCmdlet.ParameterSetName  -eq "Win2K12R2 or Win8.x"){
        $HostName=$VMHostName
    }    
    if([System.String]::IsNullOrWhiteSpace($HostName)){
        $HostName = "."
    }
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'}
    if($null -eq $AccessAccount){
        $cmdArgs.Add('ComputerName', $HostName)
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $HostName -Credential $AccessAccount
        $cmdArgs.Add('CimSession', $Script:Cim)
    }           
    
    $Script:VM = Get-VM @cmdArgs | Where-Object {$_.VMName -eq $VMName -or $_.VMID -eq $VMName}
            
    if($null -ne $Script:VM){
        if($ControllerType -eq "SCSI"){
            $Script:drvs = Get-VMScsiController -VM $Script:VM -ControllerNumber $ControllerNumber -ErrorAction Stop | Select-Object drives
        }
        else {
            $Script:drvs = Get-VMIdeController -VM $Script:VM -ControllerNumber $ControllerNumber -ErrorAction Stop | Select-Object drives
        }
        $cmdArgs.Add('Path','')
        $getArgs = $cmdArgs.Clone()             
        if($ResizeToMinimumSize -eq $true){
            $cmdArgs.Add('ToMinimumSize',$null)
        }
        else {
            $cmdArgs.Add('SizeBytes',$SizeofVHD)
        }
        foreach($drive in $Script:drvs.Drives){
            if($drive.ControllerLocation -eq $ControllerLocation){
                $cmdArgs['Path'] = $drive.Path
                $getArgs['Path'] = $drive.Path
                Resize-VHD @cmdArgs 
                $Script:output += Get-VHD @getArgs | Select-Object *
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