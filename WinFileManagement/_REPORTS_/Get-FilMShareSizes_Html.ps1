#Requires -Version 4.0

<#
.SYNOPSIS
    Generates a report with the sizes of all shares

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT    
    Requires Library Script ReportLibrary from the Action Pack Reporting\_LIB_

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinFileManagement/_REPORTS_

.Parameter SpecialShares
    Indicates that the shares to be numerated should be special. Admin share, default shares, IPC$ share are examples of special shares

.Parameter IncludeHidden
    Indicates that shares that are created and used internally are also enumerated

.Parameter ComputerName
    Specifies the name of the computer from which to retrieve the printer information
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [bool]$SpecialShares,
    [switch]$IncludeHidden,
    [string]$ComputerName,
    [PSCredential]$AccessAccount

)

$Script:output = @()
$Script:Cim = $null
try{
    if([System.string]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName = [System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim = New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }

    $objShares = Get-SmbShare -CimSession $Script:Cim -IncludeHidden:$IncludeHidden -Special $SpecialShares -ErrorAction Stop  `
                            | Select-Object Path,Name,ShareType | Where-Object {$_.ShareType -eq 'FileSystemDirectory'} | Sort-Object Name 
    foreach($share in $objShares){
        $childs = Get-ChildItem -Path $share.Path -Force -Recurse | Measure-Object -Property Length -Sum
        $size = $childs.Sum
        if($null -eq $size){
            $size = "0"
        }        
        $Script:output += [PSCustomObject] @{
                    Share = $share.Name;
                    'Size (MB)' = ([math]::round($size/1MB, 3));
                    Path = $share.Path
        }
    }    
                                
    ConvertTo-ResultHtml -Result $Script:output
}
catch{
    throw
}
finally{
    if($null -ne $Script:Cim){
        Remove-CimSession $Script:Cim 
    }
}