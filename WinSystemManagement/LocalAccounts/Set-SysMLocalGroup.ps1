#Requires -Version 5.1

<#
.SYNOPSIS
    Changes a local security group- 
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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/LocalAccounts

.Parameter Name
    Specifies an name of security group that changes

.Parameter SID
    Specifies an security ID (SID) of security group that changes

.Parameter Description
    Specifies a comment for the group. The maximum length is 48 characters    

.Parameter NewName
    Specifies a new name for the security group
 
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
    [string]$Description,     
    [Parameter(ParameterSetName = "ByName")]   
    [Parameter(ParameterSetName = "BySID")]  
    [string]$NewName,
    [Parameter(ParameterSetName = "ByName")]   
    [Parameter(ParameterSetName = "BySID")]     
    [string]$ComputerName,    
    [Parameter(ParameterSetName = "ByName")]   
    [Parameter(ParameterSetName = "BySID")]     
    [PSCredential]$AccessAccount
)

try{
    $Script:output
    [string[]]$Properties = @('Name','Description','SID')

    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){
        if($PSCmdlet.ParameterSetName  -eq "ByName"){
            if([System.String]::IsNullOrWhiteSpace($Description) -eq $false){
                $null = Set-LocalGroup -Name $Name -Description $Description -ErrorAction Stop
            }
            if([System.String]::IsNullOrWhiteSpace($NewName) -eq $false){
                $null = Rename-LocalGroup -Name $Name -NewName $NewName -ErrorAction Stop
                $Name = $NewName
            }
            $Script:output = Get-LocalGroup -Name $Name -ErrorAction Stop | Select-Object $Properties
        }
        else {
            if([System.String]::IsNullOrWhiteSpace($Description) -eq $false){
                $null = Set-LocalGroup -SID $SID -Description $Description -ErrorAction Stop
            }
            if([System.String]::IsNullOrWhiteSpace($NewName) -eq $false){
                $null = Rename-LocalGroup -SID $SID -NewName $NewName -ErrorAction Stop
            }
            $Script:output = Get-LocalGroup -SID $SID -ErrorAction Stop | Select-Object $Properties
        }
    }
    else {
        if($null -eq $AccessAccount){
            if($PSCmdlet.ParameterSetName  -eq "ByName"){
                if([System.String]::IsNullOrWhiteSpace($Description) -eq $false){
                    Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                        $null = Set-LocalGroup -Name $Using:Name -Description $Using:Description -ErrorAction Stop
                    } -ErrorAction Stop
                }
                if([System.String]::IsNullOrWhiteSpace($NewName) -eq $false){
                    Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                        $null = Rename-LocalGroup -Name $Using:Name -NewName $Using:NewName -ErrorAction Stop
                    } -ErrorAction Stop
                    $Name = $NewName
                }
                $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Get-LocalGroup -Name $Using:Name -ErrorAction Stop | Select-Object $Using:Properties
                } -ErrorAction Stop
            }
            else {
                if([System.String]::IsNullOrWhiteSpace($Description) -eq $false){
                    Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                        $null = Set-LocalGroup -SID $Using:SID -Description $Using:Description -ErrorAction Stop
                    } -ErrorAction Stop
                }
                if([System.String]::IsNullOrWhiteSpace($NewName) -eq $false){
                    Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                        $null = Rename-LocalGroup -SID $Using:SID -NewName $Using:NewName -ErrorAction Stop
                    } -ErrorAction Stop
                }
                $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Get-LocalGroup -SID $Using:SID -ErrorAction Stop | Select-Object $Using:Properties
                } -ErrorAction Stop
            }
        }
        else {
            if($PSCmdlet.ParameterSetName  -eq "ByName"){
                if([System.String]::IsNullOrWhiteSpace($Description) -eq $false){
                    Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                        $null = Set-LocalGroup -Name $Using:Name -Description $Using:Description -ErrorAction Stop
                    } -ErrorAction Stop
                } 
                if([System.String]::IsNullOrWhiteSpace($NewName) -eq $false){
                    Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                        $null = Rename-LocalGroup -Name $Using:Name -NewName $Using:NewName -ErrorAction Stop
                    } -ErrorAction Stop
                    $Name = $NewName
                }
                $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    Get-LocalGroup -Name $Using:Name -ErrorAction Stop | Select-Object $Using:Properties
                } -ErrorAction Stop
            }
            else {
                if([System.String]::IsNullOrWhiteSpace($Description) -eq $false){
                    Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                        $null = Set-LocalGroup -SID $Using:SID -Description $Using:Description -ErrorAction Stop
                    } -ErrorAction Stop
                }
                if([System.String]::IsNullOrWhiteSpace($NewName) -eq $false){
                    Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                        $null = Rename-LocalGroup -SID $Using:SID -NewName $Using:NewName -ErrorAction Stop
                    } -ErrorAction Stop
                }
                $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    Get-LocalGroup -SID $Using:SID -ErrorAction Stop | Select-Object $Using:Properties
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