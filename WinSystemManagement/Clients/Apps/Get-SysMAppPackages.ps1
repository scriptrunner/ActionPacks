#Requires -Version 5.1

<#
.SYNOPSIS
    Gets a list of the app packages that are installed

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
 
.Parameter AllUsers
    Lists app packages for all user accounts on the computer

.Parameter Name
    Specifies the name of a particular package

.Parameter PackageTypeFilter
    Specifies one or more types of packages that receives from the package repository

.Parameter Publisher
    Specifies the publisher of a particular package

.Parameter User
    Specifies a user

.Parameter Volume
    If you specify this parameter, only packages returns that are relative to volume that this parameter specifies

.Parameter Properties
    List of properties to expand, comma separated e.g. Name,Version. Use * for all properties

.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [switch]$AllUsers,
    [string]$Name,
    [ValidateSet("None", "Main", "Framework", "Resource", "Bundle", "Xap")]
    [string[]]$PackageTypeFilter,
    [string]$Publisher,
    [string]$User,
    [string]$Volume,
    [ValidateSet('*','Name','Publisher','Architecture','Version','PackageFullName')]
    [string[]]$Properties = @('Name','Publisher','Architecture','Version','PackageFullName'),
    [string]$ComputerName,    
    [PSCredential]$AccessAccount
)

try{
    $Script:output
    if(($null -eq $PackageTypeFilter) -or ($PackageTypeFilter.Length -lt 0)){
        $PackageTypeFilter = @("None", "Main", "Framework", "Resource", "Bundle", "Xap")
    }
    if([System.String]::IsNullOrWhiteSpace($Name) -eq $true){
        $Name = '*'
    }
    if([System.String]::IsNullOrWhiteSpace($Publisher) -eq $true){
        $Publisher = '*'
    }    
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){
        [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                                'Publisher' = $Publisher
                                'PackageTypeFilter' = $PackageTypeFilter 
                                'Name' = $Name
                                }
        if([System.String]::IsNullOrWhiteSpace($Volume) -eq $false){
            $cmdArgs.Add('Volume', $Volume)
        }
        if([System.String]::IsNullOrWhiteSpace($User) -eq $true){
            $cmdArgs.Add('AllUsers', $AllUsers.ToBool())
        }
        else {
            $cmdArgs.Add('User', $User)
        }
        $Script:output = Get-AppxPackage @cmdArgs | Select-Object $Properties
    }
    else {
        if($null -eq $AccessAccount){
            if([System.String]::IsNullOrWhiteSpace($Volume) -eq $true){
                if([System.String]::IsNullOrWhiteSpace($User) -eq $true){
                    $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                        Get-AppxPackage -AllUsers:$Using:AllUsers -PackageTypeFilter $Using:PackageTypeFilter -Name $Using:Name `
                            -Publisher $Using:Publisher -ErrorAction Stop | Select-Object $Using:Properties
                    } -ErrorAction Stop
                }
                else{
                    $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                        Get-AppxPackage -User $Using:User -PackageTypeFilter $Using:PackageTypeFilter -Name $Using:Name `
                            -Publisher $Using:Publisher -ErrorAction Stop | Select-Object $Using:Properties
                    } -ErrorAction Stop
                }
            }
            else{
                if([System.String]::IsNullOrWhiteSpace($User) -eq $true){
                    $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                        Get-AppxPackage -AllUsers:$Using:AllUsers -PackageTypeFilter $Using:PackageTypeFilter -Name $Using:Name `
                            -Publisher $Using:Publisher -Volume $Using:Volume -ErrorAction Stop | Select-Object $Using:Properties
                    } -ErrorAction Stop
                }
                else{
                    $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                        Get-AppxPackage -User $Using:User -PackageTypeFilter $Using:PackageTypeFilter -Name $Using:Name `
                            -Publisher $Using:Publisher -Volume $Using:Volume -ErrorAction Stop | Select-Object $Using:Properties
                    } -ErrorAction Stop
                }
            }
        }
        else {
            if([System.String]::IsNullOrWhiteSpace($Volume) -eq $true){
                if([System.String]::IsNullOrWhiteSpace($User) -eq $true){
                    $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                        Get-AppxPackage -AllUsers:$Using:AllUsers -PackageTypeFilter $Using:PackageTypeFilter -Name $Using:Name `
                            -Publisher $Using:Publisher -ErrorAction Stop | Select-Object $Using:Properties
                    } -ErrorAction Stop
                }
                else{
                    $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                        Get-AppxPackage -User $Using:User -PackageTypeFilter $Using:PackageTypeFilter -Name $Using:Name `
                            -Publisher $Using:Publisher -ErrorAction Stop | Select-Object $Using:Properties
                    } -ErrorAction Stop
                }    
            }
            else {
                if([System.String]::IsNullOrWhiteSpace($User) -eq $true){
                    $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                        Get-AppxPackage -AllUsers:$Using:AllUsers -PackageTypeFilter $Using:PackageTypeFilter -Name $Using:Name `
                            -Publisher $Using:Publisher -Volume $Using:Volume -ErrorAction Stop | Select-Object $Using:Properties
                    } -ErrorAction Stop
                }
                else{
                    $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                        Get-AppxPackage -User $Using:User -PackageTypeFilter $Using:PackageTypeFilter -Name $Using:Name `
                            -Publisher $Using:Publisher -Volume $Using:Volume -ErrorAction Stop | Select-Object $Using:Properties
                    } -ErrorAction Stop
                }            
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