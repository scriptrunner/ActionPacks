#Requires -Version 4.0

<#
.SYNOPSIS
    Modifies the properties of the share.
    Only parameters with value are set

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
    Specifies the name of the computer from which to change the share
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter Description
    Specifies an optional description of the share

.Parameter EncryptData
    Indicates whether the share is encrypted
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [string]$ShareName,
    [string]$ComputerName,
    [PSCredential]$AccessAccount,
    [string]$Description,
    [bool]$EncryptData
)

$Script:Cim = $null
[string[]]$Properties = @('Name','Description','Path','ShareState','ScopeName','CurrentUsers','ShareType','AvailabilityType','EncryptData')
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

    $Script:Share = Get-SmbShare -Name $ShareName -CimSession $Script:Cim -IncludeHidden -ErrorAction Stop | Select-Object *
    if($null -ne $Script:Share){
        if($PSBoundParameters.ContainsKey('Description') -eq $true ){
            $null = Set-SmbShare -Name $ShareName -CimSession $Script:Cim -Description $Description -Force -ErrorAction Stop
        }
        if($PSBoundParameters.ContainsKey('EncryptData') -eq $true ){
            $null = Set-SmbShare -Name $ShareName -CimSession $Script:Cim -EncryptData $EncryptData -Force -ErrorAction Stop
        }
        $Script:Share = Get-SmbShare -Name $ShareName -CimSession $Script:Cim -IncludeHidden -ErrorAction Stop `
                        | Select-Object $Properties
    }  
      
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:Share
    }
    else{
        Write-Output $Script:Share
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