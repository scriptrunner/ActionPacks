#Requires -Version 4.0

<#
.SYNOPSIS    
    Cleans a disk by removing all partition information and un-initializing it, erasing all data on the disk

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

.Parameter Number
    Specifies the disk number of the disk to initialize

.Parameter UniqueID
    Specifies the UniqueID of the disk to initialize

.Parameter PartitionStyle
    Specifies the type of the partition

.Parameter ComputerName
    Specifies the name of the computer on which you want to clear the associated Disk object. If Computername is not specified, the current computer is used.
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "ByNumber")]
    [int]$Number,
    [Parameter(Mandatory = $true,ParameterSetName = "ByUniqueID")]
    [string]$UniqueID,
    [Parameter(ParameterSetName = "ByNumber")]
    [Parameter(ParameterSetName = "ByUniqueID")]
    [string]$ComputerName,
    [Parameter(ParameterSetName = "ByNumber")]
    [Parameter(ParameterSetName = "ByUniqueID")]
    [PSCredential]$AccessAccount
)

$Script:Cim=$null
[string[]]$Script:Properties = @("Number","FriendlyName","PartitionStyle","OperationalStatus","AllocatedSize","BootFromDisk","IsBoot","IsClustered","IsHighlyAvailable","IsSystem","Size")
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
    if($PSCmdlet.ParameterSetName  -eq "ByUniqueID"){
        $Script:Disk = Get-Disk -CimSession $Script:Cim -UniqueId $UniqueID -ErrorAction Stop
    }
    else{
        $Script:Disk = Get-Disk -CimSession $Script:Cim -Number $Number -ErrorAction Stop
    }
    $null = Clear-Disk -InputObject $Script:Disk -Confirm:$false -ErrorAction Stop
    
    $result = Get-Disk -CimSession $Script:Cim -Number $Script:Disk.Number | Select-Object $Script:Properties
    if($SRXEnv) {
        $SRXEnv.ResultMessage =$result
    }
    else{
        Write-Output $result
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