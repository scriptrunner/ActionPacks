#Requires -Version 4.0

<#
.SYNOPSIS
    Enables encryption for a BitLocker volume

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
    © AppSphere AG

.COMPONENT

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinClientManagement/BitLocker

.Parameter DriveLetter
    Specifies the drive letter

.Parameter AdAccountOrGroup
    Specifies an account using the format Domain\User. Adds the account you specify as a key protector for the volume encryption key

.Parameter TpmProtector
    Indicates that BitLocker uses the TPM as a protector for the volume encryption key

.Parameter TpmAndPinProtector
    Indicates that BitLocker uses a combination of the TPM and a PIN as a protector for the volume encryption key

.Parameter TpmAndStartupKeyProtector
    Indicates that BitLocker uses a combination of the TPM and a startup key as a protector for the volume encryption key

.Parameter TpmAndPinAndStartupKeyProtector
    Indicates that BitLocker uses a combination of the TPM, a PIN, and a startup key as a protector for the volume encryption key.

.Parameter StartupKeyProtector
    Indicates that BitLocker uses a startup key as a protector for the volume encryption key

.Parameter Pin
    Specifies a string object that contains a PIN. BitLocker uses the PIN specified, with other data, as a protector for the volume encryption key

.Parameter Service
    Indicates that the system account for this computer unlocks the encrypted volume
 
.Parameter StartupKeyPath
    Specifies a path to a startup key. The key stored in the specified path acts as a protector for the volume encryption key

.Parameter RecoveryKeyPath
    Specifies a path to a recovery key. The key stored in the specified path acts as a protector for the volume encryption key

.Parameter Password
    Specifies a secure string object that contains a password

.Parameter RecoveryPassword
    Specifies a recovery password

.Parameter EncryptionMethod
    List of properties to expand, comma separated e.g. VolumeStatus,EncryptionMethod. Use * for all properties

.Parameter HardwareEncryption
    Indicates that the volume uses hardware encryption

.Parameter SkipHardwareTest
    Indicates that BitLocker does not perform a hardware test before it begins encryption

.Parameter UsedSpaceOnly
    Indicates that BitLocker does not encrypt disk space which contains unused data
 
.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "AdAccountOrGroupProtector")]
    [Parameter(Mandatory = $true,ParameterSetName = "TpmProtector")]
    [Parameter(Mandatory = $true,ParameterSetName = "TpmAndPinProtector")]
    [Parameter(Mandatory = $true,ParameterSetName = "TpmAndStartupKeyProtector")]
    [Parameter(Mandatory = $true,ParameterSetName = "TpmAndPinAndStartupKeyProtector")]
    [Parameter(Mandatory = $true,ParameterSetName = "StartupKeyProtector")]
    [Parameter(Mandatory = $true,ParameterSetName = "PasswordProtector")]
    [Parameter(Mandatory = $true,ParameterSetName = "RecoveryPasswordProtector")]
    [Parameter(Mandatory = $true,ParameterSetName = "RecoveryKeyProtector")]
    [string]$DriveLetter,
    [Parameter(Mandatory = $true,ParameterSetName = "AdAccountOrGroupProtector")]
    [string]$AdAccountOrGroup,
    [Parameter(Mandatory = $true,ParameterSetName = "TpmProtector")]
    [switch]$TpmProtector,
    [Parameter(Mandatory = $true,ParameterSetName = "TpmAndPinProtector")]
    [switch]$TpmAndPinProtector,
    [Parameter(Mandatory = $true,ParameterSetName = "TpmAndStartupKeyProtector")]
    [switch]$TpmAndStartupKeyProtector,
    [Parameter(Mandatory = $true,ParameterSetName = "TpmAndPinAndStartupKeyProtector")]
    [switch]$TpmAndPinAndStartupKeyProtector,
    [Parameter(Mandatory = $true,ParameterSetName = "StartupKeyProtector")]
    [switch]$StartupKeyProtector,
    [Parameter(Mandatory = $true,ParameterSetName = "PasswordProtector")]
    [string]$Password,
    [Parameter(Mandatory = $true,ParameterSetName = "RecoveryPasswordProtector")]
    [string]$RecoveryPassword,
    [Parameter(Mandatory = $true,ParameterSetName = "TpmAndPinProtector")]
    [Parameter(Mandatory = $true,ParameterSetName = "TpmAndPinAndStartupKeyProtector")]
    [string]$Pin,
    [Parameter(Mandatory = $true,ParameterSetName = "TpmAndStartupKeyProtector")]
    [Parameter(Mandatory = $true,ParameterSetName = "TpmAndPinAndStartupKeyProtector")]
    [Parameter(Mandatory = $true,ParameterSetName = "StartupKeyProtector")]
    [string]$StartupKeyPath,
    [Parameter(Mandatory = $true,ParameterSetName = "RecoveryKeyProtector")]
    [string]$RecoveryKeyPath,
    [Parameter(ParameterSetName = "AdAccountOrGroupProtector")]
    [switch]$Service,
    [Parameter(ParameterSetName = "AdAccountOrGroupProtector")]
    [Parameter(ParameterSetName = "TpmProtector")]
    [Parameter(ParameterSetName = "TpmAndPinProtector")]
    [Parameter(ParameterSetName = "TpmAndStartupKeyProtector")]
    [Parameter(ParameterSetName = "TpmAndPinAndStartupKeyProtector")]
    [Parameter(ParameterSetName = "StartupKeyProtector")]    
    [Parameter(ParameterSetName = "PasswordProtector")]
    [Parameter(ParameterSetName = "RecoveryPasswordProtector")]
    [Parameter(ParameterSetName = "RecoveryKeyProtector")]
    [ValidateSet("Aes128","Aes256","Hardware","XtsAes128","XtsAes256")]
    [string]$EncryptionMethod = "Aes128",
    [Parameter(ParameterSetName = "AdAccountOrGroupProtector")]
    [Parameter(ParameterSetName = "TpmProtector")]
    [Parameter(ParameterSetName = "TpmAndPinProtector")]
    [Parameter(ParameterSetName = "TpmAndStartupKeyProtector")]
    [Parameter(ParameterSetName = "TpmAndPinAndStartupKeyProtector")]
    [Parameter(ParameterSetName = "StartupKeyProtector")]    
    [Parameter(ParameterSetName = "PasswordProtector")]
    [Parameter(ParameterSetName = "RecoveryPasswordProtector")]
    [Parameter(ParameterSetName = "RecoveryKeyProtector")]
    [switch]$HardwareEncryption,
    [Parameter(ParameterSetName = "AdAccountOrGroupProtector")]
    [Parameter(ParameterSetName = "TpmProtector")]
    [Parameter(ParameterSetName = "TpmAndPinProtector")]
    [Parameter(ParameterSetName = "TpmAndStartupKeyProtector")]
    [Parameter(ParameterSetName = "TpmAndPinAndStartupKeyProtector")]
    [Parameter(ParameterSetName = "StartupKeyProtector")]    
    [Parameter(ParameterSetName = "PasswordProtector")]
    [Parameter(ParameterSetName = "RecoveryPasswordProtector")]
    [Parameter(ParameterSetName = "RecoveryKeyProtector")]
    [switch]$SkipHardwareTest,
    [Parameter(ParameterSetName = "AdAccountOrGroupProtector")]
    [Parameter(ParameterSetName = "TpmProtector")]
    [Parameter(ParameterSetName = "TpmAndPinProtector")]
    [Parameter(ParameterSetName = "TpmAndStartupKeyProtector")]
    [Parameter(ParameterSetName = "TpmAndPinAndStartupKeyProtector")]
    [Parameter(ParameterSetName = "StartupKeyProtector")]    
    [Parameter(ParameterSetName = "PasswordProtector")]
    [Parameter(ParameterSetName = "RecoveryPasswordProtector")]
    [Parameter(ParameterSetName = "RecoveryKeyProtector")]
    [switch]$UsedSpaceOnly,
    [Parameter(ParameterSetName = "AdAccountOrGroupProtector")]
    [Parameter(ParameterSetName = "TpmProtector")]
    [Parameter(ParameterSetName = "TpmAndPinProtector")]
    [Parameter(ParameterSetName = "TpmAndStartupKeyProtector")]
    [Parameter(ParameterSetName = "TpmAndPinAndStartupKeyProtector")]
    [Parameter(ParameterSetName = "StartupKeyProtector")]    
    [Parameter(ParameterSetName = "PasswordProtector")]
    [Parameter(ParameterSetName = "RecoveryPasswordProtector")]
    [Parameter(ParameterSetName = "RecoveryKeyProtector")]
    [string]$ComputerName,    
    [Parameter(ParameterSetName = "AdAccountOrGroupProtector")]
    [Parameter(ParameterSetName = "TpmProtector")]
    [Parameter(ParameterSetName = "TpmAndPinProtector")]
    [Parameter(ParameterSetName = "TpmAndStartupKeyProtector")]
    [Parameter(ParameterSetName = "TpmAndPinAndStartupKeyProtector")]
    [Parameter(ParameterSetName = "StartupKeyProtector")]    
    [Parameter(ParameterSetName = "PasswordProtector")]
    [Parameter(ParameterSetName = "RecoveryPasswordProtector")]
    [Parameter(ParameterSetName = "RecoveryKeyProtector")]
    [PSCredential]$AccessAccount
)

try{
    $Script:output
    [string[]]$Properties = @("MountPoint","EncryptionMethod","VolumeStatus","ProtectionStatus","EncryptionPercentage","VolumeType","CapacityGB")
    
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){
        if($PSCmdlet.ParameterSetName -eq "AdAccountOrGroupProtector"){
            Enable-BitLocker -MountPoint $DriveLetter -EncryptionMethod $EncryptionMethod  -Confirm:$false `
                -AdAccountOrGroup $AdAccountOrGroup -AdAccountOrGroupProtector `
                -Service:$Service -HardwareEncryption:$HardwareEncryption -SkipHardwareTest$SkipHardwareTest -UsedSpaceOnly:$UsedSpaceOnly -ErrorAction Stop
        }
        elseif($PSCmdlet.ParameterSetName -eq "TpmProtector"){
            Enable-BitLocker -MountPoint $DriveLetter -EncryptionMethod $EncryptionMethod  -Confirm:$false -TpmProtector  `
                -HardwareEncryption:$HardwareEncryption -SkipHardwareTest$SkipHardwareTest -UsedSpaceOnly:$UsedSpaceOnly -ErrorAction Stop
        }
        elseif($PSCmdlet.ParameterSetName -eq "TpmAndPinProtector"){
            [securestring]$tmpPin = ConvertTo-SecureString -String $Pin -AsPlainText -Force
            Enable-BitLocker -MountPoint $DriveLetter -EncryptionMethod $EncryptionMethod -Confirm:$false `
                -TpmAndPinProtector -Pin $tmpPin  `
                -HardwareEncryption:$HardwareEncryption -SkipHardwareTest$SkipHardwareTest -UsedSpaceOnly:$UsedSpaceOnly -ErrorAction Stop
        }
        elseif($PSCmdlet.ParameterSetName -eq "TpmAndStartupKeyProtector"){
            Enable-BitLocker -MountPoint $DriveLetter -EncryptionMethod $EncryptionMethod -Confirm:$false `
                -TpmAndStartupKeyProtector -StartupKeyPath $StartupKeyPath `
                -HardwareEncryption:$HardwareEncryption -SkipHardwareTest$SkipHardwareTest -UsedSpaceOnly:$UsedSpaceOnly -ErrorAction Stop
        }
        elseif($PSCmdlet.ParameterSetName -eq "TpmAndPinAndStartupKeyProtector"){
            [securestring]$tmpPin = ConvertTo-SecureString -String $Pin -AsPlainText -Force
            Enable-BitLocker -MountPoint $DriveLetter -EncryptionMethod $EncryptionMethod -Confirm:$false `
                -TpmAndPinAndStartupKeyProtector -Pin $tmpPin -StartupKeyPath $StartupKeyPath `
                -HardwareEncryption:$HardwareEncryption -SkipHardwareTest$SkipHardwareTest -UsedSpaceOnly:$UsedSpaceOnly -ErrorAction Stop
        }
        elseif($PSCmdlet.ParameterSetName -eq "StartupKeyProtector"){
            Enable-BitLocker -MountPoint $DriveLetter -EncryptionMethod $EncryptionMethod -Confirm:$false `
                -StartupKeyProtector -StartupKeyPath $StartupKeyPath `
                -HardwareEncryption:$HardwareEncryption -SkipHardwareTest$SkipHardwareTest -UsedSpaceOnly:$UsedSpaceOnly -ErrorAction Stop
        }
        elseif($PSCmdlet.ParameterSetName -eq "PasswordProtector"){
            [securestring]$tmpPwd = ConvertTo-SecureString -String $Password -AsPlainText -Force
            Enable-BitLocker -MountPoint $DriveLetter -EncryptionMethod $EncryptionMethod -Confirm:$false `
                -PasswordProtector -Password $tmpPwd `
                -HardwareEncryption:$HardwareEncryption -SkipHardwareTest$SkipHardwareTest -UsedSpaceOnly:$UsedSpaceOnly -ErrorAction Stop
        }
        elseif($PSCmdlet.ParameterSetName -eq "RecoveryPasswordProtector"){
            Enable-BitLocker -MountPoint $DriveLetter -EncryptionMethod $EncryptionMethod -Confirm:$false `
                -RecoveryPasswordProtector -RecoveryPassword $RecoveryPassword `
                -HardwareEncryption:$HardwareEncryption -SkipHardwareTest$SkipHardwareTest -UsedSpaceOnly:$UsedSpaceOnly -ErrorAction Stop
        }
        elseif($PSCmdlet.ParameterSetName -eq "RecoveryKeyProtector"){
            Enable-BitLocker -MountPoint $DriveLetter -EncryptionMethod $EncryptionMethod -Confirm:$false `
                -RecoveryKeyProtector -RecoveryKeyPath $RecoveryKeyPath `
                -HardwareEncryption:$HardwareEncryption -SkipHardwareTest$SkipHardwareTest -UsedSpaceOnly:$UsedSpaceOnly -ErrorAction Stop
        }
        $Script:output = Get-BitLockerVolume -MountPoint $DriveLetter | Select-Object $Properties
    }
    else {
        if($null -eq $AccessAccount){
            if($PSCmdlet.ParameterSetName -eq "AdAccountOrGroupProtector"){
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Enable-BitLocker -MountPoint $Using:DriveLetter -EncryptionMethod $Using:EncryptionMethod -Confirm:$false `
                         -AdAccountOrGroup $Using:AdAccountOrGroup -AdAccountOrGroupProtector -Service:$Using:Service  `
                         -HardwareEncryption:$Using:HardwareEncryption -SkipHardwareTest:$Using:SkipHardwareTest -UsedSpaceOnly:$Using:UsedSpaceOnly  `
                         -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "TpmProtector"){
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Enable-BitLocker -MountPoint $Using:DriveLetter -EncryptionMethod $Using:EncryptionMethod -Confirm:$false `
                         -TpmProtector `
                         -HardwareEncryption:$Using:HardwareEncryption -SkipHardwareTest:$Using:SkipHardwareTest -UsedSpaceOnly:$Using:UsedSpaceOnly  `
                         -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "TpmAndPinProtector"){
                [securestring]$tmpPin = ConvertTo-SecureString -String $Pin -AsPlainText -Force
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Enable-BitLocker -MountPoint $Using:DriveLetter -EncryptionMethod $Using:EncryptionMethod -Confirm:$false `
                         -TpmAndPinProtector -Pin $Using:tmpPin `
                         -HardwareEncryption:$Using:HardwareEncryption -SkipHardwareTest:$Using:SkipHardwareTest -UsedSpaceOnly:$Using:UsedSpaceOnly  `
                         -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "TpmAndStartupKeyProtector"){
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Enable-BitLocker -MountPoint $Using:DriveLetter -EncryptionMethod $Using:EncryptionMethod -Confirm:$false `
                         -TpmAndStartupKeyProtector -StartupKeyPath $Using:StartupKeyPath `
                         -HardwareEncryption:$Using:HardwareEncryption -SkipHardwareTest:$Using:SkipHardwareTest -UsedSpaceOnly:$Using:UsedSpaceOnly  `
                         -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "TpmAndPinAndStartupKeyProtector"){
                [securestring]$tmpPin = ConvertTo-SecureString -String $Pin -AsPlainText -Force
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Enable-BitLocker -MountPoint $Using:DriveLetter -EncryptionMethod $Using:EncryptionMethod -Confirm:$false `
                         -TpmAndPinAndStartupKeyProtector -Pin $Using:tmpPin -StartupKeyPath $Using:StartupKeyPath `
                         -HardwareEncryption:$Using:HardwareEncryption -SkipHardwareTest:$Using:SkipHardwareTest -UsedSpaceOnly:$Using:UsedSpaceOnly  `
                         -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "StartupKeyProtector"){
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Enable-BitLocker -MountPoint $Using:DriveLetter -EncryptionMethod $Using:EncryptionMethod -Confirm:$false `
                         -StartupKeyProtector -StartupKeyPath $Using:StartupKeyPath `
                         -HardwareEncryption:$Using:HardwareEncryption -SkipHardwareTest:$Using:SkipHardwareTest -UsedSpaceOnly:$Using:UsedSpaceOnly  `
                         -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "PasswordProtector"){
                [securestring]$tmpPwd = ConvertTo-SecureString -String $Password -AsPlainText -Force
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Enable-BitLocker -MountPoint $Using:DriveLetter -EncryptionMethod $Using:EncryptionMethod -Confirm:$false `
                         -PasswordProtector -Password $Using:tmpPwd `
                         -HardwareEncryption:$Using:HardwareEncryption -SkipHardwareTest:$Using:SkipHardwareTest -UsedSpaceOnly:$Using:UsedSpaceOnly  `
                         -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "RecoveryPasswordProtector"){
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Enable-BitLocker -MountPoint $Using:DriveLetter -EncryptionMethod $Using:EncryptionMethod -Confirm:$false `
                         -RecoveryPasswordProtector -RecoveryPassword $Using:RecoveryPassword `
                         -HardwareEncryption:$Using:HardwareEncryption -SkipHardwareTest:$Using:SkipHardwareTest -UsedSpaceOnly:$Using:UsedSpaceOnly  `
                         -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "RecoveryKeyProtector"){
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Enable-BitLocker -MountPoint $Using:DriveLetter -EncryptionMethod $Using:EncryptionMethod -Confirm:$false `
                         -RecoveryKeyProtector -RecoveryKeyPath $Using:RecoveryKeyPath `
                         -HardwareEncryption:$Using:HardwareEncryption -SkipHardwareTest:$Using:SkipHardwareTest -UsedSpaceOnly:$Using:UsedSpaceOnly  `
                         -ErrorAction Stop
                } -ErrorAction Stop
            }
            $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                Get-BitLockerVolume -MountPoint $Using:DriveLetter | Select-Object $Using:Properties
            }
        }
        else {
            if($PSCmdlet.ParameterSetName -eq "AdAccountOrGroupProtector"){
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    Enable-BitLocker -MountPoint $Using:DriveLetter -EncryptionMethod $Using:EncryptionMethod -Confirm:$false `
                        -AdAccountOrGroup $Using:AdAccountOrGroup -AdAccountOrGroupProtector -Service:$Using:Service  `
                        -HardwareEncryption:$Using:HardwareEncryption -SkipHardwareTest:$Using:SkipHardwareTest -UsedSpaceOnly:$Using:UsedSpaceOnly  `
                        -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "TpmProtector"){
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{                    
                    Enable-BitLocker -MountPoint $Using:DriveLetter -EncryptionMethod $Using:EncryptionMethod -Confirm:$false `
                        -TpmProtector `
                        -HardwareEncryption:$Using:HardwareEncryption -SkipHardwareTest:$Using:SkipHardwareTest -UsedSpaceOnly:$Using:UsedSpaceOnly  `
                        -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "TpmAndPinProtector"){
                [securestring]$tmpPin = ConvertTo-SecureString -String $Pin -AsPlainText -Force
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{                    
                    Enable-BitLocker -MountPoint $Using:DriveLetter -EncryptionMethod $Using:EncryptionMethod -Confirm:$false `
                        -TpmAndPinProtector -Pin $Using:tmpPin `
                        -HardwareEncryption:$Using:HardwareEncryption -SkipHardwareTest:$Using:SkipHardwareTest -UsedSpaceOnly:$Using:UsedSpaceOnly  `
                        -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "TpmAndStartupKeyProtector"){
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{                    
                    Enable-BitLocker -MountPoint $Using:DriveLetter -EncryptionMethod $Using:EncryptionMethod -Confirm:$false `
                        -TpmAndStartupKeyProtector -StartupKeyPath $Using:StartupKeyPath `
                        -HardwareEncryption:$Using:HardwareEncryption -SkipHardwareTest:$Using:SkipHardwareTest -UsedSpaceOnly:$Using:UsedSpaceOnly  `
                        -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "TpmAndPinAndStartupKeyProtector"){
                [securestring]$tmpPin = ConvertTo-SecureString -String $Pin -AsPlainText -Force
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{                    
                    Enable-BitLocker -MountPoint $Using:DriveLetter -EncryptionMethod $Using:EncryptionMethod -Confirm:$false `
                        -TpmAndPinAndStartupKeyProtector -Pin $Using:tmpPin -StartupKeyPath $Using:StartupKeyPath `
                        -HardwareEncryption:$Using:HardwareEncryption -SkipHardwareTest:$Using:SkipHardwareTest -UsedSpaceOnly:$Using:UsedSpaceOnly  `
                        -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "StartupKeyProtector"){
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{                    
                    Enable-BitLocker -MountPoint $Using:DriveLetter -EncryptionMethod $Using:EncryptionMethod -Confirm:$false `
                        -StartupKeyProtector -StartupKeyPath $Using:StartupKeyPath `
                        -HardwareEncryption:$Using:HardwareEncryption -SkipHardwareTest:$Using:SkipHardwareTest -UsedSpaceOnly:$Using:UsedSpaceOnly  `
                        -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "PasswordProtector"){
                [securestring]$tmpPwd = ConvertTo-SecureString -String $Password -AsPlainText -Force
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{                    
                    Enable-BitLocker -MountPoint $Using:DriveLetter -EncryptionMethod $Using:EncryptionMethod -Confirm:$false `
                        -PasswordProtector -Password $Using:tmpPwd `
                        -HardwareEncryption:$Using:HardwareEncryption -SkipHardwareTest:$Using:SkipHardwareTest -UsedSpaceOnly:$Using:UsedSpaceOnly  `
                        -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "RecoveryPasswordProtector"){
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{                    
                    Enable-BitLocker -MountPoint $Using:DriveLetter -EncryptionMethod $Using:EncryptionMethod -Confirm:$false `
                        -RecoveryPasswordProtector -RecoveryPassword $Using:RecoveryPassword `
                        -HardwareEncryption:$Using:HardwareEncryption -SkipHardwareTest:$Using:SkipHardwareTest -UsedSpaceOnly:$Using:UsedSpaceOnly  `
                        -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "RecoveryKeyProtector"){
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{                    
                    Enable-BitLocker -MountPoint $Using:DriveLetter -EncryptionMethod $Using:EncryptionMethod -Confirm:$false `
                        -RecoveryKeyProtector -RecoveryKeyPath $Using:RecoveryKeyPath `
                        -HardwareEncryption:$Using:HardwareEncryption -SkipHardwareTest:$Using:SkipHardwareTest -UsedSpaceOnly:$Using:UsedSpaceOnly  `
                        -ErrorAction Stop
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