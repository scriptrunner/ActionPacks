#Requires -Version 4.0

<#
.SYNOPSIS
    Retrieves the BitLocker key protectors on the computer

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/_QUERY_

.Parameter ComputerName
    Specifies remote computer, the default is the local computer

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
    
.Parameter DriveLetter
    Specifies the drive letter, if the parameter empty all volumes retrieved
#>

[CmdLetBinding()]
Param(
    [string]$ComputerName,    
    [PSCredential]$AccessAccount,
    [string]$DriveLetter
)

try{
    if([System.String]::IsNullOrWhiteSpace($DriveLetter)){
        $DriveLetter = ""
    }
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $Script:result = Get-BitLockerVolume -MountPoint $DriveLetter -ErrorAction Stop | Select-Object MountPoint,KeyProtector
    }   
    else {
        if($null -eq $AccessAccount){
            $Script:result = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                Get-BitLockerVolume -MountPoint $DriveLetter -ErrorAction Stop | Select-Object MountPoint,KeyProtector | Sort-Object MountPoint
            } -ErrorAction Stop
        }
        else {
            $Script:result = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                Get-BitLockerVolume -MountPoint $DriveLetter -ErrorAction Stop | Select-Object MountPoint,KeyProtector | Sort-Object MountPoint
            } -ErrorAction Stop 
        }
    }
    
    foreach($drive in $Script:result)
    {
        foreach($item in $drive.KeyProtector)
        {
            if($SRXEnv) {
                $null = $SRXEnv.ResultList.Add($item.KeyProtectorId)
                $null = $SRXEnv.ResultList2.Add("$($drive.MountPoint) - $($item.KeyProtectorType)") # Display
            }
            else{
                Write-Output "$($drive.MountPoint) - $($item.KeyProtectorType)"
            }
        }
    }
}
catch{
    throw
}
finally{
}