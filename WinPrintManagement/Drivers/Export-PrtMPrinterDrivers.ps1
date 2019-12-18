#Requires -Version 4.0
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Export printer drivers from the computer in a csv file. Existing file will be overwritten

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Module PrintManagement

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinPrintManagement/Drivers

.Parameter ExportFile
    Specifies the path and filename of the CSV file to export

.Parameter Delimiter
    Specifies the delimiter that separates the property values in the CSV file

.Parameter FileEncoding
    Specifies the type of character encoding that was used in the CSV file

.Parameter ComputerName
    Specifies the name of the computer from which to retrieve the printer drivers
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.EXAMPLE
    .\Export-PrinterDrivers.ps1 -ExportFile 'C:\Temp\drivers.csv'
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [string]$ExportFile,
    [string]$Delimiter= ';',
    [ValidateSet('Unicode','UTF7','UTF8','ASCII','UTF32','BigEndianUnicode','Default','OEM')]
    [string]$FileEncoding = 'UTF8',
    [string]$ComputerName,
    [PSCredential]$AccessAccount
)

Import-Module PrintManagement

$Script:Cim = $null
try{
    if([System.string]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName=[System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim = New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }
    $drivers = Get-PrinterDriver -CimSession $Script:Cim -ComputerName $ComputerName -ErrorAction Stop  `
        | Select-Object Name,DriverName,InfPath | Sort-Object Name
    
    $Script:Csv = @()
    foreach($item in $drivers) {
        $tmp= ([ordered] @{            
            DriverName = $item.Name
            ComputerName = $ComputerName
            InfFilePath = $item.InfPath
        }   )
        $Script:Csv += New-Object PSObject -Property $tmp 
    }
    $Script:Csv | Export-Csv -Path $ExportFile -Delimiter $Delimiter -Encoding $FileEncoding -Force -NoTypeInformation -ErrorAction Stop 

    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Printer drivers exported in file: $($ExportFile)" 
    }
    else{
        Write-Output "Printer drivers exported in file: $($ExportFile)"
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