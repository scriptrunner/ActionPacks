#Requires -Version 4.0

<#
.SYNOPSIS
    Retrieves the shares on the computer

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, AppSphere AG assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of AppSphere AG.
    © AppSphere AG

.COMPONENT    

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinFileManagement/Shares

.Parameter ComputerName
    Specifies the name of the computer from which to retrieve the shares
    
.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.

.Parameter SpecialShares
    Indicates that the shares to be numerated should be special. Admin share, default shares, IPC$ share are examples of special shares

.Parameter IncludeHidden
    Indicates that shares that are created and used internally are also enumerated

.EXAMPLE

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
    if([System.String]::IsNullOrWhiteSpace($Properties) -or $Properties -eq '*'){
        $Properties=@('*')
    }
    else{
        if($null -eq ($Properties.Split(',') | Where-Object {$_ -eq 'Name'})){
            $Properties += ",Name"
        }
    }
    [string[]]$Script:props=$Properties.Replace(' ','').Split(',')
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
    if($SRXEnv) {
        $SRXEnv.ResultList =@()
        $SRXEnv.ResultList2 =@()
    }    
    foreach($item in $Script:Shares){
        if($SRXEnv) {
            $SRXEnv.ResultList += $item.Name # Value
            #$SRXEnv.ResultList2 += $item.Name # Value
            $SRXEnv.ResultList2 += $item.Path # Display
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