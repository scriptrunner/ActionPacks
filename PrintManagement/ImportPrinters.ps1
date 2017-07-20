# Requires -Modules PrintManagement

<#
.SYNOPSIS
Import print ports and printers from csv file to a print server.

.DESCRIPTION
Import print ports and printers from csv file to a print server. Script must be executed at the print server.

.PARAMETER CsvPath
Path where csv file is loacted. 

.PARAMETER FileExtension
Fileexteension of the source csv file.

.PARAMETER MaxJobCount
Maximum number of concurrent executed jobs.

.EXAMPLE

.\ImportPrinters.ps1 -CsvPath 'C:\Temp' -FileExtension 'txt'

.NOTES
General notes

CSV file pattern:
#ComputerName;PrinterName;PrinterDriver;PrinterAddress;PrinterName;PrinterLocation;PrinterComment;
HQSRVADM01;PRINTER1;"HP Universal Printing PCL 6";192.168.100.110;PRINTER1;Hameln, FRANZ, 1ETG, PRIVAT;HP Universal;
HQSRVADM01;PRINTER2;"HP Universal Printing PCL 6";192.168.100.111;PRINTER2;Hameln, FRANZ, 2ETG, PRIVAT;HP Universal;
HQSRVADM01;PRINTER3;"HP Universal Printing PCL 6";192.168.100.112;PRINTER3;Hameln, FRANZ, 3ETG, PRIVAT;HP Universal;

#>

   
[CmdLetBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [string]$CsvPath,
    [string]$FileExtension = 'csv',
    [int]$MaxJobCount = 100
)

Import-Module PrintManagement

Function Write-Log {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [string]$Message,
        [Parameter(Mandatory=$False)]
        [ValidateSet("INFO","WARNING","ERROR","FATAL","DEBUG")]
        [String]$Level = "INFO",
        [Parameter(Mandatory=$False)]
        [string]$LogFilePath
    )

    $timeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
    $line = "$timeStamp [$Level] $Message"
    if($LogFilePath) {
        Add-Content -Path $LogFilePath -Value $line -Encoding UTF8 -PassThru -Force
    }
    else {
        Write-Output $line
    }
}


trap {
    Write-Log -Level ERROR -LogFilePath $logFilePath -Message $_
}


if(Test-Path -Path $CsvPath -ErrorAction SilentlyContinue){
    $jobIDs = New-Object -TypeName System.Collections.ArrayList
    $date = Get-Date -Format "yyyy-MM-dd_HHmmss"
    $logFileName = $PSCmdlet.MyInvocation.MyCommand.Name.Substring(0, $PSCmdlet.MyInvocation.MyCommand.Name.LastIndexOf('.ps1'))
    $logFileName += "_$date.log"
    $logFilePath = Join-Path -Path $CsvPath -ChildPath $logFileName
    $csvFile = Get-ChildItem -Path $CsvPath -Filter "*.$FileExtension" -Recurse -Force | Select-Object -First 1
    if($csvFile){
        Write-Log -LogFilePath $logFilePath -Message "Importing printers from '$($csvFile.FullName)' ..."
        $printers = Import-Csv -Path $CsvFile.FullName -Delimiter ';' -Encoding UTF8 -Header @('ComputerName', 'PrinterName', 'PrinterDriver', 'PrinterAddress', '_PrinterName', 'PrinterLocation', 'PrinterComment') 
        foreach($item in $printers){
            if($item.ComputerName -eq 'ComputerName'){
                continue
            }
            if(-not (Get-PrinterPort -Name $item.PrinterAddress -ErrorAction SilentlyContinue)){
                try {
                    Add-PrinterPort -ComputerName $item.ComputerName -Name $item.PrinterAddress -PrinterHostAddress $item.PrinterAddress -ErrorAction Stop
                    Write-Log -LogFilePath $logFilePath -Message "Add printer port '$($item.PrinterAddress)' for printer '$($item.PrinterName)'."
                }
                catch {
                    Write-Log -Level ERROR -LogFilePath $logFilePath -Message "Failed to add printer port '$($item.PrinterAddress)' for printer '$($item.PrinterName)'."
                }
            }
            else{
                Write-Log -LogFilePath $logFilePath -Message "Printer port '$($item.PrinterAddress)' already exists."
            }
            do {
                $jobs = Get-Job -State Running
                if($jobs -and ($jobs.Count -gt $MaxJobCount)){
                    Start-Sleep -Seconds 5
                }
                else{
                    break
                }
            } while ($true)
            if(-not (Get-Printer -Name $item.PrinterName -ErrorAction SilentlyContinue)){
                try {
                    $job = Add-Printer -ComputerName $item.ComputerName -Name $item.PrinterName -DriverName $item.PrinterDriver -PortName $item.PrinterAddress -Location $item.PrinterLocation -Comment $item.PrinterComment -AsJob -ErrorAction Stop
                    $jobIDs.Add($job.Id)
                    Write-Log -LogFilePath $logFilePath -Message "Started add printer job '$($job.Id)' for '$($item.PrinterName)@$($item.PrinterAddress)'."
                }
                catch {
                    Write-Log -Level ERROR -LogFilePath $logFilePath -Message "Failed to add record: '$($item.ComputerName);$($item.PrinterName);$($item.PrinterDriver);$($item.PrinterAddress);'." -ErrorAction Continue
                }
            }
            else{
                Write-Log -LogFilePath $logFilePath -Message "Printer '$($item.PrinterName)' already exists."
            }
        }
    }
    else{
        Write-Log -Level ERROR -LogFilePath $logFilePath -Message "No File with extension '$FileExtension' found in path '$CsvPath'." -ErrorAction Stop
    }
}
else{
    Write-Error -Message "'$CsvPath' does not exist." -ErrorAction Stop
}

Write-Log -LogFilePath $logFilePath -Message "Waiting for job executions ..."
do{
    $jobs = Get-Job -State Running | Where-Object -FilterScript { $jobIds -contains $_.Id }
    
    if($jobs){
        Start-Sleep -Seconds 5
    }
    else {
        break
    }
} while ($true)

$jobs = Get-Job | Where-Object -FilterScript { $jobIds -contains $_.Id }
foreach ($job in $jobs){
    if($job.JobStateInfo.State -eq 'Failed'){
        Write-Log -Level ERROR -LogFilePath $logFilePath -Message "Job '$($job.Id)' failed."
        continue
    }
    if($job.JobStateInfo.State -eq 'Completed'){
        Write-Log -LogFilePath $logFilePath -Message "Job '$($job.Id)' succeed."
        continue
    }
    Write-Log -Level WARNING -LogFilePath $logFilePath -Message "Job '$($job.Id)' is in state '$($job.JobStateInfo.State)'."
}
Write-Log -LogFilePath $logFilePath -Message "Finished script execution."

