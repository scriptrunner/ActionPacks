#Requires -Version 4.0

<#
.SYNOPSIS
    Gets one or more disks visible to the operating system

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

.Parameter FriendlyName
    Gets the disk with the specified friendly name. If the parameter is empty, all disks are retrieved

.Parameter Number
    Specifies the disk number for which to get the associated Disk object. If the parameter less than 0, all disks are retrieved

.Parameter ComputerName
    Specifies the name of the computer from which to retrieve the disk informations. If Computername is not specified, the current computer is used.
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter Properties
    List of properties to expand, comma separated e.g. Name,Description. Use * for all properties
#>

[CmdLetBinding()]
Param(
    [string]$FriendlyName,
    [int]$Number = -1,
    [string]$ComputerName,
    [PSCredential]$AccessAccount,
    [ValidateSet('*','Number','FriendlyName','PartitionStyle','OperationalStatus','AllocatedSize','BootFromDisk','IsBoot','IsClustered','IsHighlyAvailable','IsSystem','Size')]
    [string[]]$Properties = @('Number','FriendlyName','PartitionStyle','OperationalStatus','AllocatedSize','BootFromDisk','IsBoot','IsClustered','IsHighlyAvailable','IsSystem','Size')
)

$Script:Cim=$null
$Script:output = @()
try{ 
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    if([System.String]::IsNullOrWhiteSpace($FriendlyName)){
        $FriendlyName= "*"
    }
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName=[System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim = New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }    
    if($Number -lt 0){
        $Script:output = Get-Disk -CimSession $Script:Cim -FriendlyName $FriendlyName | Select-Object $Properties
    }
    else{
        $Script:output = Get-Disk -CimSession $Script:Cim -Number $Number | Select-Object $Properties
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