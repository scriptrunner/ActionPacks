#Requires -Version 4.0

<#
.SYNOPSIS
    Adds permissions to the share

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
    Specifies the name of the share

.Parameter AccessType
    Specifies the access right to grant or denied to the trustee

.Parameter PermissionAccounts
    Specifies which accounts are granted or denied the permission to access the share. Multiple accounts can be specified comma separated

.Parameter ComputerName
    Specifies the name of the computer on which to set the share permissions
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$ShareName,
    [Parameter(Mandatory = $true)]
    [ValidateSet('Read','Modify','FullControlAccess','NoAccess')]
    [string]$AccessType="Read",
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
    # Change access
    if($AccessType -eq "Modify"){
        foreach($chn in $PermissionAccounts){
            try{
                $null = Grant-SmbShareAccess -Name $ShareName -AccountName $chn -AccessRight Change -Force -CimSession $Script:Cim -ErrorAction Stop      
                $Script:output += "Change access set for $($chn)"
            }
            catch
            {$Script:output +="Error set change access for $($chn) - $($_.Exception.Message)"}
        }
    } 
    # Read access
    if($AccessType -eq "Read"){
        foreach($rd in $PermissionAccounts){
            try{
                $null = Grant-SmbShareAccess -Name $ShareName -AccountName $rd -AccessRight Read -Force -CimSession $Script:Cim -ErrorAction Stop      
                $Script:output += "Read access set for $($rd)"
            }
            catch
            {$Script:output +="Error set read access for $($rd) - $($_.Exception.Message)"}
        }
    } 
    # Full access
    if($AccessType -eq "FullControlAccess"){
        foreach($fa in $PermissionAccounts){
            try{
                $null = Grant-SmbShareAccess -Name $ShareName -AccountName $fa -AccessRight Full -Force -CimSession $Script:Cim -ErrorAction Stop      
                $Script:output += "Full access set for $($fa)"
            }
            catch
            {$Script:output +="Error set full access for $($fa) - $($_.Exception.Message)"}
        }
    } 
    # No access
    if($AccessType -eq "NoAccess"){
        foreach($no in $PermissionAccounts){
            try{
                $null = Block-SmbShareAccess -Name $ShareName -AccountName $no -Force -CimSession $Script:Cim -ErrorAction Stop      
                $Script:output += "No access set for $($no)"
            }
            catch
            {$Script:output +="Error set no access for $($no) - $($_.Exception.Message)"}
        }
    } 

    $Script:output += Get-SmbShareAccess -Name $ShareName -CimSession $Script:Cim -ErrorAction Stop `
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