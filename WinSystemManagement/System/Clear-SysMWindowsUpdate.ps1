#Requires -Version 4.0

<#
    .SYNOPSIS
        Clear Windows Update. Removes the system folder SoftwareDistribution 
    
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
        Specifies the computer that cleans up Windows Update. The default is the local computer

    .Parameter ExecutionCredential
        Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used
#>

param( 
    [Parameter(Mandatory =$true)]
    [string]$ComputerName,
    [Parameter(Mandatory =$true)]
    [pscredential]$ExecutionCredential
)

try{ 
    $Script:output = @()
    
    $Script:output += Invoke-Command -ComputerName $ComputerName -Credential $ExecutionCredential -ScriptBlock{
        [bool]$startBITS = $false
        # Windows Update Service
        $srvWU = Get-Service -Name 'wuauserv' -ErrorAction Stop 
        if($srvWU.Status -eq 'Running'){
            $null = Stop-Service -InputObject $srvWU -Force -Confirm:$false -ErrorAction Stop
        }
        # Background Intelligent Transfer Service 
        $srvBits = Get-Service -Name 'BITS' -ErrorAction Stop 
        if($srvBits.Status -eq 'Running'){
            $null = Stop-Service -InputObject $srvBits -Force -Confirm:$false -ErrorAction Stop
            $startBITS = $true
        }
        # Remove SoftwareDistribution folder
        Remove-Item -Path "$($env:SystemRoot)\SoftwareDistribution" -Recurse -Force -Confirm:$false -ErrorAction Stop
        # Start services
        if($startBITS -eq $true){
            $null = Start-Service -InputObject $srvBits -Confirm:$false -ErrorAction Stop
        }
        $null = Start-Service -InputObject $srvWU -Confirm:$false -ErrorAction Stop
    }
    
    $Script:output += "Windows Update cleared"
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:output
    }
    else{
        Write-Output $Script:output
    }
}
catch{
    throw # throws error for ScriptRunner
}
finally{
    
}