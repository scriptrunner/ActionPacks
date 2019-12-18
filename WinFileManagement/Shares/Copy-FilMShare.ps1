#Requires -Version 4.0

<#
.SYNOPSIS
    Copies a share with permissions on the computer. 
    The share properties Description, ScopeName and EncryptData are copied

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

.Parameter SourceShareName
    Specifies the name of the share

.Parameter TargetShareName
    Specifies the name of the new share

.Parameter Path
    Specifies the path of the location of the folder to share. If the parameter is empty, the share is set to the source path

.Parameter ComputerName
    Specifies the name of the computer from which to rename the share
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$SourceShareName,
    [Parameter(Mandatory = $true)]
    [string]$TargetShareName,
    [string]$Path,
    [string]$ComputerName,
    [PSCredential]$AccessAccount
)

$Script:Cim = $null
$Script:output = @()
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
    $Script:Share =Get-SmbShare -Name $SourceShareName -CimSession $Script:Cim -IncludeHidden `
                    | Select-Object * | Where-Object {$_.ShareType -eq 'FileSystemDirectory'}    
    if($null -ne $Script:Share){
        if([System.String]::IsNullOrWhiteSpace($Path)){
            $Path = $Script:Share.Path
        }
        $tmp = New-SmbShare -CimSession $Script:Cim -Name $TargetShareName -Path $Path -Description $Script:Share.Description `
                            -ScopeName $Script:Share.ScopeName -EncryptData $Script:Share.EncryptData -ErrorAction Stop
        $Script:output += "$($SourceShareName) successfully copied to $($TargetShareName)"
        # Allow rights
        $rights= Get-SmbShareAccess -Name $SourceShareName -CimSession $Script:Cim `
                 | Where-Object {$_.AccessControlType -eq "Allow"} | Select-Object AccountName,AccessRight                                    
        foreach($item in $rights){
            try{
                $tmp = Grant-SmbShareAccess -Name $TargetShareName -AccountName $item.AccountName `
                         -AccessRight $item.AccessRight -Force -CimSession $Script:Cim -ErrorAction Stop      
                $Script:output += "Set allow access $($item.AccessRight) set for $($item.AccountName) on $($TargetShareName)"
            }
            catch
            {$Script:output +="Error allow access $($item.AccessRight) set for $($item.AccountName) on $($TargetShareName)"}
        }
        # Deny rights
        $rights= Get-SmbShareAccess -Name $SourceShareName -CimSession $Script:Cim `
                | Where-Object {$_.AccessControlType -eq "Deny"} | Select-Object AccountName                                    
        foreach($item in $rights){
            try{
                $tmp = Block-SmbShareAccess -Name $TargetShareName -AccountName $item.AccountName `
                         -Force -CimSession $Script:Cim -ErrorAction Stop      
                $Script:output += "Set deny access for $($item.AccountName) on $($TargetShareName)"
            }
            catch
            {$Script:output +="Error deny access set for $($item.AccountName) on $($TargetShareName)"}
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
    if($null -ne $Script:Cim){
        Remove-CimSession $Script:Cim 
    }
}