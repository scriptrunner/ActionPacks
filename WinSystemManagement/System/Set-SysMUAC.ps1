#Requires -Version 4.0

<#
.SYNOPSIS
    Configure User Account Control. 
    The system will require a reboot for changes to the UAC settings to take effect.

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

.Parameter UACSetting
    Specifies the option to configure UAC  
    1 -> Notify always
    2 -> Default 
    3 -> Notify when applications try to make change
    4 -> Never notify
    
.Parameter RebootAfterChanges
    Reboots the remote computer after change the setting

.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [ValidateSet(1,2,3,4)]
    [int]$UACSetting = 2,
    [switch]$RebootAfterChanges,
    [string]$ComputerName,    
    [PSCredential]$AccessAccount
)

try{
    [string]$UACKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
    [int]$Script:LUA
    [int]$Script:Prompt
    [int]$Script:Sec

    switch ($UACSetting){
        1{
            $Script:LUA = 1
            $Script:Sec = 1
            $Script:Prompt = 2
        }
        2{
            $Script:LUA = 1
            $Script:Sec = 1
            $Script:Prompt = 5
        }
        3{
            $Script:LUA = 1
            $Script:Sec = 0
            $Script:Prompt = 5
        }
        4{
            $Script:LUA = 0
            $Script:Sec = 0
            $Script:Prompt = 0
        }
    }

    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){       
        $null = Set-ItemProperty -Path $UACKey -Name ConsentPromptBehaviorAdmin -Value $Script:Prompt -Force -ErrorAction Stop
        $null = Set-ItemProperty -Path $UACKey -Name ConsentPromptBehaviorUser -Value $Script:Prompt -Force -ErrorAction Stop
        $null = Set-ItemProperty -Path $UACKey -Name PromptOnSecureDesktop -Value $Script:Sec -Force -ErrorAction Stop
        $null = Set-ItemProperty -Path $UACKey -Name EnableLUA -Value $Script:LUA -Force -ErrorAction Stop
    }
    else {
        if($null -eq $AccessAccount){
            $null = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                Set-ItemProperty -Path $Using:UACKey -Name ConsentPromptBehaviorAdmin -Value $Using:Prompt -Force -ErrorAction Stop
                Set-ItemProperty -Path $Using:UACKey -Name ConsentPromptBehaviorUser -Value $Using:Prompt -Force -ErrorAction Stop
                Set-ItemProperty -Path $Using:UACKey -Name PromptOnSecureDesktop -Value $Using:Sec -Force -ErrorAction Stop
                Set-ItemProperty -Path $Using:UACKey -Name EnableLUA -Value $Using:LUA -Force -ErrorAction Stop
            } -ErrorAction Stop
            if($RebootAfterChanges -eq $true){
                Restart-Computer -ComputerName $ComputerName -DcomAuthentication "Packet" -Force -Confirm:$false -ErrorAction Stop
            }
        }
        else {
            $null = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                Set-ItemProperty -Path $Using:UACKey -Name ConsentPromptBehaviorAdmin -Value $Using:Prompt -Force -ErrorAction Stop
                Set-ItemProperty -Path $Using:UACKey -Name ConsentPromptBehaviorUser -Value $Using:Prompt -Force -ErrorAction Stop
                Set-ItemProperty -Path $Using:UACKey -Name PromptOnSecureDesktop -Value $Using:Sec -Force -ErrorAction Stop
                Set-ItemProperty -Path $Using:UACKey -Name EnableLUA -Value $Using:LUA -Force -ErrorAction Stop
            } -ErrorAction Stop
            if($RebootAfterChanges -eq $true){
                $null = Restart-Computer -Credential $AccessAccount -ComputerName $ComputerName -DcomAuthentication "Packet" -Force -Confirm:$false -ErrorAction Stop
            }
        }
    }      
    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "User Account Control successfully changed"
    }
    else{
        Write-Output "User Account Control successfully changed"
    }
}
catch{
    throw
}
finally{
}