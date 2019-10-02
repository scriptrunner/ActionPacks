#Requires -Version 5.1

<#
.SYNOPSIS
    Adds an appx volume to the Package Manager

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/Clients/Apps

.Parameter Path
    Specifies the path of the mount point of the volume that this cmdlet adds. 
    The parameter must be specified as a drive letter followed by "WindowsApps" as the directory
 
.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Path,
    [string]$ComputerName,    
    [PSCredential]$AccessAccount
)

try{
    $Script:output

    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){
        $Script:output = Add-AppxVolume -Path $Path -Confirm:$false -ErrorAction Stop 
    }
    else {
        if($null -eq $AccessAccount){
            $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                Add-AppxVolume -Path $Using:Path -Confirm:$false -ErrorAction Stop
            } -ErrorAction Stop
        }
        else {
            $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                Add-AppxVolume -Path $Using:Path -Confirm:$false -ErrorAction Stop
            } -ErrorAction Stop
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