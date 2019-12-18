#Requires -Version 4.0

<#
.SYNOPSIS
    Creates a new partition on an existing Disk object

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
    Specifies the disk number

.Parameter ComputerName
    Specifies the name of the computer on which the partition creates. If Computername is not specified, the current computer is used.
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter AssignDriveLetter 
    Assigns a drive letter to the new partition

.Parameter DriveLetter
    Specifies the specific drive letter to assign to the new partition

.Parameter IsActive
    Specifies that the object is marked active

.Parameter IsHidden
    Specifies that is a hidden partition

.Parameter MbrType
    Specifies the type of MBR partition to create

.Parameter UseMaximumSize
    Creates the largest possible partition on the specified disk

.Parameter Size
    Specifies the size of the partition to create, in bytes

.Parameter FormatNewPartition
    Formats the new partition after create

.Parameter FileSystem
    Specifies the file system with which to format the volume

.Parameter FormatFull
    Performs a full format. A full format writes to every sector of the disk, takes much longer to perform than the default (quick) format
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [int]$Number,
    [switch]$AssignDriveLetter,
    [string]$DriveLetter,
    [bool]$IsActive,
    [bool]$IsHidden,
    [ValidateSet("","FAT12", "FAT16", "Extended", "Huge", "IFS", "FAT32")]
    [string]$MbrType="",
    [switch]$UseMaximumSize,
    [UInt64]$Size,
    [bool]$FormatNewPartition,
    [ValidateSet("NTFS","ReFS","exFAT","FAT32","FAT")]
    [string]$FileSystem = "NTFS",
    [switch]$FormatFull,
    [string]$ComputerName,
    [PSCredential]$AccessAccount
)

$Script:Cim = $null
[string[]]$Script:Properties = @("PartitionNumber","OperationalStatus","DriveLetter","DiskNumber","IsActive","IsHidden","Size","MbrType")

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
    $Script:Disk = Get-Disk -CimSession $Script:Cim -Number $Number -ErrorAction Stop

    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'InputObject' = $Script:Disk
                            'AssignDriveLetter' = $AssignDriveLetter}
    if($Size -gt 0){
        $cmdArgs.Add('Size',$Size)
    }
    else {
        $cmdArgs.Add('UseMaximumSize',$null)
    }
    if([System.String]::IsNullOrWhiteSpace($MbrType) -eq $false){
        $cmdArgs.Add('MbrType', $MbrType)
    }    
    $Script:Parti = New-Partition @cmdArgs

    Start-Sleep -Seconds 5
    if(-not [System.String]::IsNullOrWhiteSpace($DriveLetter)){
        $null = Set-Partition -CimSession $Script:Cim -DiskNumber $Number -PartitionNumber $Script:Parti.PartitionNumber -NewDriveLetter $DriveLetter.toUpper() -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('IsActive') -eq $true){
        $null = Set-Partition -CimSession $Script:Cim -DiskNumber $Number -PartitionNumber $Script:Parti.PartitionNumber -IsActive $IsActive -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('IsHidden') -eq $true){
        $null = Set-Partition -CimSession $Script:Cim -DiskNumber $Number -PartitionNumber $Script:Parti.PartitionNumber -IsHidden $IsHidden -ErrorAction Stop
    }
    if($FormatNewPartition){
      #  $Script:Parti.ObjectID
        $null = Format-Volume -Partition $Script:Parti -FileSystem $FileSystem -Force -Full:$FormatFull -ErrorAction Stop
    }

    $Script:Parti = Get-Partition -CimSession $Script:Cim -DiskNumber $Number -PartitionNumber $Script:Parti.PartitionNumber | Select-Object $Script:Properties
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