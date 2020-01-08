#Requires -Version 5.1

<#
.SYNOPSIS
    Removes a local security group

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/LocalAccounts

.Parameter Name
    Specifies an name of security group that deletes

.Parameter SID
    Specifies an security ID (SID) of security group that deletes
 
.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true, ParameterSetName = "ByName")]    
    [string]$Name,
    [Parameter(Mandatory = $true, ParameterSetName = "BySID")]    
    [string]$SID,
    [Parameter(ParameterSetName = "ByName")]   
    [Parameter(ParameterSetName = "BySID")]     
    [string]$ComputerName,    
    [Parameter(ParameterSetName = "ByName")]   
    [Parameter(ParameterSetName = "BySID")]     
    [PSCredential]$AccessAccount
)

try{
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){
        if($PSCmdlet.ParameterSetName  -eq "ByName"){
            $null = Remove-LocalGroup -Name $Name -Confirm:$false -ErrorAction Stop
        }
        else {
            $null = Remove-LocalGroup -SID $SID -Confirm:$false -ErrorAction Stop
        }
    }
    else {
        if($null -eq $AccessAccount){
            if($PSCmdlet.ParameterSetName  -eq "ByName"){
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    $null = Remove-LocalGroup -Name $Using:Name -Confirm:$false -ErrorAction Stop
                } -ErrorAction Stop
            }
            else {
                Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    $null = Remove-LocalGroup -SID $Using:SID -Confirm:$false -ErrorAction Stop
                } -ErrorAction Stop
            }
        }
        else {
            if($PSCmdlet.ParameterSetName  -eq "ByName"){
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    $null = Remove-LocalGroup -Name $Using:Name -Confirm:$false
                } -ErrorAction Stop
            }
            else {
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    $null = Remove-LocalGroup -SID $Using:SID -Confirm:$false -ErrorAction Stop
                } -ErrorAction Stop
            }
        }
    }          

    if($SRXEnv) {
        if($PSCmdlet.ParameterSetName  -eq "ByName"){
            $SRXEnv.ResultMessage = "Group: $($Name) removed"
        }
        else {
            $SRXEnv.ResultMessage = "Group: $($SID) removed"
        }
    }
    else{
        if($PSCmdlet.ParameterSetName  -eq "ByName"){
            Write-Output "Group: $($Name) removed"
        }
        else {
            Write-Output "Group: $($SID) removed"
        }
    }
}
catch{
    throw
}
finally{
}