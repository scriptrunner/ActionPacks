#Requires -Version 5.1

<#
.SYNOPSIS
    Sets the system time zone to a specified time zone

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

.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter ZoneID
    Specifies the ID of the time zone to set
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$ZoneID,
    [string]$ComputerName,    
    [PSCredential]$AccessAccount
)

try{    
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $false){
        if($null -eq $AccessAccount){
            $null = Invoke-Command -ComputerName $ComputerName {Set-TimeZone -Id $Using:ZoneID -Confirm:$false }
            $zone = Invoke-Command -ComputerName $ComputerName {Get-TimeZone -Id $Using:ZoneID}
            $Script:output = "Time zone $($zone.DisplayName) successfully set"
        }
        else {
            $null = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount {Set-TimeZone -Id $Using:ZoneID -Confirm:$false }
            $zone = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount {Get-TimeZone -Id $Using:ZoneID}
            $Script:output = "Time zone $($zone.DisplayName) successfully set"
        }
    }
    else {
        $null = Set-TimeZone -Id $ZoneID -Confirm:$false -ErrorAction Stop
        $zone = Get-TimeZone -Id $ZoneID -ErrorAction Stop
        $Script:output = "Time zone $($zone.DisplayName) successfully set"
    }        

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:output
    }
    else{
        Write-Output $Script:output
    }
}
catch{
    throw
}
finally{
}