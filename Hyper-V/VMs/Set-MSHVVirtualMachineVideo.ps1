#Requires -Version 4.0
#Requires -Modules Hyper-V

<#
    .SYNOPSIS
        Configures video settings for virtual machine
    
    .DESCRIPTION
        Can only executed on Windows Server 2016 / Windows 10 or newer.

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

    .Parameter HostName
        Specifies the name of the Hyper-V host

    .Parameter AccessAccount
        Specifies the user account that have permission to perform this action

    .Parameter VMName
        Specifies the name or identifier of the virtual machine whose BIOS is to be retrieved

    .Parameter ResolutionType
        Specifies the resolution type for the virtual machine display

    .Parameter HorizontalResolution 
        Specifies the horizontal resolution for the virtual machine display

    .Parameter VerticalResolution 
        Specifies the vertical resolution for the virtual machine display
#>

param(    
    [Parameter(Mandatory = $true)]
    [string]$VMName,
    [Parameter(Mandatory = $true)]
    [ValidateSet('Maximum', 'Single', 'Default')]
    [string]$ResolutionType = "Default",
    [Parameter(Mandatory = $true)]
    [uint16]$HorizontalResolution,
    [Parameter(Mandatory = $true)]
    [uint16]$VerticalResolution,
    [string]$HostName,
    [PSCredential]$AccessAccount
)

Import-Module Hyper-V

try {
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
        Set-VMVideo -VM $Script:VM -ResolutionType $ResolutionType -HorizontalResolution $HorizontalResolution -VerticalResolution $VerticalResolution -ErrorAction Stop
        $output = Get-VMVideo -VM $Script:VM | Select-Object *
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