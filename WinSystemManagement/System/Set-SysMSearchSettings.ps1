#Requires -Version 4.0

<#
.SYNOPSIS
    Sets the group policy search settings on the computer

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

.Parameter CortanaSearch
    Enable or disable Cortana search

.Parameter AllowSearchToUseLocation
    Enable or disable the use of position data for search and Cortana
    
.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [bool]$CortanaSearch,
    [bool]$AllowSearchToUseLocation,
    [string]$ComputerName,    
    [PSCredential]$AccessAccount
)

try{    
    [string]$Script:regKey = "HKLM:SOFTWARE\Policies\Microsoft\Windows\Windows Search\"
    [int]$Script:cortana = 0
#    [int]$Script:web = 0
    [int]$Script:position = 0
    if($CortanaSearch -eq $true){
        $Script:cortana = 1
    }
 <#   if($WebSearch -eq $false){
        $Script:web = 1
    }#>
    if($AllowSearchToUseLocation -eq $true){
        $Script:position = 1
    }
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){       
      #  Set-ItemProperty -Path $Script:regKey -Name DisableWebSearch -Value $Script:web -Force -ErrorAction Stop
        $null = Set-ItemProperty -Path $Script:regKey -Name AllowSearchToUseLocation -Value $Script:position -Force -ErrorAction Stop
        $null = Set-ItemProperty -Path $Script:regKey -Name AllowCortana -Value $Script:cortana -Force -ErrorAction Stop
    }
    else {
        if($null -eq $AccessAccount){
            $null = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
            #    Set-ItemProperty -Path $Using:regKey -Name DisableWebSearch -Value $Using:web -Force -ErrorAction Stop
                Set-ItemProperty -Path $Using:regKey -Name AllowSearchToUseLocation -Value $Using:position -Force -ErrorAction Stop
                Set-ItemProperty -Path $Using:regKey -Name AllowCortana -Value $Using:cortana -Force -ErrorAction Stop
            } -ErrorAction Stop
        }
        else {
            $null = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
         #       Set-ItemProperty -Path $Using:regKey -Name DisableWebSearch -Value $Using:web -Force -ErrorAction Stop
                Set-ItemProperty -Path $Using:regKey -Name AllowSearchToUseLocation -Value $Using:position -Force -ErrorAction Stop
                Set-ItemProperty -Path $Using:regKey -Name AllowCortana -Value $Using:cortana -Force -ErrorAction Stop
            } -ErrorAction Stop
        }
    }        

    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Search settings changed"
    }
    else{
        Write-Output "Search settings changed"
    }
}
catch{
    throw
}
finally{
}