#Requires -Version 4.0
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Get the permissions of the printer from the specified computer

.DESCRIPTION
    
.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Module PrintManagement

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinPrintManagement/Printers

.Parameter PrinterName
    Specifies the name of the printer from which to retrieve the permissions

.Parameter ComputerName
    Specifies the name of the computer on which the printer is installed

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [string]$PrinterName,
    [string]$ComputerName,
    [PSCredential]$AccessAccount
)

Import-Module PrintManagement

$Script:Cim = $null
$Script:output = @()
try{
    function GetAceDescription([int] $mask){
        [string[]]$tmp = @()
        $Script:AceDesc = ''
        if(($mask -band 131080) -eq 131080){
            $tmp += "Print"
        }
        if(($mask -band 524288) -eq 524288){
            $tmp += "Takeownership"
        }
        if(($mask -band 131072) -eq 131072){
            $tmp += "ReadPermissions"
        }
        if(($mask -band 262144) -eq 262144){
            $tmp += "ChangePermissions"
        }
        if(($mask -band 983052) -eq 983052){
            $tmp += "ManagePrinters"
        }
        if(($mask -band 983088) -eq 983088){
            $tmp += "ManageDocuments"
        }
        if(($mask -band 268435456) -eq 268435456){
            $tmp += "Full control all operations"
        }   
        $Script:AceDesc =$tmp -join ","
    }

    if([System.string]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName = [System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim = New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }

    $printer = Get-Printer -Name $PrinterName -ComputerName $ComputerName -CimSession $Script:Cim -Full -ErrorAction Stop
    if($null -ne $printer){
        $secDesc = New-Object -TypeName Security.AccessControl.CommonSecurityDescriptor $true, $false, $printer.PermissionSDDL
        $secDesc.DiscretionaryAcl | ForEach-Object{
            GetAceDescription $_.AccessMask
            if(-not [System.string]::IsNullOrWhiteSpace($Script:AceDesc)){
                $objSID = New-Object System.Security.Principal.SecurityIdentifier ($_.SecurityIdentifier)         
                $user= $objSID.Translate( [System.Security.Principal.NTAccount])       
                $tmp= ([ordered] @{        
                    Prinzipal = $user.Value
                    AceQualifier= $_.AceQualifier
                    AceType = $_.AceType
                    AceFlags= $_.AceFlags
                    AccessMask= $Script:AceDesc
                }   )
                $Script:output += New-Object PSObject -Property $tmp
            }
        }
    }
    
    if($SRXEnv) {
        $SRXEnv.ResultMessage = $Script:output | Format-List 
    }
    else{
        Write-Output $Script:output | Format-List 
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