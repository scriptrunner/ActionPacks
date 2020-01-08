#Requires -Version 4.0

<#
.SYNOPSIS
    Gets the restore points on the computer

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
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/_QUERY_
 
.Parameter ComputerName
    Specifies an remote computer, if the name empty the local computer is used

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [string]$ComputerName,    
    [PSCredential]$AccessAccount
)

try{
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){
        $Script:result = Get-ComputerRestorePoint -ErrorAction Stop | Select-Object @("Description","SequenceNumber")
    }
    else {
        if($null -eq $AccessAccount){
            $Script:result = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                Get-ComputerRestorePoint -ErrorAction Stop | Select-Object @("Description","SequenceNumber")  | Sort-Object Description
            } -ErrorAction Stop
        }
        else {
            $Script:result = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                Get-ComputerRestorePoint -ErrorAction Stop | Select-Object @("Description","SequenceNumber")  | Sort-Object Description
            } -ErrorAction Stop
        }
    }      
    foreach($item in $Script:result)
    {
        if($SRXEnv) {
            $null = $SRXEnv.ResultList.Add($item.SequenceNumber.toString())
            $null = $SRXEnv.ResultList2.Add($item.Description) # Display
        }
        else{
            Write-Output $item.Description
        }
    }
}
catch{
    throw
}
finally{
}