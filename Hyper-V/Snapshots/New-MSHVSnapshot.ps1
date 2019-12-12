#Requires -Version 4.0
#Requires -Modules Hyper-V

<#
    .SYNOPSIS
        Creates a snapshot of a virtual machine
    
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
        https://github.com/scriptrunner/ActionPacks/tree/master/Hyper-V/Snapshots

    .Parameter VMHostName
        Specifies the name of the Hyper-V host

    .Parameter HostName
        Specifies the name of the Hyper-V host

    .Parameter VMName
        Specifies the state of the virtual machines

    .Parameter SnapshotName
        Specifies the name of the snapshot to be taken. 
        If not provided, a combination of the virtual machine's name and a current timestamp is used       

    .Parameter AccessAccount
        Specifies the user account that have permission to perform this action    
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = "Win2K12R2 or Win8.x")]
    [string]$VMHostName,
    [Parameter(Mandatory = $true, ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(Mandatory = $true, ParameterSetName = "Newer Systems")]
    [string]$VMname,
    [Parameter(ParameterSetName = "Newer Systems")]
    [string]$HostName,
    [Parameter(ParameterSetName = "Newer Systems")]
    [PSCredential]$AccessAccount,
    [Parameter(ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(ParameterSetName = "Newer Systems")]
    [string]$SnapshotName
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
        [string[]]$Properties = @('Name','Id','SnapshotType','Path','ParentCheckpointName','SizeOfSystemFiles','CreationTime')
        if([System.String]::IsNullOrWhiteSpace($SnapshotName)){
            $Script:output = Checkpoint-VM -VM $Script:VM -Passthru -ErrorAction Stop 
        }
        else{
            $Script:output = Checkpoint-VM -VM $Script:VM -SnapshotName $SnapshotName -Passthru -ErrorAction Stop 
        }
        $Script:output = Get-VMSnapshot -VM $Script:VM -Name $Script:output.Name  | Select-Object $Properties | Format-List
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