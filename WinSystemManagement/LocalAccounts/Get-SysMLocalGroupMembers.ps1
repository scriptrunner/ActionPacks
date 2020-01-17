#Requires -Version 5.1

<#
.SYNOPSIS
    Gets members from a local group

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
    Specifies an name of security group

.Parameter SID
    Specifies an security ID (SID) of security group
 
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
    $Script:output
    [string[]]$Properties = @('Name','SID')
    
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){
        if($PSCmdlet.ParameterSetName  -eq "ByName"){
            $Script:output = Get-LocalGroupMember -Name $Name -ErrorAction Stop | Select-Object $Properties
        }
        else {
            $Script:output = Get-LocalGroupMember -SID $SID -ErrorAction Stop | Select-Object $Properties
        }
    }
    else {
        if($null -eq $AccessAccount){
            if($PSCmdlet.ParameterSetName  -eq "ByName"){
                $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Get-LocalGroupMember -Name $Using:Name | Select-Object $Using:Properties
                } -ErrorAction Stop
            }
            else {
                $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Get-LocalGroupMember -SID $Using:SID | Select-Object $Using:Properties
                } -ErrorAction Stop
            }
        }
        else {
            if($PSCmdlet.ParameterSetName  -eq "ByName"){
                $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    Get-LocalGroupMember -Name $Using:Name | Select-Object $Using:Properties
                } -ErrorAction Stop
            }
            else {
                $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    Get-LocalGroupMember -SID $Using:SID | Select-Object $Using:Properties
                } -ErrorAction Stop
            }
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
}