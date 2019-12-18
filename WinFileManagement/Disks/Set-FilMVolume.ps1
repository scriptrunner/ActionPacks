#Requires -Version 4.0

<#
.SYNOPSIS
    Sets or changes the file system label of an existing volume

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

.Parameter DedupMode
    Specifies the Data Deduplication mode to use for the volume, if Data Deduplication is enabled on this volume

.Parameter NewFileSystemLabel
    Specifies a new file system label to use

.Parameter ComputerName
    Specifies the name of the computer from which to repair the volume object. If Computername is not specified, the current computer is used.
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(    
    [Parameter(Mandatory = $true)]
    [string]$DriveLetter,
    [string]$NewFileSystemLabel,
    [ValidateSet("None","Disabled","GeneralPurpose","HyperV","Backup","NotAvailable")]
    [string]$DedupMode = "None",
    [string]$ComputerName,
    [PSCredential]$AccessAccount
)

$Script:Cim = $null
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
    if(-not [System.String]::IsNullOrWhiteSpace($NewFileSystemLabel)){
        $null = Set-Volume -InputObject $Script:vol -NewFileSystemLabel $NewFileSystemLabel -ErrorAction Stop
    }
    if($DedupMode -ne "None"){
        $null = Set-Volume -InputObject $Script:vol -DedupMode $DedupMode -ErrorAction Stop
    }

    $result = Get-Volume -CimSession $Script:Cim -DriveLetter $DriveLetter -ErrorAction Stop | Select-Object $Script:Properties
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $result
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