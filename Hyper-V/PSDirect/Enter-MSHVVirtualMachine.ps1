#Requires -Version 4.0
#Requires -Modules Hyper-V

<#
    .SYNOPSIS
        Enters the virtual machine and retrieves the computer name
    
    .DESCRIPTION
        Use "Win2K12R2 or Win8.x" for execution on Windows Server 2012 R2 or on Windows 8.1,
        when execute on Windows Server 2016 / Windows 10 or newer, use "Newer Systems"  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module Hyper-V

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/Hyper-V/VMs

    .Parameter VMName
        Specifies the name of the virtual machine

    .Parameter AccessAccount
        Specifies the user account that have permission to perform this action
#>

param(    
    [Parameter(Mandatory = $true)]
    [string]$VMName,
    [Parameter(Mandatory = $true)]
    [PSCredential]$AccessAccount
)

Import-Module Hyper-V

try { 
    $sess = New-PSSession -VMName $VMName -Credential $AccessAccount -ErrorAction Stop
    $output = Invoke-Command $sess -ScriptBlock {$env:COMPUTERNAME} # enter here your commands. see here: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/invoke-command?view=powershell-6
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $output
    }    
    else {
        Write-Output $output
    }
}
catch {
    throw
}
finally{
    if($null -ne $Script:sess){
        Remove-PSSession $Script:sess 
    }
}