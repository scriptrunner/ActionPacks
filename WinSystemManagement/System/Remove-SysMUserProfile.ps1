#Requires -Version 4.0

<#
.SYNOPSIS
    Removes the profile of the user

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

.Parameter UserName
    Specifies the login name of the user

.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$UserName,
    [string]$ComputerName,    
    [PSCredential]$AccessAccount
)

try{
    $Script:output
    if([System.string]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName = [System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim = New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }
    $sid = (New-Object Security.Principal.NTAccount($UserName)).Translate([Security.Principal.SecurityIdentifier]).Value
    $quy = [System.String]::Format("SELECT * FROM Win32_UserProfile WHERE SID = '{0}'",$sid)
    $null = Remove-CimInstance -CimSession $Script:Cim -Query $quy -ErrorAction Stop

    if($SRXEnv) {
        $SRXEnv.ResultMessage = "User profile removed"
    }
    else{
        Write-Output "User profile removed"
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