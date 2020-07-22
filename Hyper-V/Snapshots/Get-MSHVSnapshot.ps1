#Requires -Version 4.0
#Requires -Modules Hyper-V

<#
    .SYNOPSIS
        Get the snapshot associated with the virtual machine

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

    .Parameter HostName
        Specifies the name of the Hyper-V host

    .Parameter VMName
        Specifies the name of the virtual machine whose snapshot are to be retrieved

    .Parameter SnapshotName
        Specifies the name of the snapshot to be retrieved

    .Parameter AccessAccount
        Specifies the user account that have permission to perform this action

    .Parameter Properties
        List of properties to expand, comma separated e.g. Name,Description. Use * for all properties
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$VMName,
    [Parameter(Mandatory = $true)]
    [string]$SnapshotName,
    [string]$HostName,
    [PSCredential]$AccessAccount,
    [ValidateSet('*','Name','Id','SnapshotType','Path','ParentCheckpointName','SizeOfSystemFiles','CreationTime')]
    [string[]]$Properties = @('Name','Id','SnapshotType','Path','ParentCheckpointName','SizeOfSystemFiles','CreationTime')
)

Import-Module Hyper-V

try {
    if($Properties -contains '*'){
        $Properties = @('*')
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
        $output = Get-VMSnapshot -VM $Script:VM -Name $SnapshotName -ErrorAction Stop | Select-Object $Properties | Format-List
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