#Requires -Version 4.0

<#
.SYNOPSIS
    Enables or disables the System Restore feature on the specified file system drive

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/Clients/ComputerRestore

.Parameter EnableRestore
    Specifies the status of computer restore

.Parameter DriveLetter
    Specifies the drive letter, enter a file system drive letter, followed by a colon and a backslash 

.Parameter DiskSpaceUsagePercent
    Specifies the Disk Space Usage in percent
 
.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]    
    [string]$DriveLetter,
    [bool]$EnableRestore,
    [ValidateRange(1,100)]
    [int]$DiskSpaceUsagePercent = 1,
    [string]$ComputerName,    
    [PSCredential]$AccessAccount
)

try{
    $Script:output
    
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){
        if($EnableRestore -eq $true){
            $null = Enable-ComputerRestore -Drive $DriveLetter -Confirm:$false -ErrorAction Stop
        }
        else {
            $null = Disable-ComputerRestore -Drive $DriveLetter -Confirm:$false -ErrorAction Stop
        }
        vssadmin resize shadowstorage /for=$DriveLetter /on=$DriveLetter /maxsize="$($DiskSpaceUsagePercent)%"
    }
    else {
        if($null -eq $AccessAccount){
            if($EnableRestore -eq $true){
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Enable-ComputerRestore -Drive $Using:DriveLetter -Confirm:$false -ErrorAction Stop;
                    vssadmin resize shadowstorage /for=$Using:DriveLetter /on=$Using:DriveLetter /maxsize="$($Using:DiskSpaceUsagePercent)%"
                } -ErrorAction Stop
            }
            else {
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Disable-ComputerRestore -Drive $Using:DriveLetter -Confirm:$false -ErrorAction Stop;
                    vssadmin resize shadowstorage /for=$Using:DriveLetter /on=$Using:DriveLetter /maxsize="$($Using:DiskSpaceUsagePercent)%"
                } -ErrorAction Stop
            }
        }
        else {
            if($EnableRestore -eq $true){
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    Enable-ComputerRestore -Drive $Using:DriveLetter -Confirm:$false -ErrorAction Stop;
                    vssadmin resize shadowstorage /for=$Using:DriveLetter /on=$Using:DriveLetter /maxsize="$($Using:DiskSpaceUsagePercent)%"
                } -ErrorAction Stop
            }
            else {
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    Disable-ComputerRestore -Drive $Using:DriveLetter -Confirm:$false -ErrorAction Stop;
                    vssadmin resize shadowstorage /for=$Using:DriveLetter /on=$Using:DriveLetter /maxsize="$($Using:DiskSpaceUsagePercent)%"
                } -ErrorAction Stop
            }
        }
    }      
    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Computer Restore enabled is $($EnableRestore.ToString())"
    }
    else{
        Write-Output "Computer Restore enabled is $($EnableRestore.ToString())"
    }
}
catch{
    throw
}
finally{
}