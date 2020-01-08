#Requires -Version 5.0
#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
        Remove old profiles on computer
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module ActiveDirectory
        Requires Library script SysMLibrary.ps1

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/System
                
    .Parameter ComputerName
        Specifies the computer from which the profile are removed
                
    .Parameter AccessAccount
        Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used
                
    .Parameter PreviousAction
        Action to be performed before remove the profile
                
    .Parameter PreviousServerProfileAction
        Action to be performed before remove the profile on server
                
    .Parameter LastUseXDaysAgo
        Specifies the days the user has not logged in 
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$ComputerName,
    [pscredential]$AccessAccount,
    [int]$LastUseXDaysAgo = 180,
    [ValidateSet('None','ZipProfile','Rename')]
    [string]$PreviousAction = 'ZipProfile',
    [ValidateSet('None','ZipProfile','Rename')]
    [string]$PreviousServerProfileAction = 'ZipProfile'    
)

Import-Module ActiveDirectory

$Script:Cim= $null
$Global:output = @()
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

    RemoveOldProfiles -DaysAgo $LastUseXDaysAgo -ComputerAction $PreviousAction -ServerAction $PreviousServerProfileAction `
                        -CimSession $Script:Cim -ComputerName $ComputerName -AccessAccount $AccessAccount

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Global:output
    }
    else{
        Write-Output $Global:output
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