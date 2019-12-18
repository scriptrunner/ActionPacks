#Requires -Version 4.0
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Install printer drivers asyncron from csv file to a print server. 

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

    CSV file pattern:
    DriverName;ComputerName;InfFilePath

    "Microsoft PS Class Driver";;
    "Xerox FFPS Class Driver";Computer3000;
    "HP Universal Printing PCL 5";Computer1;"C:\Windows\Inf\hpcu130t.inf"

.COMPONENT
    Requires Module PrintManagement

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinPrintManagement/Drivers

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

.EXAMPLE
    .\Import-PrinterDrivers.ps1 -CsvFile 'C:\Temp\drivers.csv'
#>
   
[CmdLetBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [string]$CsvFile,
    [string]$Delimiter= ';',
    [ValidateSet('Unicode','UTF7','UTF8','ASCII','UTF32','BigEndianUnicode','Default','OEM')]
    [string]$FileEncoding = 'UTF8',
    [int]$MaxJobCount = 100,
    [PSCredential]$AccessAccount
)

Import-Module PrintManagement

[bool]$Script:Err = $false
$Script:Cim = $null
$Script:Result = @()
$Script:Errors = @()
$Script:Output = @()
$Script:Failed = New-Object  "System.Collections.Generic.List[String]"
$Script:Jobs = New-Object "System.Collections.Generic.Dictionary[Int,string]"
try{
    if(Test-Path -Path $CsvFile -ErrorAction SilentlyContinue){
        $Script:Drivers = Import-Csv -Path $CsvFile -Delimiter $Delimiter -Encoding $FileEncoding `
            -Header @('DriverName','ComputerName', 'InfFilePath')  -ErrorAction Stop
        }
    else{
        Throw "$($CsvFile) does not exist"
    }
    # Install drivers
    foreach($item in $Script:Drivers){        
        if($item.ComputerName -eq 'ComputerName'){
            continue
        }
        if([System.string]::IsNullOrWhiteSpace($item.ComputerName)){
            $item.ComputerName=[System.Net.DNS]::GetHostByName('').HostName
        }          
        if($null -eq $AccessAccount){
            $Script:Cim = New-CimSession -ComputerName $item.ComputerName -ErrorAction Stop
        }
        else {
            $Script:Cim = New-CimSession -ComputerName $item.ComputerName -Credential $AccessAccount -ErrorAction Stop
        } 
        if(Get-PrinterDriver -CimSession $Script:Cim -Name $item.DriverName.Trim() -ComputerName $item.ComputerName -ErrorAction SilentlyContinue ){
            $Script:Output += "Printer driver $($item.DriverName) already exists"
            continue
        }
        else{
            $Error.RemoveAt(0)
            if([System.String]::IsNullOrWhiteSpace($item.InfFilePath)){
                $job = Add-PrinterDriver -AsJob -CimSession $Script:Cim -Name $item.DriverName.Trim() -ComputerName $item.ComputerName 
            }
            else {
                $job = Add-PrinterDriver -AsJob -CimSession $Script:Cim -Name $item.DriverName.Trim() -ComputerName $item.ComputerName -InfPath $item.InfFilePath
            }
            $Script:Jobs.Add($job.ID,$item.DriverName)
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
            $Script:Errors += "Install printer driver: $($Script:Jobs[$job.Id]) failed."
            $Script:Failed.Add($Script:Jobs[$job.Id])
            $Script:Err = $true
        }
        if($job.JobStateInfo.State -eq 'Completed'){
            $Script:Result += "Install printer driver: $($Script:Jobs[$job.Id]) succeeded"
            continue
        }
    }
    $Script:Jobs.CLear()
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
    Write-Output $Script:Result
    Write-Output $Script:Output
    Throw $_.Exception.Message
}
finally{
    if($null -ne $Script:Cim){
        Remove-CimSession $Script:Cim 
    }
}