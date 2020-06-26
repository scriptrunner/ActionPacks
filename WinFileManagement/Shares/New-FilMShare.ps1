#Requires -Version 4.0

<#
.SYNOPSIS
    Creates an share and sets the permissions for the accounts

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinFileManagement/Shares

.Parameter ShareName
    Specifies a name for the share

.Parameter Path
    Specifies the path of the location of the folder to share

.Parameter ComputerName
    Specifies the name of the computer from which to create the share
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter Description
    Specifies an optional description of the share

.Parameter ScopeName
    Specifies the scope name of the share

.Parameter EncryptData
    Indicates that the share is encrypted

.Parameter ModifyAccess
    Specifies which accounts are granted modify permission to access the share. Multiple accounts can be specified comma separated

.Parameter FullControlAccess
    Specifies which accounts are granted full permission to access the share. Multiple accounts can be specified comma separated

.Parameter ReadAccess
    Specifies which accounts are granted read permission to access the share. Multiple accounts can be specified comma separated

.Parameter NoAccess
    Specifies which accounts are denied access to the share. Multiple accounts can be specified comma separated
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$ShareName,
    [Parameter(Mandatory = $true)]
    [string]$Path,
    [string]$ComputerName,
    [PSCredential]$AccessAccount,
    [string]$Description,
    [string]$ScopeName,
    [bool]$EncryptData,
    [string[]]$ModifyAccess,
    [string[]]$FullControlAccess,
    [string[]]$ReadAccess,
    [string[]]$NoAccess
)

$Script:Cim = $null
$Script:output = @()
[string[]]$Properties = @('Name','Description','Path','ShareState','ScopeName','CurrentUsers','ShareType','AvailabilityType','EncryptData')
try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    if([System.String]::IsNullOrWhiteSpace($ScopeName)){
        $ScopeName = '*'
    }
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName=[System.Net.DNS]::GetHostByName('').HostName
    }
    if($null -eq $AccessAccount){
        $Script:Cim = New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }
    $tmp = New-SmbShare -CimSession $Script:Cim -Name $ShareName -Path $Path -Description $Description -ScopeName $ScopeName -EncryptData $EncryptData -ErrorAction Stop

    # Change access
    if(-not [System.String]::IsNullOrWhiteSpace($ModifyAccess)){
        foreach($chn in $ModifyAccess){
            try{
                $tmp = Grant-SmbShareAccess -Name $ShareName -AccountName $chn -AccessRight Change -Force -CimSession $Script:Cim -ErrorAction Stop      
                $Script:output += "Change access set for $($chn)"
            }
            catch
            {$Script:output +="Error set change access for $($chn) - $($_.Exception.Message)"}
        }
    } 
    # Read access
    if(-not [System.String]::IsNullOrWhiteSpace($ReadAccess)){
        foreach($rd in $ReadAccess){
            try{
                $tmp = Grant-SmbShareAccess -Name $ShareName -AccountName $rd -AccessRight Read -Force -CimSession $Script:Cim -ErrorAction Stop      
                $Script:output += "Read access set for $($rd)"
            }
            catch
            {$Script:output +="Error set read access for $($rd) - $($_.Exception.Message)"}
        }
    } 
    # Full access
    if(-not [System.String]::IsNullOrWhiteSpace($FullControlAccess)){
        foreach($fa in $FullControlAccess){
            try{
                $tmp = Grant-SmbShareAccess -Name $ShareName -AccountName $fa -AccessRight Full -Force -CimSession $Script:Cim -ErrorAction Stop      
                $Script:output += "Full access set for $($fa)"
            }
            catch
            {$Script:output +="Error set full access for $($fa) - $($_.Exception.Message)"}
        }
    } 
    # No access
    if(-not [System.String]::IsNullOrWhiteSpace($NoAccess)){
        foreach($no in $NoAccess){
            try{
                $tmp = Block-SmbShareAccess -Name $ShareName -AccountName $no -Force -CimSession $Script:Cim -ErrorAction Stop      
                $Script:output += "No access set for $($no)"
            }
            catch
            {$Script:output +="Error set no access for $($no) - $($_.Exception.Message)"}
        }
    } 

    $Script:output += Get-SmbShare -Name $ShareName -CimSession $Script:Cim -IncludeHidden -ErrorAction Stop `
                    | Select-Object $Properties
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
    if($null -ne $Script:Cim){
        Remove-CimSession $Script:Cim 
    }
}