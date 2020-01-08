#Requires -Version 4.0

<#
.SYNOPSIS
    Changes the explorer settings for one or all logged on users. 
    The script works only for logged in users, the changes are effective the next time the user logs in

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

.Parameter UserName
    Specifies an name of user account that explorer settings changes. 
    If the parameter empty the settings of all logged on users where changes

.Parameter HideFileExtensions
    Specifies the setting "Hide extensions for known file types"

.Parameter ShowHiddenFilesFoldersDrives
    Specifies the setting "Show hidden files, folders, and drives"

.Parameter CheckBoxesToSelectItems
    Specifies the setting "Item check boxes"
    
.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [string]$UserName,
    [bool]$HideFileExtensions,
    [bool]$ShowHiddenFilesFoldersDrives,
    [bool]$CheckBoxesToSelectItems,
    [string]$ComputerName,    
    [PSCredential]$AccessAccount
)

try{
    [int]$Script:value = 0
    $Script:users
    [string]$ExplorerKey = "HKU:\{0}\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\"

    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){
        try{
            $null = New-PSDrive -Name HKU -PSProvider Registry -Root Registry::HKEY_Users
            if([System.String]::IsNullOrWhiteSpace($UserName) -eq $true){
                $Script:users = (Get-ChildItem -Path HKU: | Where-Object { $_.Name -match 'S-\d-\d+-(\d+-){1,14}\d+$' }).PSChildName                
            }
            else {
                $acc = New-Object Security.Principal.NTAccount($UserName)
                $Script:users = @($acc.Translate([Security.Principal.SecurityIdentifier]).Value)                 
            }            
            foreach($usr in $Script:users){
                [string]$regKey = [System.String]::Format($ExplorerKey,$usr)
                if((Test-Path -Path $regKey) -eq $false){
                    continue
                }
                $Script:value = 0
                if($HideFileExtensions -eq $true){$Script:value = 1}
                $null = Set-ItemProperty -Path $regKey -Name "HideFileExt" -Value $Script:value -Force -ErrorAction Stop
                $Script:value = 1
                if($ShowHiddenFilesFoldersDrives -eq $false){$Script:value = 2}
                $null = Set-ItemProperty -Path $regKey -Name "Hidden" -Value $Script:value -Force -ErrorAction Stop
                $Script:value = 0
                if($CheckBoxesToSelectItems -eq $true){$Script:value = 1}
                $null = Set-ItemProperty -Path $regKey -Name "AutoCheckSelect" -Value $Script:value -Force -ErrorAction Stop
            }
        }
        finally{
            $null = Remove-PSDrive -Name HKU -ErrorAction Ignore
        }
    }
    else {
        if($null -eq $AccessAccount){
            if([System.String]::IsNullOrWhiteSpace($UserName) -eq $true){
                $Script:users = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    $null = New-PSDrive -Name HKU -PSProvider Registry -Root Registry::HKEY_Users;
                    (Get-ChildItem -Path HKU: | Where-Object { $_.Name -match 'S-\d-\d+-(\d+-){1,14}\d+$' }).PSChildName;
                    Remove-PSDrive -Name HKU -ErrorAction Ignore
                } -ErrorAction Stop
            }
            else {
                $acc = New-Object Security.Principal.NTAccount($UserName)
                $Script:users = @($acc.Translate([Security.Principal.SecurityIdentifier]).Value)                 
            }    
            foreach($usr in $Script:users){
                [string]$regKey = [System.String]::Format($ExplorerKey,$usr)
                $null = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    $null = New-PSDrive -Name HKU -PSProvider Registry -Root Registry::HKEY_Users;
                    if((Test-Path -Path $Using:regKey) -eq $true){
                        [int]$setValue = 0;
                        if($Using:HideFileExtensions -eq $true){$setValue = 1};
                        Set-ItemProperty -Path $Using:regKey -Name "HideFileExt" -Value $setValue -Force -ErrorAction Stop;
                        $setValue = 1;
                        if($Using:ShowHiddenFilesFoldersDrives -eq $false){$setValue = 2};
                        Set-ItemProperty -Path $Using:regKey -Name "Hidden" -Value $setValue -Force -ErrorAction Stop;
                        $setValue = 0;
                        if($Using:CheckBoxesToSelectItems -eq $true){$setValue = 1};
                        Set-ItemProperty -Path $Using:regKey -Name "AutoCheckSelect" -Value $setValue -Force -ErrorAction Stop;
                        Remove-PSDrive -Name HKU -ErrorAction Ignore
                    } 
                } -ErrorAction Stop
            }
        }
        else {
            if([System.String]::IsNullOrWhiteSpace($UserName) -eq $true){
                $Script:users = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    $null = New-PSDrive -Name HKU -PSProvider Registry -Root Registry::HKEY_Users;
                    (Get-ChildItem -Path HKU: | Where-Object { $_.Name -match 'S-\d-\d+-(\d+-){1,14}\d+$' }).PSChildName;
                    Remove-PSDrive -Name HKU -ErrorAction Ignore
                } -ErrorAction Stop
            }
            else {
                $acc = New-Object Security.Principal.NTAccount($UserName)
                $Script:users = @($acc.Translate([Security.Principal.SecurityIdentifier]).Value)                 
            }    
            foreach($usr in $Script:users){
                [string]$regKey = [System.String]::Format($ExplorerKey,$usr)
                $null = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    $null = New-PSDrive -Name HKU -PSProvider Registry -Root Registry::HKEY_Users;
                    if((Test-Path -Path $Using:regKey) -eq $true){
                        [int]$setValue = 0;
                        if($Using:HideFileExtensions -eq $true){$setValue = 1};
                        Set-ItemProperty -Path $Using:regKey -Name "HideFileExt" -Value $setValue -Force -ErrorAction Stop;
                        $setValue = 1;
                        if($Using:ShowHiddenFilesFoldersDrives -eq $false){$setValue = 2};
                        Set-ItemProperty -Path $Using:regKey -Name "Hidden" -Value $setValue -Force -ErrorAction Stop;
                        $setValue = 0;
                        if($Using:CheckBoxesToSelectItems -eq $true){$setValue = 1};
                        Set-ItemProperty -Path $Using:regKey -Name "AutoCheckSelect" -Value $setValue -Force -ErrorAction Stop;
                        Remove-PSDrive -Name HKU -ErrorAction Ignore
                    } 
                } -ErrorAction Stop
            }
        }
    }          
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Explorer settings successfully changed"
    }
    else{
        Write-Output "Explorer settings successfully changed"
    }
}
catch{
    throw
}
finally{
}