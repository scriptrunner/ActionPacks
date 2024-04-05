#Requires -Version 5.0
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Sets the properties of an existing printer.
    Only parameters with value are set

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
    [sr-en] Name of the printer to modify

.Parameter ComputerName
    [sr-en] Name of the computer on which the printer is installed

.Parameter DriverName
    [sr-en] Name of the printer driver for the printer

.Parameter Shared
    [sr-en] Share the printer on the network

.Parameter ShareName
    [sr-en] Name by which to share the printer on the network

.Parameter PortName
    [sr-en] Name of the existing port that is used or created for the printer

.Parameter Comment
    [sr-en] Text to add to the Comment field for the specified printer

.Parameter Location
    [sr-en] Location of the printer
    
.Parameter AccessAccount
    [sr-en] User account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter DataType
    [sr-en] Data type the printer uses to record print jobs

.Parameter PrintProcessor
    [sr-en] Name of the print processor used by the printer

.Parameter RenderingMode
    [sr-en] Rendering mode for the printer
#>
   
[CmdLetBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [string]$PrinterName,
    [string]$ComputerName,
    [string]$DriverName,
    [switch]$Shared,
    [string]$ShareName,
    [string]$PortName,
    [string]$Comment,
    [string]$Location,
    [PSCredential]$AccessAccount,
    [string]$DataType='RAW',
    [string]$PrintProcessor='winprint',
    [ValidateSet('SSR','CSR','BranchOffice')]
    [string]$RenderingMode='SSR'
)

Import-Module PrintManagement

$Script:Cim = $null
$Script:Output = @()
try{
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName = [System.Net.DNS]::GetHostByName('').HostName
    }  
    if($null -eq $AccessAccount){
        $Script:Cim = New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }
    $prn = Get-Printer -CimSession $Script:Cim -Name $PrinterName -ComputerName $ComputerName -ErrorAction SilentlyContinue 
    if($null -eq $prn){
        $Script:Output += "Printer $($PrinterName) not found"
    }
    else{
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                                'CimSession' = $Script:Cim
                                'ComputerName' = $ComputerName
                                'Name' = $PrinterName
                                'Confirm' = $false}
        if($PSBoundParameters.ContainsKey('Shared') -eq $true){
            if([System.String]::IsNullOrWhiteSpace($ShareName)){
                $ShareName=$PrinterName
            }
            $null = Set-Printer @cmdArgs -Shared -ShareName $ShareName
        }
        if($PSBoundParameters.ContainsKey('PrintProcessor') -eq $true){
            $null = Set-Printer -PrintProcessor $PrintProcessor
        }
        if($PSBoundParameters.ContainsKey('Comment') -eq $true){
            $null =  Set-Printer @cmdArgs -Comment $Comment
        }
        if($PSBoundParameters.ContainsKey('DriverName') -eq $true){
            $null = Set-Printer @cmdArgs -DriverName $DriverName
        }
        if($PSBoundParameters.ContainsKey('Location') -eq $true){
            $null = Set-Printer @cmdArgs -Location $Location
        }
        if($PSBoundParameters.ContainsKey('Datatype') -eq $true){
            $null = Set-Printer @cmdArgs -Datatype $Datatype
        }
        if($PSBoundParameters.ContainsKey('RenderingMode') -eq $true){
            $null = Set-Printer @cmdArgs -RenderingMode $RenderingMode
        }
        if($PSBoundParameters.ContainsKey('PortName') -eq $true){
            $null = Set-Printer @cmdArgs -PortName $PortName
        }
        $Script:Output += "Printer: $($PrinterName) changed"
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