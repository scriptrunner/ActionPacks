#Requires -Version 5.1

<#
.SYNOPSIS
    Modifies a local user account. 
    Only parameters with value are set

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
    Specifies an name of user account that changes

.Parameter SID
    Specifies an security ID (SID) of user account that changes

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

.Parameter UserMayChangePassword
    Indicates that the user can change the password on the user account

.Parameter NewName
    Specifies a new name for the user account
 
.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "ByName")]    
    [string]$Name,
    [Parameter(Mandatory = $true, ParameterSetName = "BySID")]    
    [string]$SID,
    [Parameter(ParameterSetName = "ByName")]   
    [Parameter(ParameterSetName = "BySID")]  
    [string]$Description,     
    [Parameter(ParameterSetName = "ByName")]   
    [Parameter(ParameterSetName = "BySID")]  
    [switch]$AccountNeverExpires,     
    [Parameter(ParameterSetName = "ByName")]   
    [Parameter(ParameterSetName = "BySID")]  
    [string]$FullName,    
    [Parameter(ParameterSetName = "ByName")]   
    [Parameter(ParameterSetName = "BySID")]  
    [securestring]$Password,      
    [Parameter(ParameterSetName = "ByName")]   
    [Parameter(ParameterSetName = "BySID")]  
    [bool]$PasswordNeverExpires,      
    [Parameter(ParameterSetName = "ByName")]   
    [Parameter(ParameterSetName = "BySID")]  
    [bool]$UserMayChangePassword,     
    [Parameter(ParameterSetName = "ByName")]   
    [Parameter(ParameterSetName = "BySID")]  
    [string]$NewName,
    [Parameter(ParameterSetName = "ByName")]   
    [Parameter(ParameterSetName = "BySID")]     
    [string]$ComputerName,    
    [Parameter(ParameterSetName = "ByName")]   
    [Parameter(ParameterSetName = "BySID")]     
    [PSCredential]$AccessAccount
)

try{
    $Script:output
    $Script:user
    [string[]]$Properties = @('Name','Description','SID','Enabled','LastLogon')
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){
        if($PSCmdlet.ParameterSetName  -eq "ByName"){
            $Script:user = Get-LocalUser -Name $Name -ErrorAction Stop
        }
        else {
            $Script:user = Get-LocalUser -SID $SID -ErrorAction Stop
        }
        if($PSBoundParameters.ContainsKey('Description') -eq $true ){
            $null = Set-LocalUser -InputObject $Script:user -Description $Description -ErrorAction Stop
        }
        if($PSBoundParameters.ContainsKey('AccountNeverExpires') -eq $true ){
            $null = Set-LocalUser -InputObject $Script:user -AccountNeverExpires:$AccountNeverExpires -ErrorAction Stop
        }
        if($PSBoundParameters.ContainsKey('FullName') -eq $true ){
            $null = Set-LocalUser -InputObject $Script:user -FullName $NewName -ErrorAction Stop
        }            
        if($PSBoundParameters.ContainsKey('Password') -eq $true ){
            $null = Set-LocalUser -InputObject $Script:user -Password $Password -ErrorAction Stop
        }
        if($PSBoundParameters.ContainsKey('PasswordNeverExpires') -eq $true ){
            $null = Set-LocalUser -InputObject $Script:user -PasswordNeverExpires $PasswordNeverExpires -ErrorAction Stop
        }
        if($PSBoundParameters.ContainsKey('UserMayChangePassword') -eq $true ){
            $null = Set-LocalUser -InputObject $Script:user -UserMayChangePassword $UserMayChangePassword -ErrorAction Stop
        }       
        if($PSBoundParameters.ContainsKey('NewName') -eq $true ){
            $null = Rename-LocalUser -InputObject $Script:user -NewName $NewName -ErrorAction Stop
        }
        $Script:output = Get-LocalUser -SID $Script:user.SID -ErrorAction Stop | Select-Object $Properties
    }
    else {        
        if($null -eq $AccessAccount){
            if($PSCmdlet.ParameterSetName  -eq "ByName"){
                $Script:user = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Get-LocalUser -Name $Using:Name -ErrorAction Stop
                }
            }
            else {
                $Script:user = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Get-LocalUser -SID $Using:SID -ErrorAction Stop
                }
            }
            if($PSBoundParameters.ContainsKey('Description') -eq $true ){
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    $null = Set-LocalUser -InputObject $Using:user -Description $Using:Description -ErrorAction Stop
                } -ErrorAction Stop
            }
            if($PSBoundParameters.ContainsKey('AccountNeverExpires') -eq $true ){
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    $null = Set-LocalUser -InputObject $Using:user -AccountNeverExpires:$Using:AccountNeverExpires -ErrorAction Stop
                } -ErrorAction Stop
            }
            if($PSBoundParameters.ContainsKey('FullName') -eq $true ){
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    $null = Set-LocalUser -InputObject $Using:user -FullName $Using:NewName -ErrorAction Stop
                } -ErrorAction Stop
            }            
            if($PSBoundParameters.ContainsKey('Password') -eq $true ){
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    $null = Set-LocalUser -InputObject $Using:user -Password $Using:Password -ErrorAction Stop
                } -ErrorAction Stop
            }
            if($PSBoundParameters.ContainsKey('PasswordNeverExpires') -eq $true ){
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    $null = Set-LocalUser -InputObject $Using:user -PasswordNeverExpires $Using:PasswordNeverExpires -ErrorAction Stop
                } -ErrorAction Stop
            }
            if($PSBoundParameters.ContainsKey('UserMayChangePassword') -eq $true ){
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    $null = Set-LocalUser -InputObject $Using:user -UserMayChangePassword $Using:UserMayChangePassword -ErrorAction Stop
                } -ErrorAction Stop
            }            
            if($PSBoundParameters.ContainsKey('NewName') -eq $true ){
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    $null = Rename-LocalUser -InputObject $Using:user -NewName $Using:NewName -ErrorAction Stop
                } -ErrorAction Stop
            }
            $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                Get-LocalUser -SID $Using:user.SID -ErrorAction Stop | Select-Object $Using:Properties
            } -ErrorAction Stop
        }
        else {
            if($PSCmdlet.ParameterSetName  -eq "ByName"){
                $Script:user = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    Get-LocalUser -Name $Using:Name -ErrorAction Stop
                }
            }
            else {
                $Script:user = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    Get-LocalUser -SID $Using:SID -ErrorAction Stop
                }
            }
            if($PSBoundParameters.ContainsKey('Description') -eq $true ){
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    $null = Set-LocalUser -InputObject $Using:user -Description $Using:Description -ErrorAction Stop
                } -ErrorAction Stop
            }
            if($PSBoundParameters.ContainsKey('AccountNeverExpires') -eq $true ){
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    $null = Set-LocalUser -InputObject $Using:user -AccountNeverExpires:$Using:AccountNeverExpires -ErrorAction Stop
                } -ErrorAction Stop
            }
            if($PSBoundParameters.ContainsKey('FullName') -eq $true ){
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    $null = Set-LocalUser -InputObject $Using:user -FullName $Using:NewName -ErrorAction Stop
                } -ErrorAction Stop
            }            
            if($PSBoundParameters.ContainsKey('Password') -eq $true ){
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    $null = Set-LocalUser -InputObject $Using:user -Password $Using:Password -ErrorAction Stop
                } -ErrorAction Stop
            }
            if($PSBoundParameters.ContainsKey('PasswordNeverExpires') -eq $true ){
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    $null = Set-LocalUser -InputObject $Using:user -PasswordNeverExpires $Using:PasswordNeverExpires -ErrorAction Stop
                } -ErrorAction Stop
            }
            if($PSBoundParameters.ContainsKey('UserMayChangePassword') -eq $true ){
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    $null = Set-LocalUser -InputObject $Using:user -UserMayChangePassword $Using:UserMayChangePassword -ErrorAction Stop
                } -ErrorAction Stop
            }            
            if($PSBoundParameters.ContainsKey('NewName') -eq $true ){
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    $null = Rename-LocalUser -InputObject $Using:user -NewName $Using:NewName -ErrorAction Stop
                } -ErrorAction Stop
            }
            $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                Get-LocalUser -SID $Using:user.SID -ErrorAction Stop | Select-Object $Using:Properties
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