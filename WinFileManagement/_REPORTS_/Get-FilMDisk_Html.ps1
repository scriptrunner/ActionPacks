#Requires -Version 4.0

<#
.SYNOPSIS
    Generates a report with one or more disks

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

.Parameter FriendlyName
    Gets the disk with the specified friendly name. If the parameter is empty, all disks are retrieved

.Parameter Number
    Specifies the disk number for which to get the associated Disk object. If the parameter less than 0, all disks are retrieved

.Parameter ComputerName
    Specifies the name of the computer from which to retrieve the disk informations. If Computername is not specified, the current computer is used.
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [string]$FriendlyName,
    [int]$Number = -1,
    [string]$ComputerName,
    [PSCredential]$AccessAccount
)

$Script:Cim=$null
try{ 
    [string[]]$Script:Properties = @('Number','FriendlyName','Size','AllocatedSize','IsBoot','IsSystem')
    if([System.String]::IsNullOrWhiteSpace($FriendlyName)){
        $FriendlyName= "*"
    }
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName = [System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim = New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }    
    [hashtable]$cmdArgs = @{'ErrorAction' = 'Stop'
                            'CimSession' = $Script:Cim
                            }
    if($Number -lt 0){
        $cmdArgs.Add('FriendlyName' ,$FriendlyName)
    }
    else{
        $cmdArgs.Add('Number' ,$Number)
    }
    $Script:output = @()
    Get-Disk @cmdArgs | Select-Object $Script:Properties | ForEach-Object{
        $Script:output += New-Object PSObject -Property (([ordered] @{ 
            Number = $_.Number
            FriendlyName = $_.FriendlyName
            'Total size (MB)' = ([math]::round($_.Size/1MB, 3))
            'Allocated size (MB)' = ([math]::round($_.AllocatedSize/1MB, 3))
            IsBoot = $_.IsBoot
            IsSystem = $_.IsSystem
        }))
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