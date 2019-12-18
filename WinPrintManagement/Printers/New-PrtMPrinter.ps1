#Requires -Version 4.0
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Create print port and printer 

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinPrintManagement/Printers

.Parameter PrinterName
    Specifies the name of the printer to add

.Parameter DriverName
    Specifies the name of the printer driver for the printer

.Parameter ComputerName
    Specifies the name of the computer to which to add the printer

.Parameter Shared
    Indicates whether to share the printer on the network

.Parameter DifferentSharename
    Specifies the name by which to share the printer on the network

.Parameter PortAddress
    Specifies the name and address of the port that is used or created for the printer

.Parameter PortNumber
    Specifies the TCP/IP port number for the printer port added to the specified computer

.Parameter Comment
    Specifies the text to add to the Comment field for the specified printer

.Parameter Location
    Specifies the location of the printer
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter DataType
    Specifies the data type the printer uses to record print jobs

.Parameter PrintProcessor
    Specifies the name of the print processor used by the printer

.Parameter RenderingMode
    Specifies the rendering mode for the printer
#>

   
[CmdLetBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [string]$PrinterName,
    [Parameter(Mandatory=$true)]
    [string]$DriverName,
    [string]$ComputerName,
    [switch]$Shared,
    [string]$DifferentSharename,
    [string]$PortAddress = 'LPT1:',
    [int]$PortNumber = 9100,
    [string]$Comment,
    [string]$Location,
    [PSCredential]$AccessAccount,
    [string]$DataType = 'RAW',
    [string]$PrintProcessor = 'winprint',
    [ValidateSet('SSR','CSR','BranchOffice')]
    [string]$RenderingMode = 'SSR'
)

Import-Module PrintManagement

$Script:Cim = $null
$Script:Output = @()
try{
    # Create Port
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName = [System.Net.DNS]::GetHostByName('').HostName
    }  
    if($null -eq $AccessAccount){
        $Script:Cim = New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }
    if(Get-PrinterPort -CimSession $Script:Cim -Name $PortAddress -ComputerName $ComputerName -ErrorAction SilentlyContinue ){
        $Script:Output += "Printer port $($PortAddress) already exists"
    }
    else{
        $Error.RemoveAt(0)
        $null = Add-PrinterPort -CimSession $Script:Cim -Name $PortAddress -ComputerName $ComputerName -PrinterHostAddress $PortAddress -PortNumber $PortNumber
        $Script:Output += "Create printer port: $($PortAddress) succeeded"
    }
     # Create Printer
    if([System.String]::IsNullOrWhiteSpace($DifferentSharename)){
        $DifferentSharename = $PrinterName
    }
    if(Get-Printer -CimSession $Script:Cim -Name $PrinterName -ComputerName $ComputerName -ErrorAction SilentlyContinue ){
        $Script:Output += "Printer $($PrinterName) already exists"
    }
    else{
        $Error.RemoveAt(0)
        $null = Add-Printer -CimSession $Script:Cim -ComputerName $ComputerName -Shared:$Shared.ToBool() -ShareName $DifferentShareName -Name $PrinterName `
                -PrintProcessor $PrintProcessor -Comment $Comment -PortName $PortAddress -DriverName $DriverName `
                -Location $Location -RenderingMode $RenderingMode -Datatype $DataType -ErrorAction Stop
        $Script:Output += "Create printer: $($PrinterName) succeeded"
    }   
    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:Output
    } 
    else {
        Write-Output $Script:Output   
    }    
}
catch{
    Throw 
}
finally{
    if($null -ne $Script:Cim){
        Remove-CimSession $Script:Cim 
    }
}