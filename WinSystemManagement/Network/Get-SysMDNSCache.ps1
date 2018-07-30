#Requires -Version 4.0

<#
.SYNOPSIS
    Retrieves the contents of the DNS client cache

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/Network

.Parameter Section
    Specifies the record section

.Parameter Status
    Specifies the record status

.Parameter Type
    Specifies the record type

.Parameter ComputerName
    Specifies the name of the computer from which to retrieves the dns cache
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [ValidateSet("None", "Answer", "Authority", "Additional")]
    [string]$Section = "None",
    [ValidateSet("None", "Success", "NotExist", "NoRecords")]
    [string]$Status = "None",
    [ValidateSet("None", "A", "NS", "CNAME","SOA","PTR","MX","AAAA","SRV")]
    [string]$Type = "None",
    [string]$ComputerName,
    [PSCredential]$AccessAccount
)

$Script:Cim
try{
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName=[System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim =New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim =New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }
    if($Section -ne "None"){
        if($Status -ne "None"){
            if($Type -ne "None"){
                $Script:Msg = Get-DnsClientcache -CimSession $Script:Cim -Section $Section -Status $Status -Type $Type -ErrorAction Stop
            }
            else{
                $Script:Msg = Get-DnsClientcache -CimSession $Script:Cim -Section $Section -Status $Status -ErrorAction Stop
            }
        }
        elseif($Type -ne "None"){
            $Script:Msg = Get-DnsClientcache -CimSession $Script:Cim -Section $Section -Type $Type -ErrorAction Stop
        }
        else{
            $Script:Msg = Get-DnsClientcache -CimSession $Script:Cim -Section $Section -ErrorAction Stop
        }
    }
    elseif($Status -ne "None"){
        if($Type -ne "None"){
            $Script:Msg = Get-DnsClientcache -CimSession $Script:Cim -Status $Status -Type $Type -ErrorAction Stop
        }
        else{
            $Script:Msg = Get-DnsClientcache -CimSession $Script:Cim -Status $Status -ErrorAction Stop
        }
    }
    elseif($Type -ne "None"){
        $Script:Msg = Get-DnsClientcache -CimSession $Script:Cim -Type $Type -ErrorAction Stop
    }
    else
    {
        $Script:Msg = Get-DnsClientcache -CimSession $Script:Cim -ErrorAction Stop
    }
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:Msg 
    }
    else{
        Write-Output $Script:Msg
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