#Requires -Version 4.0
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Gets all printer driver names from the computer

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
    © AppSphere AG

.COMPONENT
    Requires Module PrintManagement

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinPrintManagement/Drivers

.Parameter ComputerName
    Specifies the name of the computer from which to retrieve the printer drivers
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [string]$ComputerName,
    [PSCredential]$AccessAccount
    )

Import-Module PrintManagement

$Script:Cim=$null
try{
    if([System.string]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName=[System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim =New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim =New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }

    if($SRXEnv) {
        $SRXEnv.ResultList =@()
        $SRXEnv.ResultList2 =@()
    }
    $Script:Drivers =Get-PrinterDriver -CimSession $Script:Cim -ComputerName $ComputerName  `
        | Select-Object Name,PrinterEnvironment | Sort-Object Name
    
    foreach($item in $Script:Drivers)
    {
        if($SRXEnv) {
            $SRXEnv.ResultList += $item.Name # key
            $SRXEnv.ResultList2 += "$($item.Name) ($($item.PrinterEnvironment))" # display value
        }
        else{
            Write-Output "$($item.Name) ($($item.PrinterEnvironment))" 
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