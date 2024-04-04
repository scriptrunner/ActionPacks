#Requires -Version 5.0

<#
.SYNOPSIS
    Removes permissions from the share

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
    [sr-en] Name of the share

.Parameter AccessType
    [sr-en] Access control type to remove

.Parameter PermissionAccounts
    [sr-en] Accounts the allow or deny permissions to remove from the share. Multiple accounts can be specified comma separated

.Parameter ComputerName
    [sr-en] Name of the computer on which to remove the share permissions
    
.Parameter AccessAccount
    [sr-en] User account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$ShareName,
    [Parameter(Mandatory = $true)]
    [ValidateSet('Allow','Deny')]
    [string]$AccessType="Deny",
    [Parameter(Mandatory = $true)]
    [string[]]$PermissionAccounts,
    [string]$ComputerName,
    [PSCredential]$AccessAccount
)

$Script:Cim = $null
$Script:output = @()
[string[]]$Properties = @('AccessControlType','AccessRight','AccountName')
try{
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName=[System.Net.DNS]::GetHostByName('').HostName
    }
    if($null -eq $AccessAccount){
        $Script:Cim = New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }
    $Script:Share = Get-SmbShare -Name $ShareName -CimSession $Script:Cim -IncludeHidden -ErrorAction Stop
    # Allow permissions
    if($AccessType -eq "Allow"){
        foreach($chn in $PermissionAccounts){
            try{
                $tmp = Revoke-SmbShareAccess -Name $ShareName -AccountName $chn -Force -CimSession $Script:Cim -ErrorAction Stop      
                $Script:output += "Allow permissions removed for $($chn)"
            }
            catch
            {$Script:output +="Error remove allow permissions for $($chn) - $($_.Exception.Message)"}
        }
    } 
    # Deny permissions
    if($AccessType -eq "Deny"){
        foreach($rd in $PermissionAccounts){
            try{
                $tmp = Unblock-SmbShareAccess -Name $ShareName -AccountName $rd -Force -CimSession $Script:Cim -ErrorAction Stop      
                $Script:output += "Deny permissions removed for $($rd)"
            }
            catch
            {$Script:output +="Error remove deny permissions for $($rd) - $($_.Exception.Message)"}
        }
    } 
    
    $Script:output += Get-SmbShareAccess -Name $ShareName -CimSession $Script:Cim `
                    | Select-Object $Properties | Sort-Object AccessControlType,AccountName | Format-List    
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