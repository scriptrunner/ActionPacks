#Requires -Version 5.1

<#
.SYNOPSIS
    Gets the current time zone or a list of available time zones

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
    Specifies the ID of the time zone that retrieves. If ZoneID is not specified, the current time zone are retrieves

.Parameter GetList
    Indicates that this cmdlet gets all available time zones
#>

[CmdLetBinding()]
Param(
    [string]$ComputerName,    
    [PSCredential]$AccessAccount,
    [string]$ZoneID,
    [switch]$GetList 
)

try{
    $Script:output
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $false){
        if($null -eq $AccessAccount){
            if($GetList -eq $true){
                $Script:output = Invoke-Command -ComputerName $ComputerName {Get-TimeZone -ListAvailable}
            }
            else {
                if([System.String]::IsNullOrWhiteSpace($ZoneID)){
                    $Script:output = Invoke-Command -ComputerName $ComputerName {Get-TimeZone }
                }
                else {
                    $Script:output = Invoke-Command -ComputerName $ComputerName {Get-TimeZone -Id $Using:ZoneID}
                }
            }
        }
        else {
            if($GetList -eq $true){
                $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount {Get-TimeZone -ListAvailable}
            }
            else {
                if([System.String]::IsNullOrWhiteSpace($ZoneID)){
                    $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount {Get-TimeZone }
                }
                else {
                    $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount {Get-TimeZone -Id $Using:ZoneID}
                }
            }
        }
    }
    else {
        if($GetList -eq $true){
            $Script:output = Get-TimeZone -ListAvailable -ErrorAction Stop
        }
        else {
            if([System.String]::IsNullOrWhiteSpace($ZoneID)){
                $Script:output = Get-TimeZone -ErrorAction Stop
            }
            else {
                $Script:output = Get-TimeZone -Id $ZoneID -ErrorAction Stop           
            }
        }
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