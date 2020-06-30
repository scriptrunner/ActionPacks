#Requires -Version 5.1

<#
.SYNOPSIS
    Generates a report with the memberships of a local user account

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Library Script ReportLibrary from the Action Pack Reporting\_LIB_

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/_REPORTS_

.Parameter Name
    Specifies the name of user account

.Parameter SID
    Specifies the security ID (SID) of user account
 
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
    $Script:output = @()
    
    if([System.String]::IsNullOrWhiteSpace($ComputerName) -eq $true){
        $groups = Get-LocalGroup -ErrorAction Stop | Select-Object -Property Name
        foreach($item in $groups){
            try{
                if($PSCmdlet.ParameterSetName  -eq "ByName"){
                    $user = Get-LocalGroupMember -Group $item -Member $Name -ErrorAction Ignore
                }
                else{
                    $user = Get-LocalGroupMember -Group $item -Member $SID -ErrorAction Ignore
                }
                if($null -ne $user){
                    $Script:output += [PSCustomObject]@{
                        Name = $item.Name;
                        SID = $item.SID.value
                    }
                }
            }
            catch{
            }
        }
    }
    else {
        if($null -eq $AccessAccount){
            $groups = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                Get-LocalGroup -ErrorAction Stop | Select-Object -Property Name,SID
            } -ErrorAction Stop
            foreach($item in $groups){
                try{
                    if($PSCmdlet.ParameterSetName -eq "ByName"){
                        $user = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                            $null = Get-LocalGroupMember -SID $Using:item.SID.Value -Member $Using:Name -ErrorAction Ignore
                        } -ErrorAction Ignore
                    }
                    else{
                        $user = Invoke-Command -ComputerName $ComputerName -ScriptBlock{
                            $null = Get-LocalGroupMember -SID $Using:item.SID.Value -Member $Using:SID -ErrorAction Ignore
                        } -ErrorAction Ignore
                    }
                    if($null -ne $user){
                        $Script:output += [PSCustomObject]@{
                            Name = $item.Name;
                            SID = $item.SID.value
                        }
                    }
                }
                catch{
                }
            }
        }
        else {
            $groups = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                Get-LocalGroup -ErrorAction Stop | Select-Object -Property Name,SID
            } -ErrorAction Stop
            foreach($item in $groups){
                try{
                    if($PSCmdlet.ParameterSetName -eq "ByName"){
                        $user = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                            $null = Get-LocalGroupMember -SID $Using:item.SID.Value -Member $Using:Name -ErrorAction Ignore
                        } -ErrorAction Ignore
                    }
                    else{
                        $user = Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock{
                            $null = Get-LocalGroupMember -SID $Using:item.SID.Value -Member $Using:SID -ErrorAction Ignore
                        } -ErrorAction Ignore
                    }
                    if($null -ne $user){
                        $Script:output += [PSCustomObject]@{
                            Name = $item.Name;
                            SID = $item.SID.value
                        }
                    }
                }
                catch{
                }
            }
        }
    }      
        
    ConvertTo-ResultHtml -Result $Script:output
}
catch{
    throw
}
finally{
}