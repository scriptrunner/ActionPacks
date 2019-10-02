#Requires -Version 5.1

<#
.SYNOPSIS
    Removes an appx volume

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

.Parameter Volume
    Specifies the AppxVolume object to remove
 
.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Volume,
    [string]$ComputerName,    
    [PSCredential]$AccessAccount
)

try{
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){
        $null = Remove-AppxVolume -Volume $Volume -Confirm:$false -ErrorAction Stop
    }
    else {
        if($null -eq $AccessAccount){
            $null = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                Remove-AppxVolume -Volume $Using:Volume -Confirm:$false -ErrorAction Stop
            } -ErrorAction Stop
        }
        else {
            $null = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                Remove-AppxVolume -Volume $Using:Volume -Confirm:$false -ErrorAction Stop
            } -ErrorAction Stop
        }
    }      
    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Volume $($Volume) removed"
    }
    else{
        Write-Output "Volume $($Volume) removed"
    }
}
catch{
    throw
}
finally{
}