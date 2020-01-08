#Requires -Version 4.0

<#
.SYNOPSIS
    Enables or disables a firewall rule

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/Firewall

.Parameter RuleName
    Specifies the name or display name of the firewall rule that will be enabled or disabled

.Parameter ComputerName
    Specifies the name of the computer from which to retrieve the firewall rule
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter Enable
    Enable or disable the firewall rule
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$RuleName,
    [ValidateSet("True", "False")]
    [string]$Enable = "True",
    [string]$ComputerName,
    [PSCredential]$AccessAccount    
)

$Script:Cim = $null
[string[]]$Script:Properties = @("Name","Description","DisplayName","Enabled","Direction","Action","PrimaryStatus","Status")
try{
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName = [System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim = New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $ComputerName -Credential $AccessAccount 
    }
    $Script:Rule = Get-NetFirewallRule -CimSession $Script:Cim -ErrorAction Stop | `
                    Where-Object {$_.Name -like "*$($RuleName)*" -or $_.DisplayName -like "*$($RuleName)*"}

    if($null -ne $Script:Rule){
        if(($Script:Rule.Enabled -eq "True") -and ($Enable -eq $false)){ # disable
            $null = Disable-NetFirewallRule -CimSession $Script:Cim -InputObject $Script:Rule -ErrorAction Stop
        }
        elseif(($Script:Rule.Enabled -eq "False") -and ($Enable -eq $true)){ # enable
            $null = Enable-NetFirewallRule -CimSession $Script:Cim -InputObject $Script:Rule -ErrorAction Stop
        }
        
        $Script:Rule = Get-NetFirewallRule -CimSession $Script:Cim -Name $Script:Rule.Name -ErrorAction Stop | Select-Object $Script:Properties
        if($SRXEnv) {
            $SRXEnv.ResultMessage = $Script:Rule
        }
        else{
            Write-Output $Script:Rule
        }
    }
    else{
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "Rule $($RuleName) not found" 
        }
        throw "Rule $($RuleName) not found"
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