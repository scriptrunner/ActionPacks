#Requires -Version 4.0

<#
.SYNOPSIS
    Retrieves firewall rules from the target computer

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

.Parameter RuleName
    Specifies that only matching firewall rules of the indicated name or display name are retrieved. Use * for all rules

.Parameter ComputerName
    Specifies the name of the computer from which to retrieve the firewall rules
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.EXAMPLE

#>

[CmdLetBinding()]
Param(
    [string]$RuleName = "*",
    [string]$ComputerName,
    [PSCredential]$AccessAccount
)

$Script:Cim=$null
try{
    if([System.String]::IsNullOrWhiteSpace($RuleName)){
        $RuleName= "*"
    }
    else{
        $RuleName = "*$($RuleName)*"
    }
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName = [System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim = New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }
    
    if($RuleName -eq "*"){
        $Script:Rules = Get-NetFirewallRule -CimSession $Script:Cim -Name *  `
            | Select-Object Name,DisplayName | Sort-Object DisplayName
    }
    else{
        $Script:Rules = Get-NetFirewallRule -CimSession $Script:Cim | Where-Object {$_.Name -like $RuleName -or $_.DisplayName -like $RuleName} `
            | Select-Object Name,DisplayName,Direction,Action | Sort-Object DisplayName   
    }
    foreach($item in $Script:Rules)
    {
        if($SRXEnv) {
            $null = $SRXEnv.ResultList.Add($item.Name)
            $null = $SRXEnv.ResultList2.Add("$($item.DisplayName) | $($item.Direction) | $($item.Action)")
        }
        else{
            Write-Output "$($item.DisplayName) | $($item.Direction) | $($item.Action)"
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