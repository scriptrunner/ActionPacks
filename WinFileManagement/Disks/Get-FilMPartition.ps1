#Requires -Version 4.0

<#
.SYNOPSIS
    Returns a list of all partition objects visible on the disk

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
    Specifies the disk number. If the parameter less than 0, all disks are retrieved

.Parameter DriveLetter
    Specifies a letter used to identify a drive or volume in the system. Specifically the drive on which the partition resides

.Parameter ComputerName
    Specifies the name of the computer from which to retrieve the partition informations. If Computername is not specified, the current computer is used.
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter Properties
    List of properties to expand, comma separated e.g. Name,Description. Use * for all properties
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "ByNumber")]
    [int]$Number = -1,
    [Parameter(Mandatory = $true,ParameterSetName = "ByDriveLetter")]
    [string]$DriveLetter,
    [Parameter(ParameterSetName = "ByNumber")]
    [Parameter(ParameterSetName = "ByDriveLetter")]
    [string]$ComputerName,
    [Parameter(ParameterSetName = "ByNumber")]
    [Parameter(ParameterSetName = "ByDriveLetter")]
    [PSCredential]$AccessAccount,
    [Parameter(ParameterSetName = "ByNumber")]
    [Parameter(ParameterSetName = "ByDriveLetter")]
    [ValidateSet('*','PartitionNumber','OperationalStatus','Type','DriveLetter','DiskNumber','IsActive','IsBoot','IsOffline','IsSystem','Size')]
    [string[]]$Properties = @('PartitionNumber','OperationalStatus','Type','DriveLetter','DiskNumber','IsActive','IsBoot','IsOffline','IsSystem','Size')
)

$Script:Cim=$null
$Script:output = @()
try{ 
    if($Properties -contains '*'){
        $Properties = @('*')
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
    if($PSCmdlet.ParameterSetName  -eq "ByNumber"){
        if($Number -lt 0){
            $Script:output = Get-Partition -CimSession $Script:Cim -ErrorAction Stop | Select-Object $Properties
        }
        else {
            $Script:output = Get-Partition -CimSession $Script:Cim -DiskNumber $Number -ErrorAction Stop | Select-Object $Properties
        }
    }
    else{
        $Script:output = Get-Partition -CimSession $Script:Cim -DriveLetter $DriveLetter -ErrorAction Stop | Select-Object $Properties
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