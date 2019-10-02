#Requires -Version 5.1

<#
.SYNOPSIS
    Moves a package from its current location to another appx volume

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
 
.Parameter Package
    Specifies the full name of a package

.Parameter Volume
    Specifies an AppxVolume object

.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Package,
    [Parameter(Mandatory = $true)]
    [string]$Volume,
    [string]$ComputerName,    
    [PSCredential]$AccessAccount
)

try{
    $Script:output
    [string[]]$Script:Properties = @("Name","Publisher","Architecture","Version","PackageFullName")
    
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){
        Move-AppxPackage -Package $Package -Volume $Volume -Confirm:$false -ErrorAction Stop
        $Script:output = Get-AppxPackage -ErrorAction Stop | Where-Object -Property PackageFullName -eq $Package | Select-Object $Script:Properties
    }
    else {
        if($null -eq $AccessAccount){
            $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                Move-AppxPackage -Package $Using:Package -Volume $Using:Volume -Confirm:$false -ErrorAction Stop;
                Get-AppxPackage -ErrorAction Stop | Where-Object -Property PackageFullName -eq $Using:Package | Select-Object $Using:Properties
            } -ErrorAction Stop
        }
        else {
            $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                Move-AppxPackage -Package $Using:Package -Volume $Using:Volume -Confirm:$false -ErrorAction Stop;
                Get-AppxPackage -ErrorAction Stop | Where-Object -Property PackageFullName -eq $Using:Package | Select-Object $Using:Properties
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