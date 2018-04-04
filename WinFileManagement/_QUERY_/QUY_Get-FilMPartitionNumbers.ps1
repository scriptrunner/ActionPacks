#Requires -Version 4.0

<#
.SYNOPSIS
    Returns a list of the partition numbers on the disk

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
    © AppSphere AG

.COMPONENT
    
.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinFileManagement/_QUERY_

.Parameter DiskNumber
    Specifies the disk number

.Parameter ComputerName
    Specifies the name of the computer from which to retrieve the partition informations. If Computername is not specified, the current computer is used.
        
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [int]$DiskNumber,
    [string]$ComputerName,
    [PSCredential]$AccessAccount
)

$Script:Cim=$null
$Script:output = @()
try{ 
    if([System.String]::IsNullOrWhiteSpace($Properties)){
        $Properties=@('*')
    }
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName=[System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim =New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim =New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }         
    $result = Get-Partition -CimSession $Script:Cim -DiskNumber $DiskNumber | Select-Object @("DiskNumber","PartitionNumber","DriveLetter")
    if($SRXEnv) {
        $SRXEnv.ResultList =@()
        $SRXEnv.ResultList2 =@()
    }
    foreach($item in $result){
        if($SRXEnv) {       
            $SRXEnv.ResultList += $item.PartitionNumber # Value            
            $SRXEnv.ResultList2 += "PartitionNumber:$($item.PartitionNumber.ToString()) - DriveLetter:$($item.DriveLetter) - DiskNumber:$($item.DiskNumber.ToString())" # Display
        }
        else{
            Write-Output $item.name
        }
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