#Requires -Version 4.0

<#
.SYNOPSIS
    Suspends Bitlocker encryption for the specified volume

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/BitLocker

.Parameter DriveLetter
    Specifies the drive letter

.Parameter RebootCount
    Specifies the number of computer restarts before BitLocker restores protection. 
    The acceptable values for this parameter are:integers from 0 to 15
 
.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]    
    [string]$DriveLetter,
    [int32]$RebootCount = 0,
    [string]$ComputerName,    
    [PSCredential]$AccessAccount
)

try{
    $Script:output
    [string[]]$Properties = @('MountPoint','EncryptionMethod','VolumeStatus','ProtectionStatus','EncryptionPercentage','VolumeType','CapacityGB')
    
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){
        $null = Suspend-BitLocker -MountPoint $DriveLetter -RebootCount $RebootCount -Confirm:$false -ErrorAction Stop
        $Script:output = Get-BitLockerVolume -MountPoint $DriveLetter | Select-Object $Properties
    }
    else {
        if($null -eq $AccessAccount){
            Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                Suspend-BitLocker -MountPoint $Using:DriveLetter -RebootCount $Using:RebootCount -Confirm:$false -ErrorAction Stop
            } -ErrorAction Stop
            $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                Get-BitLockerVolume -MountPoint $Using:DriveLetter | Select-Object $Using:Properties
            }
        }
        else {
            Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                Suspend-BitLocker -MountPoint $Using:DriveLetter -RebootCount $Using:RebootCount -Confirm:$false -ErrorAction Stop
            } -ErrorAction Stop
            $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                Get-BitLockerVolume -MountPoint $Using:DriveLetter | Select-Object $Using:Properties
            }
        }
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