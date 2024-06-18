#Requires -Version 5.0

<#
.SYNOPSIS
    Retrieves the shares on the computer

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinFileManagement/_QUERY_

.Parameter ComputerName
    [sr-en] Name of the computer from which to retrieve the shares
    
.Parameter AccessAccount
    [sr-en] User account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter SpecialShares
    [sr-en] Shares to be numerated should be special. Admin share, default shares, IPC$ share are examples of special shares

.Parameter IncludeHidden
    [sr-en] Shares that are created and used internally are also enumerated
#>

[CmdLetBinding()]
Param(
    [string]$ComputerName,
    [PSCredential]$AccessAccount,
    [bool]$SpecialShares,
    [switch]$IncludeHidden
)

$Script:Cim=$null
try{
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName=[System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim =New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim =New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }
    $Script:Shares =Get-SmbShare -CimSession $Script:Cim -IncludeHidden:$IncludeHidden -Special $SpecialShares -ErrorAction Stop  `
                            | Select-Object @("Name","Description","Path","ShareType") | Where-Object {$_.ShareType -eq 'FileSystemDirectory'} | Sort-Object Name
    
    foreach($item in $Script:Shares){
        if($SRXEnv) {
            $null = $SRXEnv.ResultList.Add($item.Name) # Value
            $null = $SRXEnv.ResultList2.Add($item.Path) # Display
        }
        else{
            Write-Output $item.Name
        }
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