#Requires -Version 4.0

<#
.SYNOPSIS
     Enable or disable (RDP) Remote Desktop

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/RemoteDesktop

.Parameter Enable
    Enable or disable RDP

.Parameter SetFirewallRule
    Enables or disables the Firewall Rule for Remote Desktop, too

.Parameter FirewallRuleGroupName
    Specifies the name of the firewall group, e.g. englisch Remote Desktop, german Remotedesktop
 
.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [ValidateSet("True", "False")]
    [string]$Enable = "True",
    [switch]$SetFirewallRule,
    [string]$FirewallRuleGroupName = "Remote Desktop",
    [string]$ComputerName,    
    [PSCredential]$AccessAccount
)

try{
    $Script:newStatus = 0
    [string]$regKey = "HKLM:\System\CurrentControlSet\Control\Terminal Server"

    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName = [System.Net.DNS]::GetHostByName('').HostName
    } 
    if($null -eq $AccessAccount){
        $Script:Cim = New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }
    if($Enable -eq "False"){
        $Script:newStatus = 1
    }

    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){
        $null = Set-ItemProperty -Path $regKey -Name fDenyTSConnections -Value $Script:newStatus -Force -ErrorAction Stop
    }
    else {
        if($null -eq $AccessAccount){
            $null = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                Set-ItemProperty -Path $Using:regKey -Name fDenyTSConnections -Value $Using:newStatus -Force -ErrorAction Stop
            } -ErrorAction Stop
        }
        else {
            $null = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                Set-ItemProperty -Path $Using:regKey -Name fDenyTSConnections -Value $Using:newStatus -Force -ErrorAction Stop
            } -ErrorAction Stop
        }
    }      
    if($SetFirewallRule -eq $true){
        if($Script:newStatus -eq 0){
            $null = Enable-NetFirewallRule -CimSession $Script:Cim -DisplayGroup $FirewallRuleGroupName -ErrorAction Stop
        }
        else {
            $null = Disable-NetFirewallRule -CimSession $Script:Cim -DisplayGroup $FirewallRuleGroupName -ErrorAction Stop
        }
    }

    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Remote Desktop status changed"
    }
    else{
        Write-Output "Remote Desktop status changed"
    }
}
catch{
    throw
}
finally{
    if($null -ne $Script:Cim){
        Remove-CimSession $Script:Cim 
    }
}