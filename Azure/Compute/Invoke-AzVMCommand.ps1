#Requires -Version 5.0
#Requires -Modules Az.Compute

<#
.SYNOPSIS
    Invokes a command for the specified Azure virtual machine. 
    The acceptable commands are: Stop, Start, Restart

.DESCRIPTION

.NOTES
    This PowerShell script was originally developed for ScriptRunner and has been adapted for a non-ScriptRunner environment.

.COMPONENT
    Requires Module Az.Compute

.Parameter Name
    [sr-en] Name of the virtual machine
    [sr-de] Name der virtuellen Maschine

.Parameter ResourceGroupName
    [sr-en] Name of the resource group of the virtual machine
    [sr-de] Name der resource group die die virtuelle Maschine enthält

.Parameter Command
    [sr-en] Command that executed on the Azure virtual machine
    [sr-de] Kommando das für die virtuelle Maschine ausgeführt werden soll
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [ValidateSet('Stop','Start','Restart')]
    [string]$Command
)

Import-Module Az.Compute

try{
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'Confirm' = $false 
                            'Name' = $Name
                            'ResourceGroupName' = $ResourceGroupName
                            }
    switch ($Command){
        "Stop"{
            $cmdArgs.Add("Force",$null)
            $ret = Stop-AzVM @cmdArgs
        }
        "Start"{
            $ret = Start-AzVM @cmdArgs
        }
        "Restart"{
            $ret = Restart-AzVM @cmdArgs
        }
    }

    Write-Output $ret
}
catch{
    throw
}
finally{
}