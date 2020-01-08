#Requires -Version 4.0

<#
    .SYNOPSIS
        Lists the Active Directory user profiles on the computer
    
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
                
    .Parameter ComputerName
        Specifies the computer from which the profiles are listed
                
    .Parameter AccessAccount
        Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used
#>

param(
    [string]$ComputerName,
    [pscredential]$AccessAccount
)

$Script:Cim= $null
try{
    if([System.string]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName = [System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim = New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }
    $profiles = Get-CimInstance -CimSession $Script:Cim -ClassName Win32_UserProfile -ErrorAction Stop `
                                | Where-Object{$_.Special -eq $false} | Select-Object LastUseTime,SID

    foreach($itm in $profiles){
        $sid = $itm.SID
        $usr = Get-ADUser -Filter{SID -eq $sid} -Properties Name | Sort-Object Name
        if([System.String]::IsNullOrWhiteSpace($usr.Name) -eq $false){
            if($SRXEnv) {            
                $null =  $SRXEnv.ResultList.Add($sid) # Value
                $null = $SRXEnv.ResultList2.Add("$($usr.Name) - last use $($itm.LastUseTime)") # DisplayValue            
            }
            else{
                Write-Output "$($usr.Name) - last use $($itm.LastUseTime)"
            }
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