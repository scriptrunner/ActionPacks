#Requires -Version 5.1

<#
.SYNOPSIS
    Creates a local user account

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    ScriptRunner Version 4.2.x or higher

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/LocalAccounts

.Parameter Name
    Specifies the user name for the user account

.Parameter Description
    Specifies a comment for the user account. The maximum length is 48 characters    

.Parameter AccountNeverExpires
    Indicates that the account does not expire

.Parameter FullName
    Specifies the full name for the user account. The full name differs from the user name of the user account

.Parameter Password
    Specifies a password for the user account

.Parameter PasswordNeverExpires
    Indicates whether the password expires

.Parameter UserMayNotChangePassword
    Indicates that the user can change the password on the user account

.Parameter Disabled
    Indicates that this cmdlet creates the user account as disabled
 
.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [parameter(Mandatory = $true)]
    [string]$Name,
    [string]$Description,     
    [switch]$AccountNeverExpires,     
    [string]$FullName,    
    [securestring]$Password,    
    [switch]$PasswordNeverExpires,      
    [switch]$UserMayNotChangePassword,  
    [switch]$Disabled,
    [string]$ComputerName,    
    [PSCredential]$AccessAccount
)

try{
    $Script:output
    if([System.String]::IsNullOrWhiteSpace($Description) -eq $false){
        $Description = " "
    }
    [string[]]$Properties = @('Name','Description','SID','Enabled','LastLogon')

    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){
        if([System.String]::IsNullOrWhiteSpace($Password) -eq $true){
            $null = New-LocalUser -Name $Name -Description $Description -AccountNeverExpires:$AccountNeverExpires -Disabled:$Disabled `
                -FullName $FullName -NoPassword `
                -UserMayNotChangePassword:$UserMayNotChangePassword -Confirm:$False -ErrorAction Stop
        }
        else {
            $null = New-LocalUser -Name $Name -Description $Description -AccountNeverExpires:$AccountNeverExpires -Disabled:$Disabled `
                -FullName $FullName -Password $Script:Password -PasswordNeverExpires:$PasswordNeverExpires `
                -UserMayNotChangePassword:$UserMayNotChangePassword -Confirm:$False -ErrorAction Stop
        }
        $Script:output = Get-LocalUser -Name $Name | Select-Object $Properties
    }
    else {        
        if($null -eq $AccessAccount){
            if([System.String]::IsNullOrWhiteSpace($Password) -eq $true){
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    $null = New-LocalUser -Name $Using:Name -Description $Using:Description -AccountNeverExpires:$Using:AccountNeverExpires `
                        -FullName $Using:FullName -NoPassword -Disabled:$Using:Disabled `
                        -UserMayNotChangePassword:$Using:UserMayNotChangePassword -Confirm:$False -ErrorAction Stop
                } -ErrorAction Stop
            }
            else {
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    $null = New-LocalUser -Name $Using:Name -Description $Using:Description -AccountNeverExpires:$Using:AccountNeverExpires `
                        -FullName $Using:FullName -Password $Using:Password -PasswordNeverExpires:$Using:PasswordNeverExpires `
                        -UserMayNotChangePassword:$Using:UserMayNotChangePassword -Disabled:$Using:Disabled -Confirm:$False -ErrorAction Stop
                } -ErrorAction Stop
            }
            $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                Get-LocalUser -Name $Using:Name | Select-Object $Using:Properties
            } -ErrorAction Stop
        }
        else {
            if([System.String]::IsNullOrWhiteSpace($Password) -eq $true){
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    $null = New-LocalUser -Name $Using:Name -Description $Using:Description -AccountNeverExpires:$Using:AccountNeverExpires `
                        -FullName $Using:FullName -NoPassword -Disabled:$Using:Disabled `
                        -UserMayNotChangePassword:$Using:UserMayNotChangePassword -Confirm:$False -ErrorAction Stop
                } -ErrorAction Stop
            }
            else {
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    $null = New-LocalUser -Name $Using:Name -Description $Using:Description -AccountNeverExpires:$Using:AccountNeverExpires `
                        -FullName $Using:FullName -Password $Using:Password -PasswordNeverExpires:$Using:PasswordNeverExpires `
                        -UserMayNotChangePassword:$Using:UserMayNotChangePassword -Disabled:$Using:Disabled -Confirm:$False -ErrorAction Stop
                } -ErrorAction Stop
            }
            $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                Get-LocalUser -Name $Using:Name | Select-Object $Using:Properties
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