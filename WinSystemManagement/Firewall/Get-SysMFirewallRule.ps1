#Requires -Version 4.0

<#
.SYNOPSIS
    Retrieves firewall rules from the target computer

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinClientManagement/Firewall

.Parameter RuleName
    Specifies that only matching firewall rules of the indicated name or display name are retrieved. Use * for all rules

.Parameter ComputerName
    Specifies the name of the computer from which to retrieve the firewall rules
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter Properties
    List of properties to expand, comma separated e.g. Name,Description. Use * for all properties

.Parameter Enabled 
    Specifies that matching firewall rules of the indicated state are retrieved

.EXAMPLE

#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true,ParameterSetName = "by Name")]
    [string]$RuleName = "*",
    [Parameter(Mandatory = $true,ParameterSetName = "by Status")]
    [ValidateSet("All", "True", "False")]
    [string]$Enabled = "All",
    [Parameter(Mandatory = $true,ParameterSetName = "by Name")]
    [Parameter(Mandatory = $true,ParameterSetName = "by Status")]
    [string]$ComputerName,
    [Parameter(Mandatory = $true,ParameterSetName = "by Name")]
    [Parameter(Mandatory = $true,ParameterSetName = "by Status")]
    [PSCredential]$AccessAccount,
    [Parameter(Mandatory = $true,ParameterSetName = "by Name")]
    [Parameter(Mandatory = $true,ParameterSetName = "by Status")]
    [string]$Properties="Name,Description,DisplayName,Enabled,Profile,Direction,Action,PrimaryStatus,Status"
)

$Script:Cim=$null
try{
    if([System.String]::IsNullOrWhiteSpace($RuleName)){
        $RuleName= "*"
    }
    if([System.String]::IsNullOrWhiteSpace($Properties)){
        $Properties = '*'
    }
    else{
        if($null -eq ($Properties.Split(',') | Where-Object {$_ -like 'DisplayName'})){
            $Properties += ",DisplayName"
        }
    }
    [string[]]$Script:props=$Properties.Replace(' ','').Split(',')
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName=[System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim =New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim =New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }
    if(($PSCmdlet.ParameterSetName  -eq "by Name") -or ($Enabled -eq "All")) {
        $Script:Rules =Get-NetFirewallRule -CimSession $Script:Cim | Where-Object {$_.Name -like "*$($RuleName)*" -or $_.DisplayName -like "*$($RuleName)*"} `
                    | Select-Object $Script:props | Sort-Object DisplayName | Format-List    
    }
    else {
        $Script:Rules =Get-NetFirewallRule -CimSession $Script:Cim -Enabled $Enabled  `
                    | Select-Object $Script:props | Sort-Object DisplayName | Format-List
    }
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:Rules 
    }
    else{
        Write-Output $Script:Rules
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