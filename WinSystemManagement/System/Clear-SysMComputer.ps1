#Requires -Version 5.0
#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
        Remove profiles, clears recycle bin on computer
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
        © AppSphere AG

    .COMPONENT
        Requires Module ActiveDirectory
        Requires Library script SysMLibrary.ps1

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/System
                
    .Parameter ComputerName
        Specifies the computer from which the profile are removed
                
    .Parameter AccessAccount
        Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used
                                
    .Parameter ClearProfiles
        Clean up user profiles
        
    .Parameter PreviousProfileAction
        Action to be performed before remove the profile
                
    .Parameter PreviousServerProfileAction
        Action to be performed before remove the profile on server
                
    .Parameter ProfileLastUseXDaysAgo
        Specifies the days the user has not logged in 

    .Parameter ClearRecycleBin
        Clean up recycle bin

    .Parameter RecycleBinDrives        
        Specifies the drive letters for which this cmdlet clears the recycle bin, comma separated. 
        Is the parameter empty, all items are cleared
#>

param( 
    [Parameter(Mandatory = $true)]
    [string]$ComputerName,
    [pscredential]$AccessAccount,
    [switch]$ClearProfiles,
    [int]$ProfileLastUseXDaysAgo = 180,
    [ValidateSet('None','ZipProfile','Rename')]
    [string]$PreviousProfileAction = 'ZipProfile',
    [ValidateSet('None','ZipProfile','Rename')]
    [string]$PreviousServerProfileAction = 'ZipProfile',
    [switch]$ClearRecycleBin,
    [string]$RecycleBinDrives
)

Import-Module ActiveDirectory

$Script:Cim= $null
try{ 
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName=[System.Net.DNS]::GetHostByName('').HostName
    }          
    [hashtable]$cmdArgs = @{} 
    if($null -eq $AccessAccount){
        $Script:Cim =New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim =New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }
    if($ClearRecycleBin -eq $true){
        $cmdArgs = @{'ErrorAction' = 'SilentlyContinue'
                    'Force' = $null
                    'Confirm' = $false
                    } 
        if([System.String]::IsNullOrWhiteSpace($RecycleBinDrives) -eq $false){
            $cmdArgs.Add('DriveLetter',$RecycleBinDrives.Split(','))
        }
        if($null -eq $AccessAccount){
            Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                $CopyParams = $using:cmdArgs
                Clear-RecycleBin @CopyParams
            } -ErrorAction Stop
        }
        else{
            Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                $CopyParams = $using:cmdArgs
                Clear-RecycleBin @CopyParams
            } -ErrorAction Stop
        }
        $Global:output += "Recycle bin cleared"
    }
    # clear old profiles
    if($ClearProfiles -eq $true){
        RemoveOldProfiles -DaysAgo $LastUseXDaysAgo -ComputerAction $PreviousAction -ServerAction $PreviousServerProfileAction `
                        -CimSession $Script:Cim -ComputerName $ComputerName -AccessAccount $AccessAccount
    }

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