#Requires -Version 4.0

<#
.SYNOPSIS
    Adds a key protector for a BitLocker volume

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/BitLocker

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
            Add-BitLockerKeyProtector -MountPoint $DriveLetter -Confirm:$false `
                -AdAccountOrGroup $AdAccountOrGroup -AdAccountOrGroupProtector -Service:$Service -ErrorAction Stop
        }
        elseif($PSCmdlet.ParameterSetName -eq "TpmProtector"){
            Add-BitLockerKeyProtector -MountPoint $DriveLetter -Confirm:$false -TpmProtector -ErrorAction Stop
        }
        elseif($PSCmdlet.ParameterSetName -eq "TpmAndPinProtector"){
            [securestring]$tmpPin = ConvertTo-SecureString -String $Pin -AsPlainText -Force
            Add-BitLockerKeyProtector -MountPoint $DriveLetter -Confirm:$false `
                -TpmAndPinProtector -Pin $tmpPin -ErrorAction Stop
        }
        elseif($PSCmdlet.ParameterSetName -eq "TpmAndStartupKeyProtector"){
            Add-BitLockerKeyProtector -MountPoint $DriveLetter -Confirm:$false `
                -TpmAndStartupKeyProtector -StartupKeyPath $StartupKeyPath -ErrorAction Stop
        }
        elseif($PSCmdlet.ParameterSetName -eq "TpmAndPinAndStartupKeyProtector"){
            [securestring]$tmpPin = ConvertTo-SecureString -String $Pin -AsPlainText -Force
            Add-BitLockerKeyProtector -MountPoint $DriveLetter -Confirm:$false `
                -TpmAndPinAndStartupKeyProtector -Pin $tmpPin -StartupKeyPath $StartupKeyPath -ErrorAction Stop
        }
        elseif($PSCmdlet.ParameterSetName -eq "StartupKeyProtector"){
            Add-BitLockerKeyProtector -MountPoint $DriveLetter -Confirm:$false `
                -StartupKeyProtector -StartupKeyPath $StartupKeyPath -ErrorAction Stop
        }
        elseif($PSCmdlet.ParameterSetName -eq "PasswordProtector"){
            [securestring]$tmpPwd = ConvertTo-SecureString -String $Password -AsPlainText -Force
            Add-BitLockerKeyProtector -MountPoint $DriveLetter -Confirm:$false `
                -PasswordProtector -Password $tmpPwd -ErrorAction Stop
        }
        elseif($PSCmdlet.ParameterSetName -eq "RecoveryPasswordProtector"){
            Add-BitLockerKeyProtector -MountPoint $DriveLetter -Confirm:$false `
                -RecoveryPasswordProtector -RecoveryPassword $RecoveryPassword -ErrorAction Stop
        }
        elseif($PSCmdlet.ParameterSetName -eq "RecoveryKeyProtector"){
            Add-BitLockerKeyProtector -MountPoint $DriveLetter -Confirm:$false `
                -RecoveryKeyProtector -RecoveryKeyPath $RecoveryKeyPath -ErrorAction Stop
        }
        $Script:output = Get-BitLockerVolume -MountPoint $DriveLetter | Select-Object $Properties
    }
    else {
        if($null -eq $AccessAccount){
            if($PSCmdlet.ParameterSetName -eq "AdAccountOrGroupProtector"){
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Add-BitLockerKeyProtector -MountPoint $Using:DriveLetter -Confirm:$false `
                         -AdAccountOrGroup $Using:AdAccountOrGroup -AdAccountOrGroupProtector -Service:$Using:Service -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "TpmProtector"){
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Add-BitLockerKeyProtector -MountPoint $Using:DriveLetter -Confirm:$false `
                         -TpmProtector -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "TpmAndPinProtector"){
                [securestring]$tmpPin = ConvertTo-SecureString -String $Pin -AsPlainText -Force
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Add-BitLockerKeyProtector -MountPoint $Using:DriveLetter -Confirm:$false `
                         -TpmAndPinProtector -Pin $Using:tmpPin -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "TpmAndStartupKeyProtector"){
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Add-BitLockerKeyProtector -MountPoint $Using:DriveLetter -Confirm:$false `
                        -TpmAndStartupKeyProtector -StartupKeyPath $Using:StartupKeyPath -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "TpmAndPinAndStartupKeyProtector"){
                [securestring]$tmpPin = ConvertTo-SecureString -String $Pin -AsPlainText -Force
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Add-BitLockerKeyProtector -MountPoint $Using:DriveLetter -Confirm:$false `
                        -TpmAndPinAndStartupKeyProtector -Pin $Using:tmpPin -StartupKeyPath $Using:StartupKeyPath -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "StartupKeyProtector"){
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Add-BitLockerKeyProtector -MountPoint $Using:DriveLetter -Confirm:$false `
                        -StartupKeyProtector -StartupKeyPath $Using:StartupKeyPath -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "PasswordProtector"){
                [securestring]$tmpPwd = ConvertTo-SecureString -String $Password -AsPlainText -Force
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Add-BitLockerKeyProtector -MountPoint $Using:DriveLetter -Confirm:$false `
                        -PasswordProtector -Password $Using:tmpPwd -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "RecoveryPasswordProtector"){
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Add-BitLockerKeyProtector -MountPoint $Using:DriveLetter -Confirm:$false `
                         -RecoveryPasswordProtector -RecoveryPassword $Using:RecoveryPassword -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "RecoveryKeyProtector"){
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Add-BitLockerKeyProtector -MountPoint $Using:DriveLetter -Confirm:$false `
                        -RecoveryKeyProtector -RecoveryKeyPath $Using:RecoveryKeyPath -ErrorAction Stop
                } -ErrorAction Stop
            }
            $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                Get-BitLockerVolume -MountPoint $Using:DriveLetter | Select-Object $Using:Properties
            }
        }
        else {
            if($PSCmdlet.ParameterSetName -eq "AdAccountOrGroupProtector"){
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    Add-BitLockerKeyProtector -MountPoint $Using:DriveLetter -Confirm:$false `
                        -AdAccountOrGroup $Using:AdAccountOrGroup -AdAccountOrGroupProtector -Service:$Using:Service -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "TpmProtector"){
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{                    
                    Add-BitLockerKeyProtector -MountPoint $Using:DriveLetter -Confirm:$false `
                        -TpmProtector -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "TpmAndPinProtector"){
                [securestring]$tmpPin = ConvertTo-SecureString -String $Pin -AsPlainText -Force
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{                    
                    Add-BitLockerKeyProtector -MountPoint $Using:DriveLetter -Confirm:$false `
                        -TpmAndPinProtector -Pin $Using:tmpPin -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "TpmAndStartupKeyProtector"){
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{                    
                    Add-BitLockerKeyProtector -MountPoint $Using:DriveLetter -Confirm:$false `
                        -TpmAndStartupKeyProtector -StartupKeyPath $Using:StartupKeyPath -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "TpmAndPinAndStartupKeyProtector"){
                [securestring]$tmpPin = ConvertTo-SecureString -String $Pin -AsPlainText -Force
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{                    
                    Add-BitLockerKeyProtector -MountPoint $Using:DriveLetter -Confirm:$false `
                        -TpmAndPinAndStartupKeyProtector -Pin $Using:tmpPin -StartupKeyPath $Using:StartupKeyPath -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "StartupKeyProtector"){
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{                    
                    Add-BitLockerKeyProtector -MountPoint $Using:DriveLetter -Confirm:$false `
                        -StartupKeyProtector -StartupKeyPath $Using:StartupKeyPath -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "PasswordProtector"){
                [securestring]$tmpPwd = ConvertTo-SecureString -String $Password -AsPlainText -Force
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{                    
                    Add-BitLockerKeyProtector -MountPoint $Using:DriveLetter -Confirm:$false `
                        -PasswordProtector -Password $Using:tmpPwd -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "RecoveryPasswordProtector"){
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{                    
                    Add-BitLockerKeyProtector -MountPoint $Using:DriveLetter -Confirm:$false `
                        -RecoveryPasswordProtector -RecoveryPassword $Using:RecoveryPassword -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "RecoveryKeyProtector"){
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{                    
                    Add-BitLockerKeyProtector -MountPoint $Using:DriveLetter -Confirm:$false `
                        -RecoveryKeyProtector -RecoveryKeyPath $Using:RecoveryKeyPath -ErrorAction Stop
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