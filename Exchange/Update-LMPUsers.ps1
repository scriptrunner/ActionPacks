#Requires -Version 4
# Requires -Modules Com.AppSphere.Base, ActiveDirectory

<#
    .SYNOPSIS
        Aktualisiert die LMP-Benutzer. Grundlage ist die AD Gruppe

	.Parameter DomainName
        Name der Active Directory Domäne.
		Standardbelegung ist Muenchen.de
		
    .Parameter ADCredential
         Ausreichend berechtigtes Benutzerkonto für den Zugriff auf das Active Directory

    .Parameter LMPProgramUserGroup
        Mitglieder dieser Gruppe werden in LMP übernommen

	.Parameter DataPath
        Optionaler Pfad zur Dateiablage und Pfad zur Druckertreiberdatei.
		Standardbelegung ist das ProgramData Verzeichnis bzw. das Homedrive 
		 
	.Parameter LogPath
        Optionaler Pfad zur Ablage der Protokolldatei.
		Standardbelegung ist Log\Referat im DataPath
		 
	.Parameter LogMaxSaveDays
        Anzahl der Tage wie lange Protokolldateien aufbewahrt werden.
		Standardbelegung ist 14 Tage

	.Parameter LogLevel         
		Standardbelegung ist Information

    .Parameter ValidDepartments
        Nur Benutzer in deren OU ein Referat der Liste vorkommen werden in LMP aufgenommen
		Beispiel: CN=vorname.zuname,OU=Users,OU=REFERAT,OU=Bereiche,DC=muenchen,DC=de
		 
	.Parameter SQLServer
        MS SQL-Server auf dem sich die die LMP Datenbank befindet
		 
	.Parameter SQLDbName
        Name der LMP Datenbank

    .Parameter SQLCredential
        Auf LMP-Datenbank berechtigter Benutzer mit SQL-Authentifizierung (keine Windows-Authentifizierung!)
		 
	.EXAMPLE
#>

[CmdletBinding()]
param(
	[parameter(Mandatory = $true)]
    [string]$SqlServer,
    [parameter(Mandatory = $true)]
    [string]$SQlDbName='LMP',
	[parameter(Mandatory = $true)]
    [PsCredential]$SQLCredential,
    [string]$DomainName="muenchen.de",
    [PsCredential]$ADCredential ,
    [ValidateSet('Basic','Negotiate')]
    [string]$ADAuthType="Negotiate",
    [parameter(Mandatory = $true)]
    [string]$LMPProgramUserGroup,
    [string]$DataPath,
    [string]$LogPath,
    [int]$LogMaxSaveDays = 14,
    [ValidateSet('Debug', 'Information', 'Warning', 'Error')]
    [string]$LogLevel = 'Information',
    [string[]]$ValidDepartments=@('AWM', 'BAU', 'BFM', 'DIR', 'ITM', 'KOM', 'KUL', 'KVR', 'MHM', 'MKS', 'MSE', 'PLA', 'POR', 'RAW', 'RBS', 'RGU', 'SKA', 'SOZ', 'STA', 'STR')
)

Import-Module ActiveDirectory
Import-Module 'C:\Program Files (x86)\AppSphere\LocateMyPrinters\Modules\LMPCmdLet\LMPCmdLet.psd1'

[bool]$Script:WhatIf =$true
[string]$Script:UsersFolder="_Benutzer"
[string]$Global:LogPreference = $LogLevel
$Script:SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$Script:SqlConnection.ConnectionString = "Server = $($SqlServer); Database = $($SQlDbName); Integrated Security = False; User ID = $($SQLCredential.GetNetworkCredential().UserName); Password = $($SQLCredential.GetNetworkCredential().Password)"
$Script:SqlConnection.Open()
$Script:SqlCmd = New-Object System.Data.SqlClient.SqlCommand

if(-not $DataPath)
{
	if(-not $env:ProgramData){
	    $DataPath = Join-Path -Path $env:HOMEDRIVE -ChildPath 'AppSphere\LocateMyPrinters'
	} else {
	    $DataPath = Join-Path -Path $env:ProgramData -ChildPath 'AppSphere\LocateMyPrinters'
	}
}
if(-not [System.IO.Directory]::Exists($DataPath))
{
    [System.IO.Directory]::CreateDirectory($DataPath)
}
if(-not $LogPath)
{
    $LogPath = $DataPath + "\Logs\Common"
}
if(-not $LogPath.EndsWith($Department)){
    $LogPath = $LogPath + "\Common" 
}
if(-not [System.IO.Directory]::Exists($LogPath))
{
    [System.IO.Directory]::CreateDirectory($LogPath)
}
$scriptName = $MyInvocation.MyCommand.Name.Split('.')[0]
if([String]::IsNullOrEmpty($scriptName)){
    # Invoked by ScriptRunner
    Write-Log "$($SRXEnv.SRXScriptName)"
    $scriptName = ($SRXEnv.SRXScriptName -split '.', 0, "SimpleMatch")[0]
}
if([String]::IsNullOrEmpty($scriptName)){
    $scriptName = 'Update-LMPUsers'
}
$Global:logFilePath = Join-Path -Path $logPath -ChildPath "$($scriptName)_$(Get-Date -Format 'yyyyMMdd_HHmm').log"
Write-Log "********************************************************************************"
Write-Log "Start Script to update LMP program users."
Write-Log "********************************************************************************"

#Functions
$Script:ADUsers = New-Object 'System.Collections.Generic.SortedDictionary[string,object]'
function ClearLogFolder(){# alte Logfiles löschen
    Write-Log "********************************************************************************"
    Write-Log "Clear log folder"
    Write-Log "********************************************************************************"
    $checkDate=[System.DateTime]::Today.AddDays(-$LogMaxSaveDays)
    $logfiles = dir -Path $LogPath -Filter $scriptName*.log | sort lastwritetime
    Write-Log "Check log folder $($LogPath)" -Level Information
    foreach($file in $logfiles){
        if($file.LastWriteTime -lt $checkDate){
            Write-Log "Delete log file $($file.Name)" -Level Information
            $file.Delete()
        }
    }
}
function Get-NestedGroupMember($group) { 
    Write-Log "Group: $($group.SamAccountName)"
    $members =Get-ADGroupMember -Identity $group -AuthType $ADAuthType -Credential $ADCredential | `
            Sort-Object -Property  @{Expression="objectClass";Descending=$true} , @{Expression="SamAccountName";Descending=$false}
    if($null -ne $members){
        foreach($itm in $members){
            if($itm.objectClass -eq "group"){
                Get-NestedGroupMember($itm)
            }
            else{
                if(-not $Script:ADUsers.ContainsKey($itm.SamAccountName)){
                    $Script:ADUsers.Add($itm.SamAccountName,$itm)
                #    Write-Log "$($itm.SamAccountName) - $($itm.SID)"
                }
            }
        }
    }
}
function Get-FirstLetterOfSurName{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [string]$User
    )

    Trap {Return "_"}

    $names = $user.Split(@('.'))
    if($names.Count -gt 0)
    {
        $surname = $names[$names.Count - 1]
        $letter = $surname.Substring(0,1)
		switch ($letter)
		{
			"Ä" { $letter = "A" }
			"Ö" { $letter = "O" }
			"Ü" { $letter = "U" }
			#default 
		}
		return $letter.ToUpperInvariant()
    }
}
function Get-Department([string]$dep){
    #CN=vorname.zuname,OU=Users,OU=BAU,OU=Bereiche,DC=muenchen,DC=de
    $out = $dep.Replace(",OU=Bereiche,DC=muenchen,DC=de","").Trim()
    return $out.Substring($out.Length-3)
}

function SetDepartment(){
	[CmdLetBinding()]
    Param(           
        [Parameter(Mandatory = $true)] 
        [guid]$UserID,
        [Parameter(Mandatory = $true)] 
        [string]$Department
    )
	try
	{
		$Script:SqlCmd.CommandText = 'LdapSetDepartment4User'
		$Script:SqlCmd.CommandType = [System.Data.CommandType]::StoredProcedure
		$Script:SqlCmd.Connection = $Script:SqlConnection
		$Script:SqlCmd.Parameters.AddWithValue("@Identifier", $UserID)
		$Script:SqlCmd.Parameters.AddWithValue("@Department", $Department)
		if ($Script:SqlCmd.Connection.State -ne [System.Data.ConnectionState]::Open) { 
			$Script:SqlCmd.Connection.Open()
		}
		$Script:SqlCmd.ExecuteNonQuery()		
	}
	catch
	{
		Write-Log "Write department $($Department) for user id $($UserID) failed. $($_.Exception.Message)" -Level Error
	}
	finally{
	}
}

$repeathashGroup = @{ }
$repeathashUser = @{ }
function Get-NestedGroupMembersNeu($GroupName) { 
    $Grouppath = "LDAP://" + $GroupName
    $groupObj = [ADSI]$Grouppath
    foreach($member in $groupObj.Member){ 
        $userPath = "LDAP://" + $member
        $UserObj = [ADSI]$userPath
        if($UserObj.groupType.Value -eq $null){
            if($repeathashUser.ContainsKey($UserObj.distinguishedName.ToString()) -eq $false){
                $repeathashUser.add($UserObj.distinguishedName.ToString(),1)
                if(-not $Script:ADUsers.ContainsKey($itm.SamAccountName)){
                    $usr = Get-ADUser -AuthType $ADAuthType -Credential $ADCredential -Filter {SamAccountname -eq $UserObj.SamAccountName}
                    $Script:ADUsers.Add($UserObj.SamAccountName,$usr)
                #    Write-Log "$($itm.SamAccountName) - $($itm.SID)"
                }
            }
        }    
        else{
            if($repeathashGroup.ContainsKey($UserObj.distinguishedName.ToString()) -eq $false){
                $repeathashGroup.add($UserObj.distinguishedName.ToString(),1)
                Write-Log "Group: $($UserObj.SamAccountName)"
                Get-NestedGroupMembersNeu $UserObj.distinguishedName
            }
        }
    }
}

ClearLogFolder
# Gruppe aus AD laden und Benutzer rekursiv auslesen
Write-Log "Read group: $($LMPProgramUserGroup) from Active Directory"
$Grp= Get-ADGroup -Credential $ADCredential -AuthType $ADAuthType `
        -Filter {(SamAccountName -eq $LMPProgramUserGroup) -or (DistinguishedName -eq $LMPProgramUserGroup)} 
if($null -ne $Grp){    
    Write-Log "Read group users"
   # alt Get-NestedGroupMember $Grp # AD Benutzer laden
   Write-Log "Group: $($Grp.SamAccountName)"
   Get-NestedGroupMembersNeu $Grp.DisdistinguishedName
#    $Script:ADUsers.Count
    Write-Log "Read LMP users"
    $Script:LMPUsers= LMPCmdLet\Get-LMPProgramUsers -IgnoreDeleteFlag # LMP Benutzer laden
#    $Script:LMPUsers.Count
    if($null -ne $Script:ADUsers -and $null -ne $Script:LMPUsers){
        $Script:delUsers=@{}
        $Script:LMPUsers | foreach{
            $Script:delUsers[$_.ID]=$_.UserName
        } # Vorhalten um Löschung durchzuführen
        # Abgleich der Benutzer
        foreach($usr in $Script:ADUsers.Keys){
            $dep=Get-Department $Script:ADUsers[$usr].DistinguishedName
            if($ValidDepartments -notcontains $dep){
                Write-Log  "User $($usr) OU contains not a valid department"
                continue
            }
            # Benutzer per SID suchen
            $tmp= $Script:LMPUsers | Where-Object {$_.SID -eq $Script:ADUsers[$usr].SID.value}
            if($null -eq $tmp){
  # veraltet v6.0              $tmp= $Script:LMPUsers | Where-Object {$_.UserName -eq $usr}    # Benutzer per SamAccount suchen
            }
         <#   else
            {
            Write-Log "found per sid"
            }#>
            if($null -eq $tmp){
                Write-Log  "User: $($usr) not found"
                $tmp=LMPCmdLet\New-LMPProgramUser
                # Benutzer anlegen
                try{
                    $tmp.UserName=$usr
                    $tmp.Domain=$DomainName
                    $tmp.SID=$Script:ADUsers[$usr].SID.value
                    if($Script:WhatIf){
                        Write-Log "Create user: $($usr)"
                    }
                    else{
                        $tmp=LMPCmdLet\Set-LMPProgramUser -User $tmp -ErrorAction SilentlyContinue
                        Write-Log "Added LMP ProgramUser $($usr)"
                    }
                }
                catch{
                    Write-Log "Error create user: $($usr) - $($_.Exception.Message))" 
                }
            }
            else{
                $Script:delUsers.Remove($tmp.ID)
                # Benutzer aktualisieren?
                if(Get-Member -InputObject $tmp -name "UserName" -MemberType Properties ){                    
                    if(($tmp.UserName -ne $usr) -or ($tmp.SID -ne $Script:ADUsers[$usr].SID.value) -or ($tmp.Domain -ne $DomainName)){
                        try{
                            $tmp.UserName = $usr
                            $tmp.Domain = $DomainName
                            $tmp.SID = $Script:ADUsers[$usr].SID.value
                            if($Script:WhatIf){
                                Write-Log "User: $($usr) must update"
                            }
                            else{
								$tmp=LMPCmdLet\Set-LMPProgramUser -User $tmp -ErrorAction SilentlyContinue
								SetDepartment -UserID [System.Guid]::new($tmp.ID) -Department $dep
								Write-Log "LMP ProgramUser $($usr) updated"
                            }
                        }
                        catch{
                            Write-Log "Error update user: $($usr) - $($_.Exception.Message))"
                        }
                    }
                }
                else{
                    $tmp | Select-Object *
                    Write-Log "LMP ProgramUser $($usr) is corrupt. Please check the user in LMP" -Level Warning
                    continue
                }                
            }
            # Infrastruktur updaten
            if($null -ne $tmp){
                $folder= "$(Get-Department $Script:ADUsers[$usr].DistinguishedName);$($Script:UsersFolder);$(Get-FirstLetterOfSurName $usr)"
                if($Script:WhatIf){
                    Write-Log "Add user: $($usr) to $($folder)"
                }
                else{
                    if(-not [System.String]::IsNullOrWhiteSpace($folder)){
                        $lmpInfra = LMPCmdlet\Add-LMPInfrastructureObjects -ObjectNames $folder -Separator ';'
                        if($null -ne $lmpInfra){
				            if(LMPCmdlet\Add-LMPProgramUserToInfrastructure -UserObject $tmp -InfrastructureObject $lmpInfra)
				            {
                                Write-Log "Add $($usrs) to $($folder)"
                            }
                        }
                    }
                }
            }
        }
        # Benutzer nicht mehr gefunden daher löschen
        foreach($item in $Script:delUsers.Values){
            if($Script:WhatIf){
                Write-Log "Delete user: $($item)" 
            }
            else{
                LMPCmdLet\Remove-LMPProgramUser -User $Script:LMPUsers | Where-Object -Property
                Write-Log "LMP ProgramUser $($usr) removed"
            }
        }
    }
}
else{
    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Group: $($LMPProgramUserGroup) not found"
    }    
    Throw "Group: $($LMPProgramUserGroup) not found"
}
# Aufräumen
if($Script:SqlCmd){
    $Script:SqlCmd.Dispose()
}
if($Script:SqlConnection -and $Script:SqlConnection.State -eq [System.Data.ConnectionState]::Open){
    $Script:SqlConnection.Close()
}
if($Script:SqlConnection){
    $Script:SqlConnection.Dispose()
}
Write-Log "********************************************************************************"
Write-Log "Script complete"
Write-Log "********************************************************************************"