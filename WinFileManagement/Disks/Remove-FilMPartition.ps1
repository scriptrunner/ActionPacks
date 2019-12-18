#Requires -Version 4.0

<#
.SYNOPSIS
    Deletes the specified Partition object on an existing disk and any underlying Volume objects

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
    Specifies the disk number

.Parameter PartitionNumber
    Specifies the number of the partition

.Parameter Confirm
    Confirm that the cmdlet is running

.Parameter ComputerName
    Specifies the name of the computer from which to remove the partition. If Computername is not specified, the current computer is used.
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [int]$DiskNumber,
    [Parameter(Mandatory = $true)]
    [int]$PartitionNumber,
    [bool]$Confirm = $false,
    [string]$ComputerName,
    [PSCredential]$AccessAccount
)

$Script:Cim=$null
$Script:output = @()

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
    if($Confirm -eq $true){
        $null = Remove-Partition -InputObject $Script:Parti -Confirm:$false -ErrorAction Stop 
        $Script:output += "Partition: $($PartitionNumber) on disk: $($DiskNumber) removed"
    }
    else{
        $Script:output += $Script:Parti
    }
    
    if($SRXEnv) {
        $SRXEnv.ResultMessage =$Script:output
    }
    else{
        Write-Output $Script:output
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