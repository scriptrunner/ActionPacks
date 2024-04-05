#Requires -Version 5.0

<#
.SYNOPSIS
    Creates a new inbound or outbound firewall rule and adds the rule to the target computer

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

.Parameter DisplayName
    [sr-en] Only matching firewall rule of the indicated display name are created

.Parameter Direction
    [sr-en] Matching firewall rule of the indicated direction are created

.Parameter Description
    [sr-en] Matching firewall rule of the indicated description are created

.Parameter ComputerName
    [sr-en] Name of the computer from which to retrieve the firewall rule
    
.Parameter AccessAccount
    [sr-en] User account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter Action
    [sr-en] Matching firewall rule of the indicated action are created

.Parameter Authentication
    [sr-en] Authentication is required on firewall rule

.Parameter Enabled 
    [sr-en] Matching firewall rule of the indicated state are retrieved

.Parameter LocalPort
    [sr-en] Network packets with matching IP local port numbers match this rule

.Parameter Name
    [sr-en] Only matching firewall rule of the indicated name are created

.Parameter Program
    [sr-en] Path and file name of the program for which the rule allows traffic

.Parameter Protocol
    [sr-en] Network packets with matching IP addresses match this rule

.Parameter RemoteAddress
    [sr-en] Network packet with matching IP address match this rule
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$DisplayName ,
    [Parameter(Mandatory = $true)]
    [ValidateSet("Inbound", "Outbound")]
    [string]$Direction ,
    [Parameter(Mandatory = $true)]
    [ValidateSet("Allow", "Block")]
    [string]$Action = "Allow",
    [string]$Description ,
    [ValidateSet("NotRequired", "Required", "NoEncap")]
    [string]$Authentication ,
    [ValidateSet("True", "False")]
    [string]$Enabled = "True",
    [string]$Name,
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
    if([System.String]::IsNullOrWhiteSpace($Name)){
        $Script:Rule = New-NetFirewallRule -CimSession $Script:Cim -DisplayName $DisplayName -Direction $Direction -Action $Action `
                                           -Enabled $Enabled -ErrorAction Stop
    }
    else {
        $Script:Rule = New-NetFirewallRule -CimSession $Script:Cim -DisplayName $DisplayName -Direction $Direction -Action $Action `
                                           -Enabled $Enabled -Name $Name -ErrorAction Stop
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

    $Script:Rule = Get-NetFirewallRule -CimSession $Script:Cim -DisplayName $DisplayName -ErrorAction Stop `
                    | Select-Object $Script:Properties    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:Rule 
    }
    else{
        Write-Output $Script:Rule
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