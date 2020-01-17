#Requires -Version 4.0

<#
.SYNOPSIS
    Adds a key protector for a BitLocker volume

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
    [securestring]$Password,
    [Parameter(Mandatory = $true,ParameterSetName = "RecoveryPasswordProtector")]
    [securestring]$RecoveryPassword,
    [Parameter(Mandatory = $true,ParameterSetName = "TpmAndPinProtector")]
    [Parameter(Mandatory = $true,ParameterSetName = "TpmAndPinAndStartupKeyProtector")]
    [securestring]$Pin,
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
    [string[]]$Properties = @('MountPoint','EncryptionMethod','VolumeStatus','ProtectionStatus','EncryptionPercentage','VolumeType','CapacityGB')

    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                                'MountPoint' = $DriveLetter
                                'Confirm' = $false}
        if($PSCmdlet.ParameterSetName -eq "AdAccountOrGroupProtector"){
            $cmdArgs.Add('AdAccountOrGroup', $AdAccountOrGroup)
            $cmdArgs.Add('AdAccountOrGroupProtector', $null)
            $cmdArgs.Add('Service', $Service)
        }
        elseif($PSCmdlet.ParameterSetName -eq "TpmProtector"){
            $cmdArgs.Add('TpmProtector', $null)
        }
        elseif($PSCmdlet.ParameterSetName -eq "TpmAndPinProtector"){
            $cmdArgs.Add('TpmAndPinProtector', $null)
            $cmdArgs.Add('Pin', $Pin)
        }
        elseif($PSCmdlet.ParameterSetName -eq "TpmAndStartupKeyProtector"){
            $cmdArgs.Add('TpmAndStartupKeyProtector', $null)
            $cmdArgs.Add('StartupKeyPath', $StartupKeyPath)
        }
        elseif($PSCmdlet.ParameterSetName -eq "TpmAndPinAndStartupKeyProtector"){
            $cmdArgs.Add('TpmAndPinAndStartupKeyProtector', $null)
            $cmdArgs.Add('StartupKeyPath', $StartupKeyPath)
            $cmdArgs.Add('Pin', $Pin)
        }
        elseif($PSCmdlet.ParameterSetName -eq "StartupKeyProtector"){
            $cmdArgs.Add('StartupKeyProtector', $null)
            $cmdArgs.Add('StartupKeyPath', $StartupKeyPath)
        }
        elseif($PSCmdlet.ParameterSetName -eq "PasswordProtector"){
            $cmdArgs.Add('PasswordProtector', $null)
            $cmdArgs.Add('Password', $Password)
        }
        elseif($PSCmdlet.ParameterSetName -eq "RecoveryPasswordProtector"){
            $cmdArgs.Add('RecoveryPasswordProtector', $null)
            $cmdArgs.Add('RecoveryPassword', $RecoveryPassword)
        }
        elseif($PSCmdlet.ParameterSetName -eq "RecoveryKeyProtector"){
            $cmdArgs.Add('RecoveryKeyProtector', $null)
            $cmdArgs.Add('RecoveryKeyPath', $RecoveryKeyPath)
        }
        $null = Add-BitLockerKeyProtector @cmdArgs
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
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Add-BitLockerKeyProtector -MountPoint $Using:DriveLetter -Confirm:$false `
                         -TpmAndPinProtector -Pin $Using:Pin -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "TpmAndStartupKeyProtector"){
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Add-BitLockerKeyProtector -MountPoint $Using:DriveLetter -Confirm:$false `
                        -TpmAndStartupKeyProtector -StartupKeyPath $Using:StartupKeyPath -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "TpmAndPinAndStartupKeyProtector"){
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Add-BitLockerKeyProtector -MountPoint $Using:DriveLetter -Confirm:$false `
                        -TpmAndPinAndStartupKeyProtector -Pin $Using:Pin -StartupKeyPath $Using:StartupKeyPath -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "StartupKeyProtector"){
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Add-BitLockerKeyProtector -MountPoint $Using:DriveLetter -Confirm:$false `
                        -StartupKeyProtector -StartupKeyPath $Using:StartupKeyPath -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "PasswordProtector"){
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Add-BitLockerKeyProtector -MountPoint $Using:DriveLetter -Confirm:$false `
                        -PasswordProtector -Password $Using:Password -ErrorAction Stop
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
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{                    
                    Add-BitLockerKeyProtector -MountPoint $Using:DriveLetter -Confirm:$false `
                        -TpmAndPinProtector -Pin $Using:Pin -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "TpmAndStartupKeyProtector"){
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{                    
                    Add-BitLockerKeyProtector -MountPoint $Using:DriveLetter -Confirm:$false `
                        -TpmAndStartupKeyProtector -StartupKeyPath $Using:StartupKeyPath -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "TpmAndPinAndStartupKeyProtector"){
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{                    
                    Add-BitLockerKeyProtector -MountPoint $Using:DriveLetter -Confirm:$false `
                        -TpmAndPinAndStartupKeyProtector -Pin $Using:Pin -StartupKeyPath $Using:StartupKeyPath -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "StartupKeyProtector"){
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{                    
                    Add-BitLockerKeyProtector -MountPoint $Using:DriveLetter -Confirm:$false `
                        -StartupKeyProtector -StartupKeyPath $Using:StartupKeyPath -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($PSCmdlet.ParameterSetName -eq "PasswordProtector"){
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{                    
                    Add-BitLockerKeyProtector -MountPoint $Using:DriveLetter -Confirm:$false `
                        -PasswordProtector -Password $Using:Password -ErrorAction Stop
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