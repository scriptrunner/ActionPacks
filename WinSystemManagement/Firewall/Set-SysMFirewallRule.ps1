#Requires -Version 4.0

<#
.SYNOPSIS
    Modifies existing firewall rule.
    Only parameters with value are set

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
    Specifies that only matching firewall rule of the indicated name or display name are retrieved

.Parameter Direction
    Specifies that matching firewall rule of the indicated direction are created

.Parameter Description
    Specifies that matching firewall rule of the indicated description are created

.Parameter ComputerName
    Specifies the name of the computer from which to retrieve the firewall rule
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter Action
    Specifies that matching firewall rule of the indicated action are created

.Parameter Authentication
    Specifies that authentication is required on firewall rule

.Parameter NewDisplayName 
    Specifies the new display name for a firewall rule

.Parameter LocalPort
    Specifies that network packets with matching IP local port numbers match this rule

.Parameter Program
    Specifies the path and file name of the program for which the rule allows traffic

.Parameter Protocol
    Specifies that network packets with matching IP addresses match this rule

.Parameter RemoteAddress
    Specifies that network packet with matching IP address match this rule
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$RuleName ,
    [ValidateSet("Inbound", "Outbound")]
    [string]$Direction ,
    [ValidateSet("Allow", "Block")]
    [string]$Action,
    [string]$Description ,
    [ValidateSet("NotRequired", "Required", "NoEncap")]
    [string]$Authentication,
    [string]$NewDisplayName,
    [string]$LocalPort,
    [ValidateSet("TCP", "UDP", "ICMPv4","ICMPv6")]
    [string]$Protocol ,
    [string]$Program ,
    [string]$RemoteAddress ,
    [string]$ComputerName,
    [PSCredential]$AccessAccount
)

$Script:Cim = $null
[string[]]$Script:Properties = @('Name','Description','DisplayName','Enabled','Direction','Action','PrimaryStatus','Status')
try{
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName = [System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim = New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }
    $Script:Rule = Get-NetFirewallRule -CimSession $Script:Cim -ErrorAction Stop | Where-Object {$_.Name -like "*$($RuleName)*" -or $_.DisplayName -like "*$($RuleName)*"}   
    
    if($null -eq $Script:Rule){
        if($SRXEnv) {
            $SRXEnv.ResultMessage = "Rule $($RuleName) not found" 
        }
        throw "Rule $($RuleName) not found"
    }
    else {
        if($PSBoundParameters.ContainsKey('Direction') -eq $true){
            $null = Set-NetFirewallRule -CimSession $Script:Cim -InputObject $Script:Rule -Direction $Direction -ErrorAction Stop
        }
        if($PSBoundParameters.ContainsKey('Action') -eq $true){
            $null = Set-NetFirewallRule -CimSession $Script:Cim -InputObject $Script:Rule -Action $Action -ErrorAction Stop
        }
        if($PSBoundParameters.ContainsKey('Description') -eq $true){
            $null = Set-NetFirewallRule -CimSession $Script:Cim -InputObject $Script:Rule -Description $Description -ErrorAction Stop
        }
        if($PSBoundParameters.ContainsKey('Authentication') -eq $true){
            $null = Set-NetFirewallRule -CimSession $Script:Cim -InputObject $Script:Rule -Authentication $Authentication -ErrorAction Stop
            $Script:Properties += "Authentication"
        }
        if($PSBoundParameters.ContainsKey('Protocol') -eq $true){
            $null = Set-NetFirewallRule -CimSession $Script:Cim -InputObject $Script:Rule -Protocol $Protocol -ErrorAction Stop
            $Script:Properties += "Protocol"
        }
        if($PSBoundParameters.ContainsKey('LocalPort') -eq $true){
            $null = Set-NetFirewallRule -CimSession $Script:Cim -InputObject $Script:Rule -LocalPort @($LocalPort) -ErrorAction Stop
            $Script:Properties += "LocalPort"
        }
        if($PSBoundParameters.ContainsKey('RemoteAddress') -eq $true){
            $null = Set-NetFirewallRule -CimSession $Script:Cim -InputObject $Script:Rule -RemoteAddress $RemoteAddress -ErrorAction Stop
            $Script:Properties += "RemoteAddress"
        }
        if($PSBoundParameters.ContainsKey('Program') -eq $true){
            $null = Set-NetFirewallRule -CimSession $Script:Cim -InputObject $Script:Rule -Program $Program -ErrorAction Stop
            $Script:Properties += "Program"
        }
        if($PSBoundParameters.ContainsKey('NewDisplayName') -eq $true){
            $null = Set-NetFirewallRule -CimSession $Script:Cim -InputObject $Script:Rule -NewDisplayName $NewDisplayName -ErrorAction Stop
        }
        
        $Script:Rule = Get-NetFirewallRule -CimSession $Script:Cim -Name $Script:Rule.Name -ErrorAction Stop `
                        | Select-Object $Script:Properties
        if($SRXEnv) {
            $SRXEnv.ResultMessage = $Script:Rule 
        }
        else{
            Write-Output $Script:Rule
        }
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