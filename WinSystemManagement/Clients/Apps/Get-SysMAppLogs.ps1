#Requires -Version 4.0

<#
.SYNOPSIS
    Gets an app package installation log

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/Clients/Apps
 
.Parameter ActivityID
    Specifies an activity ID

.Parameter ResultItems
    Limit the number of the last logs

.Parameter Properties
    List of properties to expand, comma separated e.g. ID,UserID. Use * for all properties

.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [string]$ActivityID,
    [VaildateSet('*','Id','UserID','TimeCreated','ActivityId','LevelDisplayName')]
    [string[]]$Properties = @('Id','UserID','TimeCreated','ActivityId','LevelDisplayName'),
    [ValidateRange(1,100)]
    [int]$ResultItems = 20,
    [string]$ComputerName,    
    [PSCredential]$AccessAccount
)

try{
    $Script:output    
    if($Properties -contains '*'){
        $Properties = @('*')
    }
    
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){
        if([System.String]::IsNullOrWhiteSpace($ActivityID) -eq $true){
            $Script:output = Get-AppxLog -All -ErrorAction Stop | Select-Object $Properties -Last $ResultItems
        }
        else{
            $Script:output = Get-AppxLog -ActivityId $ActivityID -ErrorAction Stop | Select-Object $Properties
        }
    }
    else {
        if($null -eq $AccessAccount){
            if([System.String]::IsNullOrWhiteSpace($ActivityID) -eq $true){
                $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Get-AppxLog -All -ErrorAction Stop | Select-Object $Using:Properties -Last $Using:ResultItems
                } -ErrorAction Stop
            }
            else{
                $Script:output = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                    Get-AppxLog -ActivityId $Using:ActivityID -ErrorAction Stop | Select-Object $Using:Properties -Last $Using:ResultItems
                } -ErrorAction Stop
            }
        }
        else {
            if([System.String]::IsNullOrWhiteSpace($ActivityID) -eq $true){
                $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    Get-AppxLog -All -ErrorAction Stop | Select-Object $Using:Properties -Last $Using:ResultItems
                } -ErrorAction Stop
            }
            else{
                $Script:output = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                    Get-AppxLog -ActivityId $Using:ActivityID -ErrorAction Stop | Select-Object $Using:Properties -Last $Using:ResultItems
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