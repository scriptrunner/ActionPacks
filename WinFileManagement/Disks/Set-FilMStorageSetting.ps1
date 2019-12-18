#Requires -Version 4.0

<#
.SYNOPSIS
    Adjusts or configures current storage settings of the StorageSetting object

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinFileManagement/Disks

.Parameter NewDiskPolicy
    Manages the policy that will be applied to newly attached disks

.Parameter ScrubPolicy
    Specifies the policy for the files that the automatic data integrity scanner scrubs    

.Parameter ComputerName
    Specifies the name of the computer from which to retrieve the storage setting informations. If Computername is not specified, the current computer is used.
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [ValidateSet("None", "OnlineAll", "OfflineShared", "OfflineAll", "OfflineInternal")]
    [string]$NewDiskPolicy = "OfflineShared",
    [ValidateSet("None", "Off", "IntegrityStreams", "All")]
    [string]$ScrubPolicy = "IntegrityStreams",
    [string]$ComputerName,
    [PSCredential]$AccessAccount
)

$Script:Cim = $null
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
    if(($PSBoundParameters.ContainsKey('NewDiskPolicy') -eq $true) -and ($NewDiskPolicy -ne "None")){
        $null = Set-StorageSetting -CimSession $Script:Cim -NewDiskPolicy $NewDiskPolicy -ErrorAction Stop
    }
    if(($PSBoundParameters.ContainsKey('ScrubPolicy') -eq $true) -and ($ScrubPolicy -ne "None")){
        $null = Set-StorageSetting -CimSession $Script:Cim -ScrubPolicy $ScrubPolicy -ErrorAction Stop
    }   

    $result = Get-StorageSetting -CimSession $Script:Cim -ErrorAction Stop | Select-Object *
    if($SRXEnv) {
        $SRXEnv.ResultMessage =$result
    }
    else{
        Write-Output $result
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