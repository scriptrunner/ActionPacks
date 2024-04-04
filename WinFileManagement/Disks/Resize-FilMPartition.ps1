#Requires -Version 5.0

<#
.SYNOPSIS
    Resizes a partition and the underlying file system

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    
.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinFileManagement/Disks

.Parameter DiskNumber
    [sr-en] Disk number

.Parameter PartitionNumber
    [sr-en] Number of the partition

.Parameter Size
    [sr-en] Size of the partition to create, in bytes

.Parameter UseMaximumSize
    [sr-en] Creates the largest possible partition on the specified disk

.Parameter ComputerName
    [sr-en] Name of the computer from which to resize the disk. If Computername is not specified, the current computer is used.
    
.Parameter AccessAccount
    [sr-en] User account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [int]$DiskNumber,
    [Parameter(Mandatory = $true)]
    [int]$PartitionNumber,
    [uint64]$Size,
    [switch]$UseMaximumSize,
    [string]$ComputerName,
    [PSCredential]$AccessAccount
)

$Script:Cim=$null
[string[]]$Script:Properties = @("PartitionNumber","DriveLetter","DiskNumber","Size","IsActive","IsBoot","IsOffline","IsSystem","IsReadOnly","Type")

try{ 
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName=[System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim = New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }         
    $Script:Parti = Get-Partition -CimSession $Script:Cim -DiskNumber $DiskNumber -PartitionNumber $PartitionNumber -ErrorAction Stop
    if($UseMaximumSize -eq $true){
        $tmp = Get-PartitionSupportedSize -InputObject $Script:Parti | Select-Object SizeMax
        $Size = [uint64]$tmp.SizeMax
    }
    $null = Resize-Partition -InputObject $Script:Parti -Size $Size -ErrorAction Stop 
    
    $Script:Parti = Get-Partition -CimSession $Script:Cim -DiskNumber $DiskNumber -PartitionNumber $PartitionNumber | Select-Object $Script:Properties
    if($SRXEnv) {
        $SRXEnv.ResultMessage =$Script:Parti
    }
    else{
        Write-Output $Script:Parti
    }
}
catch{
    throw
}
finally{
    if($null -ne $Script:Cim){
        Remove-CimSession $Script:Cim 
    }
}