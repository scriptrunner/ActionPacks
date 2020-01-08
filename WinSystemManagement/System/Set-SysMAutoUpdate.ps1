#Requires -Version 5.1

<#
.SYNOPSIS
    Enable or Disable Automatic Updates for Windows Update

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/System

.Parameter UpdateOption
    Specifies the option to Enable or Disable Automatic Updates  
    0 -> Change setting in Windows Update app (default) 
    1 -> Never check for updates (not recommended) 
    2 -> Notify for download and notify for install 
    3 -> Auto download and notify for install 
    4 -> Auto download and schedule the install
    
.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [ValidateSet(0,1,2,3,4)]
    [int]$UpdateOption = 0,
    [string]$ComputerName,    
    [PSCredential]$AccessAccount
)

try{
    [string]$WindowsUpdateKey = "HKLM:SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\"
    [string]$AutoUpdateKey = "HKLM:SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"

    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){
        if((Test-Path -Path $WindowsUpdateKey) -eq $true){
            $null = Remove-Item -Path $WindowsUpdateKey -Recurse -Force -ErrorAction Stop
        }
        If ($UpdateOption -gt 0) {
            $null = New-Item -Path $WindowsUpdateKey -Force -ErrorAction Stop
            $null = New-Item -Path $AutoUpdateKey -Force -ErrorAction Stop
        }        
        If ($UpdateOption -eq 1) {
            $null = Set-ItemProperty -Path $AutoUpdateKey -Name NoAutoUpdate -Value 1 -Force -ErrorAction Stop
        }
        elseif ($UpdateOption -gt 2) {
            $null = Set-ItemProperty -Path $AutoUpdateKey -Name NoAutoUpdate -Value 0 -Force -ErrorAction Stop
            $null = Set-ItemProperty -Path $AutoUpdateKey -Name AUOptions -Value $UpdateOption -Force -ErrorAction Stop
            $null = Set-ItemProperty -Path $AutoUpdateKey -Name ScheduledInstallDay -Value 0 -Force -ErrorAction Stop
            $null = Set-ItemProperty -Path $AutoUpdateKey -Name ScheduledInstallTime -Value 3 -Force -ErrorAction Stop
        }
    }
    else {
        if($null -eq $AccessAccount){
            $tmp = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                Test-Path -Path $Using:WindowsUpdateKey
            } -ErrorAction Stop
            if($tmp -eq $true){
                $null = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Remove-Item -Path $Using:WindowsUpdateKey -Recurse -Force -ErrorAction Stop
                } -ErrorAction Stop
            }
            If ($UpdateOption -gt 0) {
                $null = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    $null = New-Item -Path $Using:WindowsUpdateKey -Force -ErrorAction Stop;
                    $null = New-Item -Path $Using:AutoUpdateKey -Force -ErrorAction Stop
                } -ErrorAction Stop
            }        
            If ($UpdateOption -eq 1) {
                $null = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Set-ItemProperty -Path $Using:AutoUpdateKey -Name NoAutoUpdate -Value 1 -Force -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif ($UpdateOption -gt 2) {
                $null = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Set-ItemProperty -Path $Using:AutoUpdateKey -Name NoAutoUpdate -Value 0 -Force -ErrorAction Stop;
                    Set-ItemProperty -Path $Using:AutoUpdateKey -Name AUOptions -Value $Using:UpdateOption -Force -ErrorAction Stop;
                    Set-ItemProperty -Path $Using:AutoUpdateKey -Name ScheduledInstallDay -Value 0 -Force -ErrorAction Stop;
                    Set-ItemProperty -Path $Using:AutoUpdateKey -Name ScheduledInstallTime -Value 3 -Force -ErrorAction Stop;
                } -ErrorAction Stop
            }  
        }
        else {
            $tmp = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                Test-Path -Path $Using:WindowsUpdateKey
            } -ErrorAction Stop
            if($tmp -eq $true){
                $null = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    Remove-Item -Path $Using:WindowsUpdateKey -Recurse -Force -ErrorAction Stop
                } -ErrorAction Stop
            }
            If ($UpdateOption -gt 0) {
                $null = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    $null = New-Item -Path $Using:WindowsUpdateKey -Force -ErrorAction Stop;
                    $null = New-Item -Path $Using:AutoUpdateKey -Force -ErrorAction Stop
                } -ErrorAction Stop
            }        
            If ($UpdateOption -eq 1) {
                $null = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    Set-ItemProperty -Path $Using:AutoUpdateKey -Name NoAutoUpdate -Value 1 -Force -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif ($UpdateOption -gt 2) {
                $null = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    Set-ItemProperty -Path $Using:AutoUpdateKey -Name NoAutoUpdate -Value 0 -Force -ErrorAction Stop;
                    Set-ItemProperty -Path $Using:AutoUpdateKey -Name AUOptions -Value $Using:UpdateOption -Force -ErrorAction Stop;
                    Set-ItemProperty -Path $Using:AutoUpdateKey -Name ScheduledInstallDay -Value 0 -Force -ErrorAction Stop;
                    Set-ItemProperty -Path $Using:AutoUpdateKey -Name ScheduledInstallTime -Value 3 -Force -ErrorAction Stop;
                } -ErrorAction Stop
            }  
        }
    }      
    [string]$Script:output    
    switch ($UpdateOption){
        0 {
            $Script:output = "Setting changed to: Change setting in Windows Update app (default)"
        }
        1 {
            $Script:output = "Setting changed to: Never check for updates (not recommended)"
        }
        2 {
            $Script:output = "Setting changed to: Notify for download and notify for install"
        }
        3 {
            $Script:output = "Setting changed to: Auto download and notify for install"
        }
        4 {
            $Script:output = "Setting changed to: Auto download and schedule the install"
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