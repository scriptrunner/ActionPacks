#Requires -Version 5.1

<#
.SYNOPSIS
    Removes an app package

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/Clients/Apps

.Parameter Package
    Specifies an AppxPackage object or the full name of a package
    
.Parameter AllUsers
    Removes the app package for all user accounts on the computer

.Parameter PreserveApplicationData
    Specifies that the cmdlet preserves the application data during the package removal

.Parameter User
    Removes the app package only for the specified user

.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$Package,
    [string]$User,
    [switch]$AllUsers,
    [switch]$PreserveApplicationData,
    [string]$ComputerName,    
    [PSCredential]$AccessAccount
)

try{
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){
        if([System.String]::IsNullOrWhiteSpace($User) -eq $false){
            $null = Remove-AppxPackage -User $User -Package $Package -Confirm:$false -ErrorAction Stop
        }
        elseif($AllUsers -eq $true){
            $null = Remove-AppxPackage -AllUsers -Package $Package -Confirm:$false -ErrorAction Stop
        }
        else{
            $null = Remove-AppxPackage -PreserveApplicationData:$PreserveApplicationData -Package $Package -Confirm:$false -ErrorAction Stop
        }
    }
    else {
        if($null -eq $AccessAccount){
            if([System.String]::IsNullOrWhiteSpace($User) -eq $false){
                $null =  Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Remove-AppxPackage -User $Using:User -Package $Using:Package -Confirm:$false -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($AllUsers -eq $true){
                $null =  Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Remove-AppxPackage -AllUsers -Package $Using:Package -Confirm:$false -ErrorAction Stop
                } -ErrorAction Stop
            }
            else{
                $null =  Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Remove-AppxPackage -PreserveApplicationData:$Using:PreserveApplicationData -Package $Using:Package -Confirm:$false -ErrorAction Stop
                } -ErrorAction Stop
            }
        }
        else {
            if([System.String]::IsNullOrWhiteSpace($User) -eq $false){
                $null = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    Remove-AppxPackage -User $Using:User -Package $Using:Package -Confirm:$false -ErrorAction Stop
                } -ErrorAction Stop
            }
            elseif($AllUsers -eq $true){
                $null = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    Remove-AppxPackage -AllUsers -Package $Using:Package -Confirm:$false -ErrorAction Stop
                } -ErrorAction Stop
            }
            else{
                $null = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    Remove-AppxPackage -PreserveApplicationData:$Using:PreserveApplicationData -Package $Using:Package -Confirm:$false -ErrorAction Stop
                } -ErrorAction Stop
            }
        }
    }      
    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Package $($Package) removed"
    }
    else{
        Write-Output "Package $($Package) removed"
    }
}
catch{
    throw
}
finally{
}