#Requires -Version 4.0

<#
.SYNOPSIS
    Formats a existing volumes or a new volume on an existing partition

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

.Parameter DriveLetter
    Specifies a letter used to identify a drive or volume in the system

.Parameter AllocationUnitSize
    Specifies the allocation unit size to use when formatting the volume

.Parameter FileSystem
    Specifies the file system with which to format the volume

.Parameter Full
    Performs a full format. A full format writes to every sector of the disk, takes much longer to perform than the default (quick) format, and is not recommended on storage that is thinly provisioned

.Parameter NewFileSystemLabel
    Specifies a new label to use for the volume

.Parameter ComputerName
    Specifies the name of the computer from which to repair the volume object. If Computername is not specified, the current computer is used.
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(    
    [Parameter(Mandatory = $true)]
    [string]$DriveLetter,
    [switch]$Full,
    [uint32]$AllocationUnitSize,
    [ValidateSet("FAT", "FAT32", "exFAT","NTFS","ReFS")]
    [string]$FileSystem = "NTFS",
    [string]$NewFileSystemLabel,
    [string]$ComputerName,
    [PSCredential]$AccessAccount
)

$Script:Cim=$null
$Script:output = @()
[string[]]$Script:Properties = @("DriveLetter","FileSystemLabel","DedupMode","DriveType","HealthStatus","FileSystemType","AllocationUnitSize","Size","SizeRemaining")

try{
    if($DriveLetter.Length -gt 0){
        $DriveLetter = $DriveLetter.Substring(0,1)        
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
    $Script:vol = Get-Volume -CimSession $Script:Cim -DriveLetter $DriveLetter -ErrorAction Stop
    if($AllocationUnitSize -gt 0){
        Format-Volume -InputObject $Script:vol -Full:$Full -FileSystem $FileSystem -AllocationUnitSize $AllocationUnitSize -Force -ErrorAction Stop
    }
    else {
        Format-Volume -InputObject $Script:vol -Full:$Full -FileSystem $FileSystem -Force -ErrorAction Stop
    }
    if(-not [System.String]::IsNullOrWhiteSpace($NewFileSystemLabel)){
        $null = Set-Volume -InputObject $Script:vol -NewFileSystemLabel $NewFileSystemLabel -ErrorAction Stop
    }

    $result = Get-Volume -CimSession $Script:Cim -DriveLetter $DriveLetter | Select-Object $Script:Properties
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