#Requires -Version 5.1

<#
.SYNOPSIS
    Gets a list of internal and external disks that are online for the local computer

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/Server/Backup

.Parameter DriveLetter
    Specifies the drive letter

.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter Properties
    List of properties to expand, comma separated e.g. VolumeLabel,FreeSpace. Use * for all properties
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]    
    [string]$DriveLetter,
    [string]$ComputerName,    
    [PSCredential]$AccessAccount,
    [ValidateSet('*','VolumeLabel','FileSystem','TotalSpace','FreeSpace','Property')]
    [string[]]$Properties = @('VolumeLabel','FileSystem','TotalSpace','FreeSpace','Property')
)

try{
    $Script:output
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $false){
        if($null -eq $AccessAccount){
            $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                Get-WBVolume -VolumePath $Using:DriveLetter | Select-Object $Using:Properties
            } -ErrorAction Stop
        }
        else {
            $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock {
                Get-WBVolume -VolumePath $Using:DriveLetter | Select-Object $Using:Properties
            } -ErrorAction Stop
        }
    }
    else {
        $Script:output = Get-WBVolume -VolumePath $DriveLetter -ErrorAction Stop | Select-Object $Properties
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