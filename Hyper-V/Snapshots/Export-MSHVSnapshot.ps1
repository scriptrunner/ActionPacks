#Requires -Version 4.0
#Requires -Modules Hyper-V

<#
    .SYNOPSIS
        Exports a virtual machine snapshot to disk
    
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
        Specifies the name of the virtual machine whose snapshot are to be retrieved

    .Parameter SnapshotName
        Specifies the name of the snapshot to be retrieved

    .Parameter ExportPath
        Specifies the path to the folder into which the snapshot is to be exported

    .Parameter AccessAccount
        Specifies the user account that have permission to perform this action
#>

param(
    [Parameter(Mandatory = $true,ParameterSetName = "Win2K12R2 or Win8.x")]
    [string]$VMHostName,
    [Parameter(Mandatory = $true, ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(Mandatory = $true, ParameterSetName = "Newer Systems")]
    [string]$VMName,
    [Parameter(Mandatory = $true, ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(Mandatory = $true, ParameterSetName = "Newer Systems")]
    [string]$SnapshotName,
    [Parameter(Mandatory = $true, ParameterSetName = "Win2K12R2 or Win8.x")]
    [Parameter(Mandatory = $true, ParameterSetName = "Newer Systems")]
    [string]$ExportPath,
    [Parameter(ParameterSetName = "Newer Systems")]
    [string]$HostName,
    [Parameter(ParameterSetName = "Newer Systems")]
    [PSCredential]$AccessAccount
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
        $Script:shot = Get-VMSnapshot -VMName $VMName -Name $SnapshotName  -ComputerName $HostName -ErrorAction Stop
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $HostName -Credential $AccessAccount
        $Script:shot = Get-VMSnapshot -VMName $VMName -Name $SnapshotName -CimSession $Script:Cim -ErrorAction Stop
    }       
    if($null -ne $Script:shot){
        Export-VMSnapshot -VMSnapshot $Script:shot -Path $ExportPath -ErrorAction Stop
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "Snapshot $($SnapshotName) from virtual machine $($VMName) exported to $($ExportPath)"
        }    
        else {
            Write-Output "Snapshot $($SnapshotName) from virtual machine $($VMName) exported to $($ExportPath)"
        }
    }
    else{
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "Snapshot $($SnapshotName) not found on virtual machine $($VMName)"
        }    
        throw "Snapshot $($SnapshotName) not found on virtual machine $($VMName)"
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