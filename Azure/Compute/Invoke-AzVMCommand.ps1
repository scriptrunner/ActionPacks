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
    The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
    © AppSphere AG

.COMPONENT
    Requires Module Az

.LINK
    https://github.com/scriptrunner/ActionPacks/blob/master/Azure

.Parameter AzureCredential
    The PSCredential object provides the user ID and password for organizational ID credentials, or the application ID and secret for service principal credentials

.Parameter Tenant
    Tenant name or ID

.Parameter Name
    Specifies the name of the Azure virtual machine

.Parameter ResourceGroupName
    Specifies the name of a resource group

.Parameter Command
    Specifies the command that executed on the Azure virtual machine
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [pscredential]$AzureCredential,
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    [ValidateSet('Stop','Start','Restart')]
    [string]$Command,
    [string]$Tenant
)

Import-Module Az

try{
 #   ConnectAzure -AzureCredential $AzureCredential -Tenant $Tenant
    
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
 #   DisconnectAzure -Tenant $Tenant
}