#Requires -Version 4.0

<#
.SYNOPSIS
    Retrieves the share properties on the computer

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

.Parameter ComputerName
    Specifies the name of the computer from which to retrieve the share
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter Properties
    List of properties to expand, comma separated e.g. Name,Description. Use * for all properties
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$ShareName,
    [string]$ComputerName,
    [PSCredential]$AccessAccount,
    [ValidateSet('*','Name','Description','Path','ShareState','ScopeName','CurrentUsers','ShareType','AvailabilityType')]
    [string[]]$Properties = @('Name','Description','Path','ShareState','ScopeName','CurrentUsers','ShareType','AvailabilityType')
)

$Script:Cim = $null
try{
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    else{
        if($null -eq ($Properties | Where-Object {$_ -eq 'Name'})){
            $Properties += "Name"
        }
    }
    
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName=[System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim =New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim =New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }
    $objShare = Get-SmbShare -Name $ShareName -CimSession $Script:Cim -IncludeHidden -ErrorAction Stop `
                            | Select-Object $Properties | Where-Object {$_.ShareType -eq 'FileSystemDirectory'} | Sort-Object Name | Format-List    

    if($SRXEnv) {
        $SRXEnv.ResultMessage = $objShare
    }
    else{
        Write-Output $objShare
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