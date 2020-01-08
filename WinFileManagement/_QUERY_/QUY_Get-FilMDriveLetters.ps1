#Requires -Version 4.0

<#
.SYNOPSIS
    Returns a list of all drive letters on the computer

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinFileManagement/_QUERY_

.Parameter ComputerName
    Specifies the name of the computer from which to retrieve the partition informations. If Computername is not specified, the current computer is used.
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [string]$ComputerName,
    [PSCredential]$AccessAccount
)

$Script:Cim=$null
try{ 
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName=[System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim =New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim =New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }         
    $result = Get-Partition -CimSession $Script:Cim | Select-Object @("DiskNumber","PartitionNumber","DriveLetter") | Sort-Object DriveLetter
    
    foreach($item in $result){
        if($SRXEnv) {       
            if([System.Char]::IsLetter($item.DriveLetter.ToString().Substring(0,1))){   
                $null = $SRXEnv.ResultList.Add($item.DriveLetter) # Value            
                $null = $SRXEnv.ResultList2.Add("DriveLetter:$($item.DriveLetter) - DiskNumber:$($item.DiskNumber.ToString()) - PartitionNumber:$($item.PartitionNumber.ToString())") # Display
            }
        }
        else{
            Write-Output $item.DriveLetter
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