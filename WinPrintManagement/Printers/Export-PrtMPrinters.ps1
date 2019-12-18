#Requires -Version 4.0
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Export local printers from the computer in a csv file. Existing file will be overwritten

.DESCRIPTION
    Export printers in a csv file.

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinPrintManagement/Printers

.Parameter ExportFile
    Specifies the path and filename of the CSV file to export

.Parameter Delimiter
    Specifies the delimiter that separates the property values in the CSV file

.Parameter FileEncoding
    Specifies the type of character encoding that was used in the CSV file

.Parameter ComputerName
    Specifies the name of the computer from which to retrieve the printer information
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter IncludeTcpIpPortProperties
    Specifies the export of the TCP/IP port address and number

.EXAMPLE
    .\Export-Printers.ps1 -ExportFile 'C:\Temp\printers.csv' -IncludePortProperties
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [string]$ExportFile,
    [string]$Delimiter= ';',
    [ValidateSet('Unicode','UTF7','UTF8','ASCII','UTF32','BigEndianUnicode','Default','OEM')]
    [string]$FileEncoding = 'UTF8',
    [string]$ComputerName,
    [PSCredential]$AccessAccount,
    [switch]$IncludeTcpIpPortProperties
)

Import-Module PrintManagement

$Script:Cim = $null
try{
    [string[]]$Properties = @('Name','DriverName','PortName','Shared','Sharename','Comment','Location','Datatype','PrintProcessor','RenderingMode')
    if([System.string]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName = [System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim = New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $ComputerName -Credential $AccessAccount
    }

    $printers = Get-Printer -Full -CimSession $Script:Cim -ComputerName $ComputerName -ErrorAction Stop | Where-Object {$_.Type -eq 'Local'} `
                            | Select-Object $Properties | Sort-Object Name
    $Script:Csv=@()
    $Script:Msg=@()
    $Script:Port
    foreach($item in $printers)
    {
        $tmp= ([ordered] @{            
            ComputerName= $ComputerName
            PrinterName = $item.Name
            PrinterDriver= $item.DriverName
            PortAddress= $item.PortName
            PortNumber = ''
            Shared = $item.Shared
            DifferentShareName = ''
            Comment = $item.Comment
            Location = $item.Location
            Datatype = $item.DataType
            PrintProcessor = $item.PrintProcessor
            RenderingMode = $item.RenderingMode
        }   )
        if($item.Shared -and ($item.Sharename -ne $item.Name)){
            $tmp.DifferentShareName = $item.Sharename
        }
        if($IncludeTcpIpPortProperties){
            try{
                $Script:Port = Get-PrinterPort -CimSession $Script:Cim -Name $item.PortName -ComputerName $ComputerName -ErrorAction SilentlyContinue
                if($null -ne $Script:Port.PrinterHostAddress){
                    $tmp.PortAddress = $Script:Port.PrinterHostAddress                
                    if($null -ne $Script:Port.PortNumber){
                        $tmp.PortNumber =$Script:Port.PortNumber
                    }                
                }
            }
            catch{
                $Script:Msg += "Error get printer port $($item.PortName) / $($_.Exception.Message)"
            }
        }
        $Script:Csv += New-Object PSObject -Property $tmp 
    }
    $Script:Csv | Export-Csv -Path $ExportFile -Delimiter $Delimiter -Encoding $FileEncoding -Force -NoTypeInformation -ErrorAction Stop 

    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Printers exported in file: $($ExportFile)" + $Script:Msg
    }
    else{
        Write-Output "Printers exported in file: $($ExportFile)" 
        Write-Output $Script:Msg
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