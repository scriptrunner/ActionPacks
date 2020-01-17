#Requires -Version 4.0

<#
.SYNOPSIS
    Restores access to data on a BitLocker volume

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    ScriptRunner Version 4.2.x or higher

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/BitLocker

.Parameter DriveLetter
    Specifies the drive letter

.Parameter AdAccountOrGroup
    Indicates that BitLocker requires account credentials to unlock the volume

.Parameter Password
    Specifes a string that contains a password. The password specified acts as a protector for the volume encryption key

.Parameter RecoveryPassword
    Specifies a recovery password. The password specified acts as a protector for the volume encryption key

.Parameter RecoveryKeyPath
    Specifies the path to a recovery key. The key stored in the specified path acts as a protector for the volume encryption
 
.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "AdAccountOrGroup")]    
    [Parameter(Mandatory = $true, ParameterSetName = "ByPassword")] 
    [Parameter(Mandatory = $true, ParameterSetName = "ByRecoveryPassword")]   
    [Parameter(Mandatory = $true, ParameterSetName = "ByRecoveryKeyPath")]     
    [string]$DriveLetter,
    [Parameter(Mandatory = $true, ParameterSetName = "AdAccountOrGroup")]    
    [switch]$AdAccountOrGroup,
    [Parameter(Mandatory = $true, ParameterSetName = "ByPassword")]    
    [securestring]$Password,
    [Parameter(Mandatory = $true, ParameterSetName = "ByRecoveryPassword")]    
    [securestring]$RecoveryPassword,
    [Parameter(Mandatory = $true, ParameterSetName = "ByRecoveryKeyPath")]    
    [string]$RecoveryKeyPath,
    [Parameter(ParameterSetName = "AdAccountOrGroup")]    
    [Parameter(ParameterSetName = "ByPassword")]    
    [Parameter(ParameterSetName = "ByRecoveryPassword")]    
    [Parameter(ParameterSetName = "ByRecoveryKeyPath")]    
    [string]$ComputerName,    
    [Parameter(ParameterSetName = "AdAccountOrGroup")]    
    [Parameter(ParameterSetName = "ByPassword")]    
    [Parameter(ParameterSetName = "ByRecoveryPassword")]    
    [Parameter(ParameterSetName = "ByRecoveryKeyPath")]    
    [PSCredential]$AccessAccount
)

try{
    $Script:output
    [string[]]$Properties = @('MountPoint','EncryptionMethod','VolumeStatus','ProtectionStatus','EncryptionPercentage','VolumeType','CapacityGB')
    
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){
        if($PSCmdlet.ParameterSetName -eq "AdAccountOrGroup"){
            $null = Unlock-BitLocker -MountPoint $DriveLetter -AdAccountOrGroup -Confirm:$false -ErrorAction Stop
        }
        elseif($PSCmdlet.ParameterSetName -eq "ByPassword"){
            $null = Unlock-BitLocker -MountPoint $DriveLetter -Password $Password -Confirm:$false -ErrorAction Stop
        }
        elseif($PSCmdlet.ParameterSetName -eq "ByRecoveryPassword"){
            $null = Unlock-BitLocker -MountPoint $DriveLetter -RecoveryPassword $RecoveryPassword -Confirm:$false -ErrorAction Stop
        }
        elseif($PSCmdlet.ParameterSetName -eq "ByRecoveryKeyPath"){
            $null = Unlock-BitLocker -MountPoint $DriveLetter -RecoveryKeyPath $RecoveryKeyPath -Confirm:$false -ErrorAction Stop
        }
        $Script:output = Get-BitLockerVolume -MountPoint $DriveLetter | Select-Object $Properties
    }
    else {
        if($null -eq $AccessAccount){
            if($PSCmdlet.ParameterSetName -eq "AdAccountOrGroup"){
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Unlock-BitLocker -MountPoint $Using:DriveLetter -AdAccountOrGroup -Confirm:$false -ErrorAction Stop
                } -ErrorAction Stop
            } 
            elseif($PSCmdlet.ParameterSetName -eq "ByPassword"){
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Unlock-BitLocker -MountPoint $Using:DriveLetter -Password $Using:Password -Confirm:$false -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "ByRecoveryPassword"){
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Unlock-BitLocker -MountPoint $Using:DriveLetter -RecoveryPassword $Using:RecoveryPassword -Confirm:$false -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "ByRecoveryKeyPath"){
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Unlock-BitLocker -MountPoint $Using:DriveLetter -RecoveryKeyPath $Using:RecoveryKeyPath -Confirm:$false -ErrorAction Stop
                } -ErrorAction Stop
            }
            $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                Get-BitLockerVolume -MountPoint $Using:DriveLetter | Select-Object $Using:Properties
            }
        }
        else {
            if($PSCmdlet.ParameterSetName -eq "AdAccountOrGroup"){
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    Unlock-BitLocker -MountPoint $Using:DriveLetter -AdAccountOrGroup -Confirm:$false -ErrorAction Stop
                }-ErrorAction Stop
            } 
            elseif($PSCmdlet.ParameterSetName -eq "ByPassword"){
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    Unlock-BitLocker -MountPoint $Using:DriveLetter -Password $Using:Password -Confirm:$false -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "ByRecoveryPassword"){
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    Unlock-BitLocker -MountPoint $Using:DriveLetter -RecoveryPassword $Using:RecoveryPassword -Confirm:$false -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "ByRecoveryKeyPath"){
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    Unlock-BitLocker -MountPoint $Using:DriveLetter -RecoveryKeyPath $Using:RecoveryKeyPath -Confirm:$false -ErrorAction Stop
                } -ErrorAction Stop
            }
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