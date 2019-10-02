#Requires -Version 5.1

<#
.SYNOPSIS
    Merges Windows Update .etl files into a single log file

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

.Parameter LogPath
    Specifies the full path to which Get-WindowsUpdateLog writes WindowsUpdate.log, e.g. C:\Temp\WindowsUpdate.log. 
    The default value is WindowsUpdate.log in the Desktop folder of the current user
    
.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [string]$LogPath,
    [string]$ComputerName,    
    [PSCredential]$AccessAccount
)

try{
    $Script:output
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){
        if([System.String]::IsNullOrWhiteSpace($LogPath) -eq $true){
            $Script:output = Get-WindowsUpdateLog -Confirm:$false -ErrorAction Stop
        }
        else {
            $Script:output = Get-WindowsUpdateLog -LogPath $LogPath -Confirm:$false -ErrorAction Stop            
        }
    }
    else {
        if($null -eq $AccessAccount){
            if([System.String]::IsNullOrWhiteSpace($LogPath) -eq $true){
                $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Get-WindowsUpdateLog -Confirm:$false -ErrorAction Stop
                } -ErrorAction Stop    
            }
            else {
                $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Get-WindowsUpdateLog -LogPath $Using:LogPath -Confirm:$false -ErrorAction Stop
                } -ErrorAction Stop
            }
        }
        else {
            if([System.String]::IsNullOrWhiteSpace($LogPath) -eq $true){
                $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    Get-WindowsUpdateLog -Confirm:$false -ErrorAction Stop
                } -ErrorAction Stop
            }
            else {
                $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    Get-WindowsUpdateLog -LogPath $Using:LogPath -Confirm:$false -ErrorAction Stop
                } -ErrorAction Stop
            }
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