#Requires -Version 4.0

<#
.SYNOPSIS
    Gets all processes that are running on the local computer or a remote computer

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinClientManagement/_QUERY_

.Parameter ComputerName
    Gets the active processes on the specified computer. The default is the local computer

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action
#>

[CmdLetBinding()]
Param(
    [string]$ComputerName,
    [PSCredential]$AccessAccount
)

try{    
    if($SRXEnv) {
        $SRXEnv.ResultList =@()
        $SRXEnv.ResultList2 =@()
    }
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $false){
        if($null -eq $AccessAccount){
            $Script:processes = Invoke-Command -ComputerName $ComputerName -ScriptBlock{ 
                Get-Process -IncludeUserName | Select-Object ID,ProcessName,UserName| Sort-Object -Property ProcessName }
        }
        else {
            $Script:processes = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{ 
                Get-Process -IncludeUserName | Select-Object ID,ProcessName,UserName| Sort-Object -Property ProcessName }
        }
    }
    else {
        $Script:processes = Get-Process -IncludeUserName | Select-Object ID,ProcessName,UserName| Sort-Object -Property ProcessName
    }
    foreach($item in $Script:processes)
    {
        if($SRXEnv) {
            $SRXEnv.ResultList += $item.Id.toString()
            $SRXEnv.ResultList2 += "$($item.ProcessName) ($($UserName))" # Display
        }
        else{
            Write-Output "$($item.ProcessName) ($($UserName))"
        }
    }
}
catch{
    throw
}
finally{
}