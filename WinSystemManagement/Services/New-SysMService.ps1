#Requires -Version 4.0

<#
.SYNOPSIS
    Creates a new Windows service

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/Services

.Parameter ComputerName
    Gets the service running on the specified computer. The default is the local computer

.Parameter BinaryPathName
    Specifies the path of the executable file for the service

.Parameter ServiceName
    Specifies the name of the service

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action

.Parameter DisplayName
    Specifies a display name for the service

.Parameter Description
    Specifies a description of the service.

.Parameter StartupType
    Sets the startup type of the service
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$BinaryPathName,
    [Parameter(Mandatory = $true)]
    [string]$ServiceName,    
    [string]$ComputerName,
    [PSCredential]$AccessAccount,
    [string]$DisplayName,
    [string]$Description,
    [ValidateSet("Automatic","Manual","Disabled")]
    [string]$StartupType = "Disabled"
)

try{
    [string[]]$Properties = @('Name','DisplayName','Status','RequiredServices','DependentServices','CanStop','CanShutdown','CanPauseAndContinue')

    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){
        $ComputerName = "."
    }
    if([System.String]::IsNullOrWhiteSpace($DisplayName) -eq $true){
        $DisplayName = $ServiceName
    }
    if([System.String]::IsNullOrWhiteSpace($Description) -eq $true){
        $Description = " "
    }
    if($ComputerName -eq "."){
        if($null -eq $AccessAccount){
            $Script:srv = New-Service -Name $ServiceName -BinaryPathName $BinaryPathName -DisplayName $DisplayName `
                        -Description $Description -StartupType $StartupType -Confirm:$false -ErrorAction Stop 
        }
        else {
            $Script:srv = New-Service -Credential $AccessAccount -Name $ServiceName -BinaryPathName $BinaryPathName -DisplayName $DisplayName `
                        -Description $Description -StartupType $StartupType -Confirm:$false -ErrorAction Stop 
        }
    }
    else {
        if($null -eq $AccessAccount){
            $Script:srv = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                        New-Service -Name $Using:ServiceName -BinaryPathName $Using:BinaryPathName -DisplayName $Using:DisplayName `
                        -Description $Using:Description -StartupType $Using:StartupType -Confirm:$false -ErrorAction Stop }
        }
        else {
            $Script:srv = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock {
                        New-Service -Name $Using:ServiceName -BinaryPathName $Using:BinaryPathName -DisplayName $Using:DisplayName `
                        -Description $Using:Description -StartupType $Using:StartupType -Confirm:$false -ErrorAction Stop }
        }    
    }

    $result = Get-Service -ComputerName $ComputerName -Name $Script:srv.Name -ErrorAction Stop | Select-Object $Properties
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $result
    }
    else{
        Write-Output $result
    }
}
catch{
    throw
}
finally{
}