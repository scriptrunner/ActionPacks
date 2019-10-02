#Requires -Version 5.1

<#
.SYNOPSIS
    Sets a backup target to a backup policy

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/Server/Backup

.Parameter NetworkPath 
    Specifies the path to the remote shared folder in which the server stores backups

.Parameter DriveLetter
    Specifies the drive letter of the volume that stores backups

.Parameter RemovableDriveLetter
    Specifies the drive letter of the DVD or removable drive that you use as a backup target

.Parameter NetworkCredential
    Specifies a PSCredential object that contains the user name and password for a user account that has access permissions for a location where the server stores backups.

.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "Disk")]
    [string]$DriveLetter,
    [Parameter(Mandatory = $true,ParameterSetName = "Network share")]
    [string]$NetworkPath,
    [Parameter(ParameterSetName = "Network share")]
    [PSCredential]$NetworkCredential,
    [Parameter(Mandatory = $true,ParameterSetName = "Removable drive")]
    [string]$RemovableDriveLetter,
    [Parameter(ParameterSetName = "Disk")]
    [Parameter(ParameterSetName = "Network share")]
    [Parameter(ParameterSetName = "Removable drive")]
    [string]$ComputerName,    
    [Parameter(ParameterSetName = "Disk")]
    [Parameter(ParameterSetName = "Network share")]
    [Parameter(ParameterSetName = "Removable drive")]
    [PSCredential]$AccessAccount
)

try{
    $Script:output
        
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $false){
        if($null -eq $AccessAccount){
            if($PSCmdlet.ParameterSetName  -eq "Network share"){
                if($null -eq $NetworkCredential){
                    $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                        $target = New-WBBackupTarget -NetworkPath $Using:NetworkPath -ErrorAction Stop;
                        $pol = Get-WBPolicy -Editable -ErrorAction Stop;
                        $null = Add-WBBackupTarget -Policy $pol -Target $target -Force -ErrorAction Stop;
                        $null = Set-WBPolicy -Policy $pol -ErrorAction Stop;
                        Get-WBBackupTarget -Policy $pol -ErrorAction Stop
                    } -ErrorAction Stop
                }
                else {
                    $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                        $target = New-WBBackupTarget -NetworkPath $Using:NetworkPath -Credential $Using:NetworkCredential -ErrorAction Stop;
                        $pol = Get-WBPolicy -Editable -ErrorAction Stop;
                        $null = Add-WBBackupTarget -Policy $pol -Target $target -Force -ErrorAction Stop;
                        $null = Set-WBPolicy -Policy $pol -ErrorAction Stop;
                        Get-WBBackupTarget -Policy $pol -ErrorAction Stop
                    } -ErrorAction Stop
                }
            }
            elseif($PSCmdlet.ParameterSetName  -eq "Disk"){
                $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                    $target = New-WBBackupTarget -VolumePath $Using:DriveLetter -ErrorAction Stop;
                    $pol = Get-WBPolicy -Editable -ErrorAction Stop;
                    $null = Add-WBBackupTarget -Policy $pol -Target $target -Force -ErrorAction Stop;
                    $null = Set-WBPolicy -Policy $pol -ErrorAction Stop;
                    Get-WBBackupTarget -Policy $pol -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName  -eq "Removable drive"){
                $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                    $target = New-WBBackupTarget -RemovableDrive $Using:RemovableDriveLetter -ErrorAction Stop;
                    $pol = Get-WBPolicy -Editable -ErrorAction Stop;
                    $null = Add-WBBackupTarget -Policy $pol -Target $target -Force -ErrorAction Stop;
                    $null = Set-WBPolicy -Policy $pol -ErrorAction Stop;
                    Get-WBBackupTarget -Policy $pol -ErrorAction Stop
                } -ErrorAction Stop
            }
        }
        else {
            if($PSCmdlet.ParameterSetName  -eq "Network share"){
                if($null -eq $NetworkCredential){
                    $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock {
                        $target = New-WBBackupTarget -NetworkPath $Using:NetworkPath -ErrorAction Stop;
                        $pol = Get-WBPolicy -Editable -ErrorAction Stop;
                        $null = Add-WBBackupTarget -Policy $pol -Target $target -Force -ErrorAction Stop;
                        $null = Set-WBPolicy -Policy $pol -ErrorAction Stop;
                        Get-WBBackupTarget -Policy $pol -ErrorAction Stop
                    }-ErrorAction Stop
                }
                else {
                    $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock {
                        $target = New-WBBackupTarget -NetworkPath $Using:NetworkPath -Credential $Using:NetworkCredential -ErrorAction Stop;
                        $pol = Get-WBPolicy -Editable -ErrorAction Stop;
                        $null = Add-WBBackupTarget -Policy $pol -Target $target -Force -ErrorAction Stop;
                        $null = Set-WBPolicy -Policy $pol -ErrorAction Stop;
                        Get-WBBackupTarget -Policy $pol -ErrorAction Stop
                    } -ErrorAction Stop
                }
            } 
            elseif($PSCmdlet.ParameterSetName  -eq "Disk"){
                $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock {
                    $target = New-WBBackupTarget -VolumePath $Using:DriveLetter -ErrorAction Stop;
                    $pol = Get-WBPolicy -Editable -ErrorAction Stop;
                    $null = Add-WBBackupTarget -Policy $pol -Target $target -Force -ErrorAction Stop;
                    $null = Set-WBPolicy -Policy $pol -ErrorAction Stop;
                    Get-WBBackupTarget -Policy $pol -ErrorAction Stop   
                } -ErrorAction Stop
            } 
            elseif($PSCmdlet.ParameterSetName  -eq "Removable drive"){
                $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock {
                    $target = New-WBBackupTarget -RemovableDrive $Using:RemovableDriveLetter -ErrorAction Stop;
                    $pol = Get-WBPolicy -Editable -ErrorAction Stop;
                    $null = Add-WBBackupTarget -Policy $pol -Target $target -Force -ErrorAction Stop;
                    $null = Set-WBPolicy -Policy $pol -ErrorAction Stop;
                    Get-WBBackupTarget -Policy $pol -ErrorAction Stop
                } -ErrorAction Stop
            }
        }
    }
    else {
        $Script:target
        if($PSCmdlet.ParameterSetName  -eq "Network share"){
            if($null -eq $NetworkCredential){
                $Script:target = New-WBBackupTarget -NetworkPath $NetworkPath -ErrorAction Stop
            }
            else {
                $Script:target = New-WBBackupTarget -NetworkPath $NetworkPath -Credential $NetworkCredential -ErrorAction Stop
            }
        }
        elseif($PSCmdlet.ParameterSetName  -eq "Disk"){
            $Script:target = New-WBBackupTarget -VolumePath $DriveLetter -ErrorAction Stop
        }
        elseif($PSCmdlet.ParameterSetName  -eq "Removable drive"){
            $Script:target = New-WBBackupTarget -RemovableDrive $RemovableDriveLetter -ErrorAction Stop
        }
        $pol = Get-WBPolicy -Editable -ErrorAction Stop
        $null = Add-WBBackupTarget -Policy $pol -Target $Script:target -Force -ErrorAction Stop
        $null = Set-WBPolicy -Policy $pol -ErrorAction Stop
        $Script:output = Get-WBBackupTarget -Policy $pol -ErrorAction Stop
    }
    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:output
    }
    else{
        Write-Output $Script:output
    }
}
catch{
    throw
}
finally{
}