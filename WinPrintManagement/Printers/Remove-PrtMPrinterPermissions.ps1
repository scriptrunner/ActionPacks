#Requires -Version 4.0
#Requires -Modules PrintManagement

<#
.SYNOPSIS
    Removes the permissions from the printer from the specified computer

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
    Specifies the name of the printer for which to remove the permissions

.Parameter ComputerName
    Specifies the name of the computer on which the printer is installed

.Parameter AccessAccount
    Specifies a user account that has permission to perform this action. If Credential is not specified, the executing account is used.

.Parameter ADMembers
    SamAccountName or user principal name (UPN) of the users and groups to remove the permission from the specified printer. Use the comma to separate the members

.Parameter Permission
    Specifies the permission for the specified printer

.Parameter ADMembers
    SamAccountName or user principal name (UPN) of the users and groups to remove the permission from the specified printer. Use the comma to separate the members

.Parameter PrintPermissionMembers
    SamAccountName or user principal name (UPN) of the users and groups to remove the print permission from the specified printer. Use the comma to separate the members

.Parameter ManagePrinterPermissionMembers
    SamAccountName or user principal name (UPN) of the users and groups to remove the manage printer permission from the specified printer. Use the comma to separate the members

.Parameter ManageDocumentsPermissionMembers
    SamAccountName or user principal name (UPN) of the users and groups to remove the manage documents permission from the specified printer. Use the comma to separate the members

.Parameter ReadPermissionMembers
    SamAccountName or user principal name (UPN) of the users and groups to remove the read permissions permission from the specified printer. Use the comma to separate the members

.Parameter ChangePermissionMembers
    SamAccountName or user principal name (UPN) of the users and groups to remove the change permissions permission from the specified printer. Use the comma to separate the members

.Parameter TakeownershipPermissionMembers
    SamAccountName or user principal name (UPN) of the users and groups to remove the takeownership permission from the specified printer. Use the comma to separate the members

#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory=$true,ParameterSetName='Single permission')]
    [Parameter(Mandatory=$true,ParameterSetName='Multiple permissions')]
    [string]$PrinterName,
    [Parameter(ParameterSetName='Single permission')]
    [Parameter(ParameterSetName='Multiple permissions')]
    [string]$ComputerName,
    [Parameter(ParameterSetName='Single permission')]
    [Parameter(ParameterSetName='Multiple permissions')]
    [PSCredential]$AccessAccount,
    [Parameter(Mandatory=$true,ParameterSetName='Single permission')]
    [string]$ADMembers,
    [Parameter(Mandatory=$true,ParameterSetName='Single permission')]
    [ValidateSet('Print','ManagePrinter','ManageDocuments','ReadPermissions','ChangePermissions', 'Takeownership')]
    [string]$Permission='Print',
    [Parameter(ParameterSetName='Multiple permissions')]
    [string]$PrintPermissionMembers,
    [Parameter(ParameterSetName='Multiple permissions')]
    [string]$ManagePrinterPermissionMembers,
    [Parameter(ParameterSetName='Multiple permissions')]
    [string]$ManageDocumentsPermissionMembers,
    [Parameter(ParameterSetName='Multiple permissions')]
    [string]$ReadPermissionMembers,
    [Parameter(ParameterSetName='Multiple permissions')]
    [string]$ChangePermissionMembers,
    [Parameter(ParameterSetName='Multiple permissions')]
    [string]$TakeownershipPermissionMembers
)

Import-Module PrintManagement

$Script:Cim = $null
$Script:output = @()
try{
    function SetAceID(){
        $Script:AceValue = 0
        if($Permission -eq "Takeownership" ){
            $Script:AceValue =  524288
        }
        elseif($Permission -eq "ReadPermissions"){
            $Script:AceValue =131072
        }
        elseif($Permission -eq "ChangePermissions" ){
            $Script:AceValue =262144
        }
        elseif($Permission -eq "ManagePrinter" ){
            $Script:AceValue = 851972
        }
        elseif($Permission -eq "ManageDocuments"){
            $Script:AceValue = 983088
        }
        elseif($Permission -eq  "Print"){
            $Script:AceValue =131080
        }
    <#    elseif($Permission -eq  "FullControl"){
            $Script:AceValue =268435456
        }   #>
    }

    function RemoveAccess([string]$Member){
        try{
            $acc = New-Object Security.Principal.NTAccount($Member)
            $mbr =$acc.Translate([Security.Principal.SecurityIdentifier]).Value
            if($null -ne $mbr -and $Script:AceValue -gt 0){
                if($Script:AceValue -eq 983088){
                    $Script:secDesc.DiscretionaryAcl.RemoveAccess([System.Security.AccessControl.AccessControlType]::Allow,
                    $mbr,983088,
                    [System.Security.AccessControl.InheritanceFlags]::ObjectInherit,[System.Security.AccessControl.PropagationFlags]::InheritOnly) | Out-Null
                }
                else{
                    $Script:secDesc.DiscretionaryAcl.RemoveAccess([System.Security.AccessControl.AccessControlType]::Allow,
                    $mbr,$Script:AceValue,
                    [System.Security.AccessControl.InheritanceFlags]::None, [System.Security.AccessControl.PropagationFlags]::None) | Out-Null
                }
            }
            $Script:output += "Permission $($Permission) for Member:$($Member) removed"
        }
        catch{
            $Script:output += "Error: Remove Permission $($Permission) for Member:$($Member) - $($_.Exception.Message)"
        }
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
    $Script:Printer = Get-Printer -Name $PrinterName -ComputerName $ComputerName -CimSession $Script:Cim -Full -ErrorAction Stop
    if($null -ne $Script:Printer){
        $Script:secDesc = New-Object -TypeName Security.AccessControl.CommonSecurityDescriptor ($true, $false, $Script:Printer.PermissionSDDL)
        if($PSCmdlet.ParameterSetName  -eq "Single permission"){
            SetAceID           
            foreach($item in $ADMembers.Split(',') ){
                RemoveAccess $item.Trim()
            }
        }
        else{
            if($null -ne $PrintPermissionMembers -and $PrintPermissionMembers.Length -gt 0){
                $Permission ='Print'
                SetAceID           
                foreach($item in $PrintPermissionMembers.Split(',') ){
                    RemoveAccess $item.Trim()
                }
            }
            if($null -ne $ManagePrinterPermissionMembers -and $ManagePrinterPermissionMembers.Length -gt 0){
                $Permission ='ManagePrinter'
                SetAceID           
                foreach($item in $ManagePrinterPermissionMembers.Split(',') ){
                    RemoveAccess $item.Trim()
                }
            }
            if($null -ne $ManageDocumentsPermissionMembers -and $ManageDocumentsPermissionMembers.Length -gt 0){
                $Permission ='ManageDocuments'
                SetAceID           
                foreach($item in $ManageDocumentsPermissionMembers.Split(',') ){
                    RemoveAccess $item.Trim()
                }
            }
            if($null -ne $ReadPermissionMembers -and $ReadPermissionMembers.Length -gt 0){
                $Permission ='ReadPermissions'
                SetAceID           
                foreach($item in $ReadPermissionMembers.Split(',') ){
                    RemoveAccess $item.Trim()
                }
            }
            if($null -ne $ChangePermissionMembers -and $ChangePermissionMembers.Length -gt 0){
                $Permission ='ChangePermissions'
                SetAceID           
                foreach($item in $ChangePermissionMembers.Split(',') ){
                    RemoveAccess $item.Trim()
                }
            }
            if($null -ne $TakeownershipPermissionMembers -and $TakeownershipPermissionMembers.Length -gt 0){
                $Permission ='Takeownership'
                SetAceID           
                foreach($item in $TakeownershipPermissionMembers.Split(',') ){
                    RemoveAccess $item.Trim()
                }
            }
        }
        $Script:done = $false
        $perms = $Script:secDesc.GetSddlForm('All') 
        try{
            $null = Set-Printer -CimSession $Script:Cim -Name $PrinterName -ComputerName $ComputerName -PermissionSDDL $perms -ErrorAction Stop
            $Script:done = $true
        }
        catch{
            # Problems with print server W2k16
        }
        if($Script:done -eq $false){
            $prn = $PrinterName
            $cmd = { Set-Printer -Name $Using:prn -PermissionSDDL $Using:perms }
            if($null -eq $AccessAccount){
                Invoke-Command -ComputerName $ComputerName -validateset $cmd -ErrorAction Stop
            }
            else{
                Invoke-Command -ComputerName $ComputerName -Credential $AccessAccount -ScriptBlock $cmd -ErrorAction Stop
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
    if($null -ne $Script:Cim){
        Remove-CimSession $Script:Cim 
    }
}