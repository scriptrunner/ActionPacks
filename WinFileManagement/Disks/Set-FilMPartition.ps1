#Requires -Version 4.0

<#
.SYNOPSIS
    Sets attributes of a partition

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

.Parameter PartitionNumber
    Specifies the number of the partition

.Parameter ComputerName
    Specifies the name of the computer on which the partition modifies. If Computername is not specified, the current computer is used.
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter NewDriveLetter
    Specifies the new drive letter for the partition

.Parameter IsActive
    Specifies that the object is marked active

.Parameter IsHidden
    Specifies that is a hidden partition

.Parameter IsOffline
    Takes the partition offline until explicitly brought back online, or until an access path is added to the partition

.Parameter IsReadOnly
    Sets the partition to be read-only
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [int]$Number,
    [Parameter(Mandatory = $true)]
    [int]$PartitionNumber,
    [string]$NewDriveLetter,
    [bool]$IsActive,
    [bool]$IsHidden,
    [bool]$IsOffline,
    [bool]$IsReadOnly,
    [string]$ComputerName,
    [PSCredential]$AccessAccount
)

$Script:Cim=$null
[string[]]$Script:Properties = @("PartitionNumber","DriveLetter","DiskNumber","IsActive","IsHidden","IsOffline","IsReadOnly")

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
    $Script:Parti = Get-Partition -CimSession $Script:Cim -DiskNumber $Number -PartitionNumber $PartitionNumber -ErrorAction Stop
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'InputObject' = $Script:Parti}

    if(-not [System.String]::IsNullOrWhiteSpace($NewDriveLetter)){
        $null = Set-Partition @cmdArgs -NewDriveLetter $NewDriveLetter.ToUpper() -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('IsActive') -eq $true){
        $null = Set-Partition @cmdArgs -IsActive $IsActive -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('IsReadOnly') -eq $true){
        $null = Set-Partition @cmdArgs -IsReadOnly $IsReadOnly -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('IsOffline') -eq $true){
        $null = Set-Partition @cmdArgs -IsOffline $IsOffline -ErrorAction Stop
    }
    if($PSBoundParameters.ContainsKey('IsHidden') -eq $true){
        $null = Set-Partition @cmdArgs -IsHidden $IsHidden -ErrorAction Stop
    }

    $Script:Parti = Get-Partition -CimSession $Script:Cim -DiskNumber $Number -PartitionNumber $PartitionNumber -ErrorAction Stop | Select-Object $Script:Properties
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