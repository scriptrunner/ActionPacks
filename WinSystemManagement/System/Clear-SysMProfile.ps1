#Requires -Version 5.0
#Requires -Modules ActiveDirectory

<#
    .SYNOPSIS
        Remove profile on computer
    
    .DESCRIPTION  

    .NOTES
        This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
        The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
        The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
        the use and the consequences of the use of this freely available script.
        PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
        © ScriptRunner Software GmbH

    .COMPONENT
        Requires Module ActiveDirectory
        Requires Library script SysMLibrary.ps1

    .LINK
        https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/System
                
    .Parameter ComputerName
        Specifies the computer from which the profile are removed
                
    .Parameter AccessAccount
        Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used
                
    .Parameter PreviousAction
        Action to be performed before remove the profile
                
    .Parameter PreviousServerProfileAction
        Action to be performed before remove the profile on server
                
    .Parameter UserName
        Specifies the name of the user whose profile should be removed
                
    .Parameter UserSID
        Specifies the SID of the user whose profile should be removed
#>

param( 
    [Parameter(Mandatory = $true,ParameterSetName = "BySID")]
    [Parameter(Mandatory = $true,ParameterSetName = "ByName")]
    [string]$ComputerName,
    [Parameter(Mandatory = $true,ParameterSetName = "BySID")]
    [string]$UserSID,
    [Parameter(Mandatory = $true,ParameterSetName = "ByName")]
    [string]$UserName,
    [Parameter(ParameterSetName = "BySID")]
    [Parameter(ParameterSetName = "ByName")]
    [pscredential]$AccessAccount,
    [Parameter(ParameterSetName = "BySID")]
    [Parameter(ParameterSetName = "ByName")]
    [ValidateSet('None','ZipProfile','Rename')]
    [string]$PreviousAction = 'ZipProfile',
    [Parameter(ParameterSetName = "BySID")]
    [Parameter(ParameterSetName = "ByName")]
    [ValidateSet('None','ZipProfile','Rename')]
    [string]$PreviousServerProfileAction = 'ZipProfile'    
)

Import-Module ActiveDirectory

$Script:Cim= $null
try{ 
    if([System.String]::IsNullOrWhiteSpace($ComputerName)){
        $ComputerName = [System.Net.DNS]::GetHostByName('').HostName
    }          
    if($null -eq $AccessAccount){
        $Script:Cim = New-CimSession -ComputerName $ComputerName -ErrorAction Stop
    }
    else {
        $Script:Cim = New-CimSession -ComputerName $ComputerName -Credential $AccessAccount -ErrorAction Stop
    }

    $Script:usr    
    if($PSCmdlet.ParameterSetName -eq 'ByName' ){        
        $Script:usr = Get-ADUser -Identity $UserName -Properties Name,SID,ProfilePath -ErrorAction Stop 
        $UserSID = $Script:usr.SID
    }
    else{
        $Script:usr = Get-ADUser -Filter {SID -eq $UserSID} -Properties Name,SID,ProfilePath -ErrorAction Stop 
    }
    $quy = [System.String]::Format("SELECT * FROM Win32_UserProfile WHERE SID = '{0}'",$UserSID)
    $usrProfile = Get-CimInstance -CimSession $Script:Cim -Query $quy -ErrorAction Stop
   
    # Server action
    RemoveServerProfile -ADUser $Script:usr -Action $PreviousServerProfileAction
    # Computer action
    RemoveComputerProfile -AccessAccount $AccessAccount -ComputerName $ComputerName -CimInstance $usrProfile -Action $PreviousAction

    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Profile $($usrProfile.LocalPath) removed"
    }
    else{
        Write-Output "Profile $($usrProfile.LocalPath) removed"
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