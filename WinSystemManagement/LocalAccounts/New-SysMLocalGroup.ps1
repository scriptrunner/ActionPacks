#Requires -Version 5.1

<#
.SYNOPSIS
    Creates a local security group

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
    Specifies a name for the group. The maximum length is 256 characters

.Parameter Description
    Specifies a comment for the group. The maximum length is 48 characters
 
.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory = $true)]    
    [string]$Name,
    [string]$Description,
    [string]$ComputerName,
    [PSCredential]$AccessAccount
)

try{
    $Script:output
    [string[]]$Properties = @('Name','Description','SID')    
    if([System.String]::IsNullOrWhiteSpace($Description)){
        $Description = ' '
    }

    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){
        $null = New-LocalGroup -Name $Name -Description $Description -Confirm:$false -ErrorAction Stop
        $Script:output = Get-LocalGroup -Name $Name -ErrorAction Stop | Select-Object $Properties
    }
    else {
        if($null -eq $AccessAccount){
            $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                $null = New-LocalGroup -Name $Using:Name -Description $Using:Description -Confirm:$false -ErrorAction Stop;
                Get-LocalGroup -Name $Using:Name -ErrorAction Stop | Select-Object $Using:Properties
            } -ErrorAction Stop
        }
        else {
            $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                $null = New-LocalGroup -Name $Using:Name -Description $Using:Description -Confirm:$false -ErrorAction Stop;
                Get-LocalGroup -Name $Using:Name -ErrorAction Stop | Select-Object $Using:Properties
            } -ErrorAction Stop
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