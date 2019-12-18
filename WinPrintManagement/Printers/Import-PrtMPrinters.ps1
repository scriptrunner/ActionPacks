#Requires -Version 4.0
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Creates print ports and printers asyncron from csv file to a print server. 

.DESCRIPTION
    Import print ports and printers from csv file to a print server. Script must be executed at the print server.

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

.Parameter CsvFile
    Specifies the path and filename of the CSV file to import

.Parameter Delimiter
    Specifies the delimiter that separates the property values in the CSV file

.Parameter FileEncoding
    Specifies the type of character encoding that was used in the CSV file

.Parameter MaxJobCount
    Maximum number of concurrent executed jobs.
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter DefaultDataType
    Specifies the default data type the printer uses to record print jobs

.Parameter DefaultProcessor
    Specifies the default name of the print processor used by the printer

.Parameter DefaultPortAddress
    Specifies the default name of the port that is used or created for the printer

.Parameter DefaultPortNumber
    Specifies the default TCP/IP port number for the printer port added to the specified computer

.Parameter DefaultRenderingMode
    Specifies the default rendering mode for the printer

.EXAMPLE
    .\Import-Printers.ps1 -CsvFile 'C:\Temp\printers.csv'
    
    CSV file pattern:
    #ComputerName;PrinterName;PrinterDriver;PortAddress;PortNumber;Shared;DifferentShareName;Comment;Location;Datatype;PrintProcessor;RenderingMode

    HQSRVADM01;PRINTER1;"HP Universal Printing PCL 6";192.168.100.110;9100;True;PRINTER1;"Printer 1";DE, Ettlingen, Ludwig-Erhard-Str. 2, 1.OG, Raum 101;RAW;WinPrint;SSR
    HQSRVADM01;PRINTER2;"HP Universal Printing PCL 6";192.168.100.111;9100;False;PRINTER2;"Printer 2";DE, Ettlingen, Ludwig-Erhard-Str. 2, 2.OG, Raum 212;RAW;WinPrint;SSR
    HQSRVADM01;PRINTER3;"HP Universal Printing PCL 6";192.168.100.112;9100;True;PRINTER3;"Printer 3";DE, Ettlingen, Ludwig-Erhard-Str. 2, 3.OG, Raum 308;RAW;WinPrint;SSR
#>
   
[CmdLetBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [string]$CsvFile,
    [string]$Delimiter= ';',
    [ValidateSet('Unicode','UTF7','UTF8','ASCII','UTF32','BigEndianUnicode','Default','OEM')]
    [string]$FileEncoding = 'UTF8',
    [int]$MaxJobCount = 100,
    [PSCredential]$AccessAccount,
    [string]$DefaultDataType='RAW',
    [string]$DefaultProcessor='winprint',
    [string]$DefaultPortAddress='LPT1:',
    [int]$DefaultPortNumber=9100,
    [ValidateSet('SSR','CSR','BranchOffice')]
    [string]$DefaultRenderingMode='SSR'
)

Import-Module PrintManagement

[int]$Script:PortNumber = 0
[bool]$Script:Err = $false
$Script:Cim = $null
$Script:Result = @()
$Script:Output = @()
$Script:Errors = @()
$Script:Failed = New-Object  "System.Collections.Generic.List[String]"
$Script:Jobs = New-Object "System.Collections.Generic.Dictionary[Int,string]"
try{
    if(Test-Path -Path $CsvFile -ErrorAction SilentlyContinue){
        $Script:Printers = Import-Csv -Path $CsvFile -Delimiter $Delimiter -Encoding $FileEncoding -ErrorAction Stop `
            -Header @('ComputerName', 'PrinterName', 'PrinterDriver', 'PortAddress','PortNumber', 'Shared', 'DifferentShareName', 'Comment','Location','DataType','PrintProcessor','RenderingMode') 
        }
    else{
        Throw "$($CsvFile) does not exist"
    }
    # Create Ports
    foreach($item in $Script:Printers){        
        if($item.ComputerName -eq 'ComputerName'){
            continue
        }
        $Script:Cim = $null
        $Script:PortNumber = 0
        if([System.string]::IsNullOrWhiteSpace($item.PortAddress)){
            $item.PortAddress = $DefaultPortAddress
        }
        if([System.string]::IsNullOrWhiteSpace($item.PortNumber)){
            $Script:PortNumber = $DefaultPortNumber
        }
        else{
            if(-not [System.Int32]::TryParse($item.PortNumber,[ref] $Script:PortNumber)){
                $Script:Errors += "Printer port number $($item.PortNumber) is not a valid number"
                $Script:Err = $true
                $Script:PortNumber = $DefaultPortNumber
            }
        }        
        if([System.string]::IsNullOrWhiteSpace($item.ComputerName)){
            $item.ComputerName = [System.Net.DNS]::GetHostByName('').HostName
        }          
        if($null -eq $AccessAccount){
            $Script:Cim = New-CimSession -ComputerName $item.ComputerName -ErrorAction Stop
        }
        else {
            $Script:Cim = New-CimSession -ComputerName $item.ComputerName -Credential $AccessAccount -ErrorAction Stop
        } 
        if(Get-PrinterPort -CimSession $Script:Cim -Name $item.PortAddress -ComputerName $item.ComputerName -ErrorAction SilentlyContinue ){
            $Script:Output += "Printer port $($item.PortAddress) already exists"
            continue
        }
        else{
            $Error.RemoveAt(0)
            $job = Add-PrinterPort -AsJob -CimSession $Script:Cim -Name $item.PortAddress -ComputerName $item.ComputerName -PrinterHostAddress $item.PortAddress -PortNumber $Script:PortNumber -ErrorAction Stop
            $Script:Jobs.Add($job.ID,$item.PortAddress)
        }
        # Check max. jobs
        do{
            $tmp = Get-Job -State Running | Where-Object -FilterScript { $Script:Jobs.Keys -contains $_.Id }            
            if($tmp -and $tmp.Count -gt $MaxJobCount){
                Start-Sleep -Seconds 5
            }
            else {
                break
            }
        } while ($true)
    }
    # Wait for jobs finish
    do{
        $tmp = Get-Job -State Running | Where-Object -FilterScript { $Script:Jobs.Keys -contains $_.Id }            
        if($tmp){
            Start-Sleep -Seconds 5 # wait
        }
        else {
            break
        }
    } while ($true)
    # Check job results
    $tmp = Get-Job | Where-Object -FilterScript { $Script:Jobs.Keys -contains $_.Id }
    foreach ($job in $tmp){
        if($job.JobStateInfo.State -eq 'Failed'){
            $Script:Errors += "Create printer port: $($Script:Jobs[$job.Id]) failed."
            $Script:Failed.Add($Script:Jobs[$job.Id])
            $Script:Err = $true
        }
        if($job.JobStateInfo.State -eq 'Completed'){
            $Script:Result += "Create printer port: $($Script:Jobs[$job.Id]) succeeded"
            continue
        }
    }
    $Script:Jobs.CLear()
    [bool]$Script:Shared = $false
     # Create Printers
    foreach($item in $Script:Printers){  
        if($item.ComputerName -eq 'ComputerName'){
            continue
        }
        $Script:Cim = $null
        if($null -eq $AccessAccount){
            $Script:Cim = New-CimSession -ComputerName $item.ComputerName
        }
        else {
            $Script:Cim = New-CimSession -ComputerName $item.ComputerName -Credential $AccessAccount
        }  
        if($Script:Failed.Contains($item.PortAddress)){
            $Script:Errors += "Printer port: $($item.PortAddress) for printer $($item.PrinterName) erroneous."
            continue
        }
        try{
            $tmp=[System.Boolean]::TryParse($item.Shared,[ref] $Script:Shared)
            if([System.String]::IsNullOrWhiteSpace($item.DifferentShareName)){
                $item.DifferentShareName = $item.PrinterName
            }
            if([System.String]::IsNullOrWhiteSpace($item.DataType)){
                $item.DataType = $DefaultDataType
            }
            if([System.String]::IsNullOrWhiteSpace($item.PrintProcessor)){
                $item.PrintProcessor = $DefaultProcessor
            }
            if([System.String]::IsNullOrWhiteSpace($item.RenderingMode)){
                $item.RenderingMode = $DefaultRenderingMode
            }
            if(Get-Printer -Name $item.PrinterName -ComputerName $item.ComputerName -CimSession $Script:Cim -ErrorAction SilentlyContinue ){
                $Script:Output += "Printer $($item.PrinterName) already exists"
                continue
            }
            else{
                $Error.RemoveAt(0)
                $job = Add-Printer -AsJob -ComputerName $item.ComputerName -Shared:$Script:Shared -ShareName $item.DifferentShareName -Name $item.PrinterName -CimSession $Script:Cim `
                        -PrintProcessor $item.PrintProcessor -Comment $item.Comment -PortName $item.PortAddress -DriverName $item.PrinterDriver `
                        -Location $item.Location -RenderingMode $item.RenderingMode -Datatype $item.DataType -ErrorAction Stop
                $Script:Jobs.Add($job.ID,$item.PrinterName)
            }            
        }
        catch{
            $Script:Errors +=  "Error add printer: $($item.PrinterName) / $($_.Exception.Message)"
            $Script:Err=$true
        }
    }
    # Wait for jobs finish
    do{
        $tmp = Get-Job -State Running | Where-Object -FilterScript { $Script:Jobs.Keys -contains $_.Id }            
        if($tmp){
            Start-Sleep -Seconds 5 # wait
        }
        else {
            break
        }
    } while ($true)
    # Check job results
    $tmp = Get-Job | Where-Object -FilterScript { $Script:Jobs.Keys -contains $_.Id }
    foreach ($job in $tmp){
        if($job.JobStateInfo.State -eq 'Failed'){
            $Script:Errors += "Create printer: $($Script:Jobs[$job.Id]) failed."
            $Script:Failed.Add($Script:Jobs[$job.Id])
            $Script:Err=$true
        }
        if($job.JobStateInfo.State -eq 'Completed'){
            $Script:Result += "Create printer: $($Script:Jobs[$job.Id]) succeeded"
            continue
        }
    }
    
    if($SRXEnv) {
        if($Script:Err -eq $true){
            $SRXEnv.ResultMessage = $Script:Errors
            Write-Output $Script:Result
        }
        else{
            $SRXEnv.ResultMessage = $Script:Result
        }
    } 
    else{
        if($Script:Err -eq $true){
            Write-Output $Script:Errors
        }
        Write-Output $Script:Result
    }
    Write-Output $Script:Output
    if($Script:Err -eq $true){
        Throw "An error has occurred"
    }
}
catch{
    Throw $_.Exception.Message
}
finally{
    if($null -ne $Script:Cim){
        Remove-CimSession $Script:Cim 
    }
}