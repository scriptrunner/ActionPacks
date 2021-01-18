#Requires -Version 5.0

<#
.SYNOPSIS
    Sets the logon wallpaper on the computer

.DESCRIPTION

.NOTES
    This PowerShell script was developed and optimized for ScriptRunner. The use of the scripts requires ScriptRunner. 
    The customer or user is authorized to copy the script from the repository and use them in ScriptRunner. 
    The terms of use for ScriptRunner do not apply to this script. In particular, ScriptRunner Software GmbH assumes no liability for the function, 
    the use and the consequences of the use of this freely available script.
    PowerShell is a product of Microsoft Corporation. ScriptRunner is a product of ScriptRunner Software GmbH.
    © ScriptRunner Software GmbH

.COMPONENT
    Requires Library script  

.LINK
    https://github.com/scriptrunner/ActionPacks/tree/master/WinSystemManagement/System

.Parameter SourceImagePath        
    [sr-en] Path of the source image
    [sr-de] Pfad zur Wallpaper-Datei
    
.Parameter SourceImageName        
    [sr-en] Name of the source image
    [sr-de] Name der Wallpaper-Datei, diese wird kopiert und angepasst
    
.Parameter ComputerName
    [sr-en] Specifies an remote computer, if the name empty the local computer is used
    [sr-de] Name des Computers auf dem das Wallpaper konfiguriert wird

.Parameter AccessAccount
    [sr-en] Specifies a user account that has permission to perform this action. If Credential is not specified, the current user account is used.
    [sr-de] Benutzerkonto um das Wallpaper auf dem Computer zu konfigurieren

.Parameter CopyViaShare
    [sr-en] Requires C$ share to copy, otherwise via PSSession
    [sr-de] Setzt C$ Freigabe zum Kopieren voraus, sonst per PSSession

.Parameter EnableBlurEffect
    [sr-en] Activates the blur effect on logon    
    [sr-de] Aktiviert die unscharfe Darstellung beim Logon
#>

[CmdLetBinding()]
Param(
    [Parameter(Mandatory =$true,ParameterSetName = 'Local')]
    [Parameter(Mandatory =$true,ParameterSetName = 'Remote')]
    [string]$SourceImagePath,
    [Parameter(Mandatory =$true,ParameterSetName = 'Local')]
    [Parameter(Mandatory =$true,ParameterSetName = 'Remote')]
    [string]$SourceImageName,
    [Parameter(Mandatory =$true,ParameterSetName = 'Remote')]
    [string]$ComputerName,    
    [Parameter(ParameterSetName = 'Remote')]
    [PSCredential]$AccessAccount,
    [Parameter(ParameterSetName = 'Local')]
    [Parameter(ParameterSetName = 'Remote')]
    [switch]$EnableBlurEffect,
    [Parameter(ParameterSetName = 'Remote')]
    [switch]$CopyViaShare
)

try{    
    [string]$WallpaperPath = 'C:\Windows\Web\Screen'
    [string]$Wallpaper = 'backgroundDefault.jpg'

    if($SourceImagePath.EndsWith('\') -eq $false){
        $SourceImagePath += '\'
    }

    [hashtable]$invArgs = @{
        'ErrorAction' = 'Stop'
    }
    if($PSCmdlet.ParameterSetName -eq 'Remote'){
        $invArgs.Add('ComputerName', $ComputerName)
        if($null -ne $AccessAccount){
            $invArgs.Add('Credential', $AccessAccount)
        }
    }
    # set registry keys
    [string[]]$imageInfos = Invoke-Command @invArgs -ScriptBlock{
        param(
            [string]$ImageName,
            [bool]$BlurEffect
        )
        [string]$regKey = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
        [string]$regKeyBlur = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
    
        # set wallpaper
        $tmp = Get-Item -Path $regKey -ErrorAction SilentlyContinue
        if($null -eq $tmp){
            New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows -Name Personalization
        }
        $tmp = Get-ItemProperty -Path $regKey -Name LockScreenImage -ErrorAction SilentlyContinue
        if($null -eq $tmp){
            New-ItemProperty -Path $regKey -Name LockScreenImage
        }
        Set-ItemProperty -Path $regKey -Name LockScreenImage -Value $ImageName
        # set blur effect
        $tmp = Get-Item -Path $regKeyBlur -ErrorAction SilentlyContinue
        if($null -eq $tmp){
            New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows -Name System
        }
        $tmp = Get-ItemProperty -Path $regKeyBlur -Name DisableAcrylicBackgroundOnLogon -ErrorAction SilentlyContinue
        if($null -eq $tmp){
            New-ItemProperty -Path $regKeyBlur -Name DisableAcrylicBackgroundOnLogon
        }
        if($BlurEffect -eq $true){
            Set-ItemProperty -Path $regKeyBlur -Name DisableAcrylicBackgroundOnLogon -Value 0
        }
        else{
            Set-ItemProperty -Path $regKeyBlur -Name DisableAcrylicBackgroundOnLogon -Value 1
        }
        $comp = Get-ComputerInfo | Select-Object OSName, CsName,CsProcessors,CsTotalPhysicalMemory,OsArchitecture
        # info text to set on wallpaper
        @(
            "Computername: $($comp.CsName)"
            "OS Architecture: $($comp.OsArchitecture)"
            "OS Name: $($comp.OSName)"
            "CPU: $($comp.CsProcessors.Name)"
            "Total Physical Memory: $([System.Math]::Round(($comp.CsTotalPhysicalMemory /1MB),0)) MB"
        ) 
    } -ArgumentList "$($WallpaperPath)\$($Wallpaper)",($EnableBlurEffect.IsPresent)

    # generate wallpaper
    [hashtable]$cmdArgs = @{
        Wallpaper = "$($SourceImagePath)$($SourceImageName)"
        Text  =  $imageInfos
        FontName = "Segoe UI" 
        FontColor = 'Black'
        StartFromTop = 70
        FontSize = 16}  
    ConfigureWallpaper @cmdArgs

    # copy wallpaper to target folder
    [string]$configuredWallpaper = "$($SourceImagePath)$($Wallpaper)"
    if($CopyViaShare.IsPresent -eq $true){
        Copy-Item -Path $configuredWallpaper -Destination "\\$($ComputerName)\C$\$($WallpaperPath.Substring(2))" -Force -ErrorAction Stop
    }
    else{
        $sess = $null
        $cmdArgs = @{
            Path  =  $configuredWallpaper
            Destination = "$($WallpaperPath)"
            Force = $null
            ErrorAction = 'Stop'
        }  
        if($PSCmdlet.ParameterSetName -eq 'Remote'){
            if($null -ne $AccessAccount){
                $sess = New-PSSession -ComputerName $ComputerName -Credential $AccessAccount
            }
            else{
                $sess = New-PSSession -ComputerName $ComputerName
            }
            $cmdArgs.Add('toSession',$sess)
        }
        Copy-Item @cmdArgs   
        if($null -ne $sess) {
            Remove-PSSession -Session $sess -Confirm:$false
        }    
    }

    # remove configured wallpaper
    Remove-Item -Path $configuredWallpaper -Force -ErrorAction SilentlyContinue

    if($SRXEnv) {
        $SRXEnv.ResultMessage = "Logon wallpaper set"
    }
    else{
        Write-Output "Logon wallpaper set"
    }
}
catch{
    throw
}
finally{
}