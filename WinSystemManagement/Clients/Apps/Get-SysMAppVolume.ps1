#Requires -Version 5.1

<#
.SYNOPSIS
    Gets appx volumes for the computer

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
    © AppSphere AG

.COMPONENT

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinClientManagement/Apps

.Parameter Path
    Specifies the path of the mount point of a volume

.Parameter Online
    Indicates that returns only volumes that are currently mounted

.Parameter Offline
    Indicates that returns only volumes that are currently dismounted

.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [switch]$Online,
    [switch]$Offline,
    [string]$Path,
    [string]$ComputerName,    
    [PSCredential]$AccessAccount
)

try{
    $Script:output
    if([System.String]::IsNullOrWhiteSpace($Path) -eq $true){
        $Path = '*'
    }

    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){
        if($Online -eq $true){
            $Script:output = Get-AppxVolume -Online -ErrorAction Stop | Format-List
        }
        elseif($Offline -eq $true){
            $Script:output = Get-AppxVolume -Offline -ErrorAction Stop | Format-List
        }
        else {
            $Script:output = Get-AppxVolume -Path $Path -ErrorAction Stop | Format-List
        }
    }
    else {
        if($null -eq $AccessAccount){
            if($Online -eq $true){
                $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Get-AppxVolume -Online -ErrorAction Stop | Format-List
                } -ErrorAction Stop
            }
            elseif($Offline -eq $true){
                $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Get-AppxVolume -Offline -ErrorAction Stop | Format-List
                } -ErrorAction Stop
            }
            else {
                $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Get-AppxVolume -Path $Using:Path -ErrorAction Stop | Format-List
                } -ErrorAction Stop
            }
        }
        else {
            if($Online -eq $true){
                $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    Get-AppxVolume -Online -ErrorAction Stop | Format-List
                } -ErrorAction Stop
            }
            elseif($Offline -eq $true){
                $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    Get-AppxVolume -Offline -ErrorAction Stop | Format-List
                } -ErrorAction Stop
            }
            else {
                $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    Get-AppxVolume -Path $Using:Path -ErrorAction Stop | Format-List
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