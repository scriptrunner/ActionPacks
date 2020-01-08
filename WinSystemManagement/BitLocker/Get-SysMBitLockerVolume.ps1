#Requires -Version 4.0

<#
.SYNOPSIS
    Gets information about volumes that BitLocker can protect

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
    Specifies the drive letter, if the parameter empty all volumes retrieved

.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter Properties
    List of properties to expand, comma separated e.g. VolumeStatus,EncryptionMethod. Use * for all properties
#>

[CmdLetBinding()]
Param(
    [string]$DriveLetter,
    [string]$ComputerName,    
    [PSCredential]$AccessAccount,
    [ValidateSet('*','MountPoint','EncryptionMethod','VolumeStatus','ProtectionStatus','EncryptionPercentage','VolumeType','CapacityGB')]
    [string[]]$Properties = @('MountPoint','EncryptionMethod','VolumeStatus','ProtectionStatus','EncryptionPercentage','VolumeType','CapacityGB')
)

try{
    $Script:output
    
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){
        if([System.String]::IsNullOrWhiteSpace($DriveLetter) -eq - $false){
            $Script:output = Get-BitLockerVolume -ErrorAction Stop | Select-Object $Properties
        }
        else {
            $Script:output = Get-BitLockerVolume -MountPoint $DriveLetter -ErrorAction Stop | Select-Object $Properties
        }
    }
    else {
        if($null -eq $AccessAccount){
            if([System.String]::IsNullOrWhiteSpace($DriveLetter) -eq - $false){
                $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Get-BitLockerVolume -ErrorAction Stop | Select-Object $Using:Properties
                }  -ErrorAction Stop
            }
            else {
                $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Get-BitLockerVolume -MountPoint $Using:DriveLetter -ErrorAction Stop | Select-Object $Using:Properties
                } -ErrorAction Stop
            }        
        }
        else {
            if([System.String]::IsNullOrWhiteSpace($DriveLetter) -eq - $false){
                $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    Get-BitLockerVolume -ErrorAction Stop | Select-Object $Using:Properties
                }  -ErrorAction Stop
            }
            else {
                $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    Get-BitLockerVolume -MountPoint $Using:DriveLetter -ErrorAction Stop | Select-Object $Using:Properties
                } -ErrorAction Stop
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