#Requires -Version 4.0

<#
.SYNOPSIS
    Set Windows Auto Logon 
    The system will require a reboot for changes to take effect.

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

.Parameter EnableAutoLogon
    Enable or disable Windows Auto Logon 

.Parameter DefaultUserName
    Specifies the username that the system would use to login
    
.Parameter DefaultDomainName
    Specifies the domain name that the system would use to login

.Parameter RebootAfterChanges
    Reboots the remote computer after change the settings

.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [bool]$EnableAutoLogon,
    [string]$DefaultUserName,
    [string]$DefaultDomainName,
    [switch]$RebootAfterChanges,
    [string]$ComputerName,    
    [PSCredential]$AccessAccount
)

try{
    [string]$Script:regKey = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
    [int]$Script:LogonOn = 0
    if($EnableAutoLogon -eq $true){
        $Script:LogonOn = 1
    }
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){       
        $null = Set-ItemProperty -Path $Script:regKey -Name AutoAdminLogon -Value $Script:LogonOn -Force -ErrorAction Stop
        $null = Set-ItemProperty -Path $Script:regKey -Name DefaultUserName -Value $DefaultUserName -Force -ErrorAction Stop
        $null = Set-ItemProperty -Path $Script:regKey -Name DefaultDomainName -Value $DefaultDomainName -Force -ErrorAction Stop
    }
    else {
        if($null -eq $AccessAccount){
            $null = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                Set-ItemProperty -Path $Using:regKey -Name AutoAdminLogon -Value $Using:LogonOn -Force -ErrorAction Stop
                Set-ItemProperty -Path $Using:regKey -Name DefaultUserName -Value $Using:DefaultUserName -Force -ErrorAction Stop
                Set-ItemProperty -Path $Using:regKey -Name DefaultDomainName -Value $Using:DefaultDomainName -Force -ErrorAction Stop
            } -ErrorAction Stop
            if($RebootAfterChanges -eq $true){
                $null = Restart-Computer -ComputerName $ComputerName -DcomAuthentication "Packet" -Force -Confirm:$false -ErrorAction Stop
            }
        }
        else {
            $null = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                Set-ItemProperty -Path $Using:regKey -Name AutoAdminLogon -Value $Using:LogonOn -Force -ErrorAction Stop
                Set-ItemProperty -Path $Using:regKey -Name DefaultUserName -Value $Using:DefaultUserName -Force -ErrorAction Stop
                Set-ItemProperty -Path $Using:regKey -Name DefaultDomainName -Value $Using:DefaultDomainName -Force -ErrorAction Stop
            } -ErrorAction Stop
            if($RebootAfterChanges -eq $true){
                $null = Restart-Computer -Credential $AccessAccount -ComputerName $ComputerName -DcomAuthentication "Packet" -Force -Confirm:$false -ErrorAction Stop
            }
        }
    }      
    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Auto logon enabled is $($EnableAutoLogon.ToString())"
    }
    else{
        Write-Output "Auto logon enabled is $($EnableAutoLogon.ToString())"
    }
}
catch{
    throw
}
finally{
}