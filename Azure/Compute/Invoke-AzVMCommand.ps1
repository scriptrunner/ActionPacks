#Requires -Version 4.0
#Requires -Modules Az.Compute

<#
.SYNOPSIS
    Invokes a command for the specified Azure virtual machine. 
    The acceptable commands are: Stop, Start, Restart

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Module Az

.LINK
    https://github.com/scriptrunner/ActionPacks/blob/master/Azure/Compute

.Parameter Name
    [sr-en] Specifies the name of the virtual machine
    [sr-de] Name der virtuellen Maschine

.Parameter ResourceGroupName
    [sr-en] Specifies the name of the resource group of the virtual machine
    [sr-de] Name der resource group die die virtuelle Maschine enthält

.Parameter Command
    [sr-en] Specifies the command that executed on the Azure virtual machine
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

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $ret 
    }
    else{
        Write-Output $ret
    }
}
catch{
    throw
}
finally{
}