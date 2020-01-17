#Requires -Version 5.1

<#
.SYNOPSIS
    Removes members from a local group

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

.Parameter Members
    Specifies, comma separated, the users or groups that removes from the security group
 
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
    [string]$Members,    
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
    [string[]]$tmpMembers = $Members.Split(",")

    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){
        if($PSCmdlet.ParameterSetName  -eq "ByName"){
            $Script:grp = Get-LocalGroup -Name $Name
        }
        else {
            $Script:grp = Get-LocalGroup -SID $SID
        }
        $null = Remove-LocalGroupMember -Group $Script:grp -Member $tmpMembers -ErrorAction Stop
        $Script:output = Get-LocalGroupMember -Group $Script:grp -ErrorAction Stop | Select-Object $Properties
    }
    else {
        if($null -eq $AccessAccount){
            if($PSCmdlet.ParameterSetName  -eq "ByName"){
                $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    $null = Remove-LocalGroupMember -Name $Using:Name -Member $Using:tmpMembers -ErrorAction Stop;
                    Get-LocalGroupMember -Name $Using:Name -ErrorAction Stop | Select-Object $Using:Properties
                } -ErrorAction Stop
            }
            else {
                $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    $null = Remove-LocalGroupMember -SID $Using:SID -Member $Using:tmpMembers -ErrorAction Stop;
                    Get-LocalGroupMember -SID $Using:SID -ErrorAction Stop | Select-Object $Using:Properties
                } -ErrorAction Stop
            }
        }
        else {
            if($PSCmdlet.ParameterSetName  -eq "ByName"){
                $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    $null = Remove-LocalGroupMember -Name $Using:Name -Member $Using:tmpMembers -ErrorAction Stop;
                    Get-LocalGroupMember -Name $Using:Name -ErrorAction Stop | Select-Object $Using:Properties
                } -ErrorAction Stop
            }
            else {
                $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    $null = Remove-LocalGroupMember -SID $Using:SID -Member $Using:tmpMembers -ErrorAction Stop;
                    Get-LocalGroupMember -SID $Using:SID -ErrorAction Stop | Select-Object $Using:Properties
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