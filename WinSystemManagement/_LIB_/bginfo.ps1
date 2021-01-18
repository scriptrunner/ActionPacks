Function ConfigureWallpaper {
    <#
    .SYNOPSIS
        Places the texts on the wallpaper and saves this as backgroundDefault.jpg        
        
    .Parameter Text
        Array with text to place on the wallpaper     
        
    .Parameter Wallpaper
        Path and name of the wallpaper image     
        
    .Parameter Align
        Text align on the wallpaper     
        
    .Parameter FontStyle
        Style of the font     
        
    .Parameter FontName
        Name of the font   
        
    .Parameter FontColor
        Color of the font   
        
    .Parameter FontSize
        Size of the font
        
    .Parameter StartFromTop        
        Beginning of the texts from the top position, in pixel
    #>

    Param(  
        [Parameter(Mandatory)]
        [string[]] $Text,
        [Parameter(Mandatory)]
        [string] $WallPaper ,
        [ValidateSet("Left","Center")]
        [string]$Align = "Center",        
        [ValidateSet("Regular","Bold",'Italic','Strikeout','Underline')]
        [string]$FontStyle = "Regular",
        [string]$FontName = "Segoe UI",
        [ValidateSet('White','Black','Red','Green','Blue','Grey','Yellow','Orange')]
        [string]$FontColor = 'Black',
        [ValidateRange(9,45)]
        [int32]$FontSize = 20,
        [int]$StartFromTop = 100
    )
    Begin {
        [string]$OutFile
        [bool]$UseCurrentWallpaperAsSource = $true
        [string]$Theme = "Current"
        Switch ($Theme) {
            Current {
                $RGB = (Get-ItemProperty 'HKCU:\Control Panel\Colors' -ErrorAction Stop).BackGround
                if ($RGB.Length -eq 0) {
                    $Theme = "Black" # Default to Black and don't break the switch
                } else {
                    $BG = $RGB -split " "
                    $FC1 = $FC2 = @(255,255,255)
                    $FS1 = $FS2 = $FontSize
                    break
                }
            }
            Blue {
                $BG = @(58,110,165)
                $FC1 = @(254,253,254)
                $FC2 = @(185,190,188)
                $FS1 = $FontSize+1
                $FS2 = $FontSize-2
                break
            }
            Grey {
                $BG = @(77,77,77)
                $FC1 = $FC2 = @(255,255,255)
                $FS1=$FS2=$FontSize
                break
            }
            Black {
                $BG = @(0,0,0)
                $FC1 = $FC2 = @(255,255,255)
                $FS1=$FS2=$FontSize
            }
        }
        Try {
            [system.reflection.assembly]::loadWithPartialName('system.drawing.imaging') | out-null
            [system.reflection.assembly]::loadWithPartialName('system.windows.forms') | out-null
 
            # Draw string > alignement
            $sFormat = new-object system.drawing.stringformat
 
            Switch ($Align) {
                Center {
                    $sFormat.Alignment = [system.drawing.StringAlignment]::Near
                    $sFormat.LineAlignment = [system.drawing.StringAlignment]::Near
                    break
                }
                Left {
                    $sFormat.Alignment = [system.drawing.StringAlignment]::Far
                    $sFormat.LineAlignment = [system.drawing.StringAlignment]::Near
                }
            }

            if ($UseCurrentWallpaperAsSource) {
                if (Test-Path -Path $WallPaper -PathType Leaf) {
                    $OutFile = "$((Get-Item -Path $WallPaper | Select-Object Directory).Directory)\backgroundDefault.jpg"
                    $bmp = new-object system.drawing.bitmap -ArgumentList $WallPaper
                    $image = [System.Drawing.Graphics]::FromImage($bmp)
                    $SR = $bmp | Select-Object Width,Height
                } else {
                    Write-Warning -Message "Failed cannot find the current wallpaper $($WallPaper)"
                    break
                }
            } else {
                $SR = [System.Windows.Forms.Screen]::AllScreens | Where-Object Primary | 
                    Select-Object -ExpandProperty Bounds | Select-Object Width,Height 
                Write-Verbose -Message "Screen resolution is set to $($SR.Width)x$($SR.Height)" -Verbose
 
                # Create Bitmap
                $bmp = new-object system.drawing.bitmap($SR.Width,$SR.Height)
                $image = [System.Drawing.Graphics]::FromImage($bmp)
     
                $image.FillRectangle(
                    (New-Object Drawing.SolidBrush (
                        [System.Drawing.Color]::FromArgb($BG[0],$BG[1],$BG[2])
                    )),
                    (new-object system.drawing.rectanglef(0,0,($SR.Width),($SR.Height)))
                )
 
            }
        } Catch {
            Write-Warning -Message "Failed to $($_.Exception.Message)"
            break
        }
    }
    Process {
        $style 
        switch ($FontStyle) {
            'Italic' {$style = [System.Drawing.FontStyle]::Italic }
            'Bold' {$style = [System.Drawing.FontStyle]::Bold }
            'Strikeout' {$style = [System.Drawing.FontStyle]::Strikeout }
            'Underline' {$style = [System.Drawing.FontStyle]::Underline }
            Default {$style = [System.Drawing.FontStyle]::Regular}
        }
        $i = 1
        [int]$StartPositionLeft = 10
        Try {
            # first find longest string
            foreach($line in $Text){
                $sz2 = [system.windows.forms.textrenderer]::MeasureText($line, $font2)
                if($sz2.Width -gt $StartPositionLeft){
                    $StartPositionLeft = $sz2.Width
                }
            }
            $StartPositionLeft = ($SR.Width  / 2) - ($StartPositionLeft * 2)

            foreach($line in $Text){
                $font2 = New-Object System.Drawing.Font($FontName,$FS2,$style)
                $Brush2 = New-Object Drawing.SolidBrush (
                    $FontColor #:FromArgb($FC2[0],$FC2[1],$FC2[2])
                )
               
                $rect2 = New-Object System.Drawing.RectangleF ($StartPositionLeft,($i*$FontSize*3 + $StartFromTop),$SR.Width,$SR.Height)
                $image.DrawString($line, $font2, $brush2, $rect2, $sFormat)
                $i++
            }
        } 
        Catch {
            Write-Warning -Message "Failed to $($_.Exception.Message)"
            break
        }
    }
    End {   
        Try { 
            # Close Graphics
            $image.Dispose();
            # Save and close Bitmap
            $bmp.Save($OutFile, [system.drawing.imaging.imageformat]::Bmp);
            $bmp.Dispose();
 
            # Output our file
            Write-Verbose (Get-Item -Path $OutFile)
        } Catch {
            Write-Warning -Message "Failed to $($_.Exception.Message)"
            break
        }
    }
 
} # endof function

<#Writing info to the background
$t = @(
    "Computername: $($env:COMPUTERNAME)"
    "Username: Dataport-Testbenutzer"
    "Kennwort: 123456"
) 

#Format etc
$BGHT = @{
 Text  =  $t;
 WallPaper = 'C:\Transfer\img000.jpg'
 FontName = "Segoe UI" 
 FontColor = 'Black'
 StartFromTop =70
 FontSize = 16
}

SetDataportWallpaper @BGHT #>


return

<#
.Synopsis
   bginfo.ps1
.DESCRIPTION
    Bginfo solution, adding text on the background, and text is fully customable down in the script.
    Change the #Writing info to the background part

    You can even force a background in this script
    #Set-Wallpaper -Path "C:\Windows\Web\Wallpaper\Windows\img0.jpg" -Style stretch

   
    Created: 2019-05-31
    Version: 1.0

    Author : Pontus Wendt

    Disclaimer: This script is provided "AS IS" with no warranties, confers no rights and
    is not supported by the author.
.EXAMPLE
    NA
#>


Function New-BGinfo {
    Param(  [Parameter(Mandatory)]
            [string] $Text,
 
            [Parameter()]
            [string] $OutFile=“$($env:temp)\” + ( ( get-date ).TimeOfDay.TotalSeconds ) + “BGInfo.bmp”,
 
            [Parameter()]
            [ValidateSet("Left","Center")]
            [string]$Align="Left",
 
 
            [Parameter()]
            [ValidateSet("Current","Blue","Grey","Black")]
            [string]$Theme="Current",
 
            [Parameter()]
            [string]$FontName="Segoe UI",
 
            [Parameter()]
            [ValidateRange(9,45)]
            [int32]$FontSize = 20,
 
            [Parameter()]
            [switch]$UseCurrentWallpaperAsSource
    )
    Begin {

        # Enumerate current wallpaper now, so we can decide whether it's a solid colour or not
        try {
            $wpath = (Get-ItemProperty 'HKCU:\Control Panel\Desktop' -Name WallPaper -ErrorAction Stop).WallPaper
            if ($wpath.Length -eq 1) {
                # Solid colour used
                $UseCurrentWallpaperAsSource = $false
                $Theme = "Current"
            }
        } catch {
            $UseCurrentWallpaperAsSource = $false
            $Theme = "Current"
        }
 
        Switch ($Theme) {
            Current {
                $RGB = (Get-ItemProperty 'HKCU:\Control Panel\Colors' -ErrorAction Stop).BackGround
                if ($RGB.Length -eq 0) {
                    $Theme = "Black" # Default to Black and don't break the switch
                } else {
                    $BG = $RGB -split " "
                    $FC1 = $FC2 = @(255,255,255)
                    $FS1=$FS2=$FontSize
                    break
                }
            }
            Blue {
                $BG = @(58,110,165)
                $FC1 = @(254,253,254)
                $FC2 = @(185,190,188)
                $FS1 = $FontSize+1
                $FS2 = $FontSize-2
                break
            }
            Grey {
                $BG = @(77,77,77)
                $FC1 = $FC2 = @(255,255,255)
                $FS1=$FS2=$FontSize
                break
            }
            Black {
                $BG = @(0,0,0)
                $FC1 = $FC2 = @(255,255,255)
                $FS1=$FS2=$FontSize
            }
        }
        Try {
            [system.reflection.assembly]::loadWithPartialName('system.drawing.imaging') | out-null
            [system.reflection.assembly]::loadWithPartialName('system.windows.forms') | out-null
 
            # Draw string > alignement
            $sFormat = new-object system.drawing.stringformat
 
            Switch ($Align) {
                Center {
                    $sFormat.Alignment = [system.drawing.StringAlignment]::Center
                    $sFormat.LineAlignment = [system.drawing.StringAlignment]::Center
                    break
                }
                Left {
                    $sFormat.Alignment = [system.drawing.StringAlignment]::Far
                    $sFormat.LineAlignment = [system.drawing.StringAlignment]::Near
                }
            }

            if ($UseCurrentWallpaperAsSource) {
                if (Test-Path -Path $wpath -PathType Leaf) {
                    $bmp = new-object system.drawing.bitmap -ArgumentList $wpath
                    $image = [System.Drawing.Graphics]::FromImage($bmp)
                    $SR = $bmp | Select Width,Height
                } else {
                    Write-Warning -Message "Failed cannot find the current wallpaper $($wpath)"
                    break
                }
            } else {
                $SR = [System.Windows.Forms.Screen]::AllScreens | Where Primary | 
                Select -ExpandProperty Bounds | Select Width,Height
 
                Write-Verbose -Message "Screen resolution is set to $($SR.Width)x$($SR.Height)" -Verbose
 
                # Create Bitmap
                $bmp = new-object system.drawing.bitmap($SR.Width,$SR.Height)
                $image = [System.Drawing.Graphics]::FromImage($bmp)
     
                $image.FillRectangle(
                    (New-Object Drawing.SolidBrush (
                        [System.Drawing.Color]::FromArgb($BG[0],$BG[1],$BG[2])
                    )),
                    (new-object system.drawing.rectanglef(0,0,($SR.Width),($SR.Height)))
                )
 
            }
        } Catch {
            Write-Warning -Message "Failed to $($_.Exception.Message)"
            break
        }
    }
    Process {
 
        # Split our string as it can be multiline
        $artext = ($text -split "`r`n")
     
        $i = 1
        Try {
            for ($i ; $i -le $artext.Count ; $i++) {
                if ($i -eq 0) {
                    #$font1 = New-Object System.Drawing.Font($FontName,$FS1,[System.Drawing.FontStyle]::Bold)
                    #$Brush1 = New-Object Drawing.SolidBrush (
                        #[System.Drawing.Color]::FromArgb($FC1[0],$FC1[1],$FC1[2])
                    #)
                    #$sz1 = [system.windows.forms.textrenderer]::MeasureText($artext[$i-1], $font1)
                    #$rect1 = New-Object System.Drawing.RectangleF (0,($sz1.Height),$SR.Width,$SR.Height)
                    #$image.DrawString($artext[$i-1], $font1, $brush1, $rect1, $sFormat) 
                } else {
                    $font2 = New-Object System.Drawing.Font($FontName,$FS2,[System.Drawing.FontStyle]::Bold)
                    $Brush2 = New-Object Drawing.SolidBrush (
                        [System.Drawing.Color]::FromArgb($FC2[0],$FC2[1],$FC2[2])
                    )
                    $sz2 = [system.windows.forms.textrenderer]::MeasureText($artext[$i-17], $font2)
                    $rect2 = New-Object System.Drawing.RectangleF (0,($i*$FontSize*1.5 + $sz2.Height),$SR.Width,$SR.Height)
                    $image.DrawString($artext[$i-1], $font2, $brush2, $rect2, $sFormat)
                }
            }
        } Catch {
            Write-Warning -Message "Failed to $($_.Exception.Message)"
            break
        }
    }
    End {   
        Try { 
            # Close Graphics
            $image.Dispose();
 
            # Save and close Bitmap
            $bmp.Save($OutFile, [system.drawing.imaging.imageformat]::Bmp);
            $bmp.Dispose();
 
            # Output our file
            Get-Item -Path $OutFile
        } Catch {
            Write-Warning -Message "Failed to $($_.Exception.Message)"
            break
        }
    }
 
} # endof function


Function Set-Wallpaper {
    Param(
        [Parameter(Mandatory=$true)]
        $Path,
         
        [ValidateSet('Center','Stretch','Fill','Tile','Fit')]
        $Style = 'Stretch'
    )
    Try {
        if (-not ([System.Management.Automation.PSTypeName]'Wallpaper.Setter').Type) {
            Add-Type -TypeDefinition @"
            using System;
            using System.Runtime.InteropServices;
            using Microsoft.Win32;
            namespace Wallpaper {
                public enum Style : int {
                Center, Stretch, Fill, Fit, Tile
                }
                public class Setter {
                    public const int SetDesktopWallpaper = 20;
                    public const int UpdateIniFile = 0x01;
                    public const int SendWinIniChange = 0x02;
                    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
                    private static extern int SystemParametersInfo (int uAction, int uParam, string lpvParam, int fuWinIni);
                    public static void SetWallpaper ( string path, Wallpaper.Style style ) {
                        SystemParametersInfo( SetDesktopWallpaper, 0, path, UpdateIniFile | SendWinIniChange );
                        RegistryKey key = Registry.CurrentUser.OpenSubKey("Control Panel\\Desktop", true);
                        switch( style ) {
                            case Style.Tile :
                                key.SetValue(@"WallpaperStyle", "0") ; 
                                key.SetValue(@"TileWallpaper", "1") ; 
                                break;
                            case Style.Center :
                                key.SetValue(@"WallpaperStyle", "0") ; 
                                key.SetValue(@"TileWallpaper", "0") ; 
                                break;
                            case Style.Stretch :
                                key.SetValue(@"WallpaperStyle", "2") ; 
                                key.SetValue(@"TileWallpaper", "0") ;
                                break;
                            case Style.Fill :
                                key.SetValue(@"WallpaperStyle", "10") ; 
                                key.SetValue(@"TileWallpaper", "0") ; 
                                break;
                            case Style.Fit :
                                key.SetValue(@"WallpaperStyle", "6") ; 
                                key.SetValue(@"TileWallpaper", "0") ; 
                                break;
}
                        key.Close();
                    }
                }
            }
"@ -ErrorAction Stop 
            } else {
                Write-Verbose -Message "Type already loaded" -Verbose
            }
        # } Catch TYPE_ALREADY_EXISTS
        } Catch {
            Write-Warning -Message "Failed because $($_.Exception.Message)"
        }
     
    [Wallpaper.Setter]::SetWallpaper( $Path, $Style )
}

#Sets a custom background (optional)
#Set-Wallpaper -Path "C:\Windows\Web\Wallpaper\Windows\img0.jpg" -Style stretch



#Gather information
$WindowsVersion =(Get-ItemProperty -Path "HKLM:\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ReleaseID).ReleaseID

$BoottimeRaw = systeminfo | Select-String "System Boot Time"
if($null -eq $BoottimeRaw){
    $BoottimeRaw = systeminfo | Select-String "Systemstartzeit" # deutsches OS
}
$Boottime = ''
if([System.String]::IsNullOrWhiteSpace($BoottimeRaw) -eq $false){
    $BoottimeRaw = $BoottimeRaw.ToString()
    $Boottime = $BoottimeRaw.Substring($BoottimeRaw.IndexOf(':')+1).Trim() 
}
#Writing info to the background
$t = @"
Computername: $env:COMPUTERNAME
Username: $env:USERNAME
Logonserver: $env:LOGONSERVER
Windows Version $WindowsVersion
System Start Time : $Boottime
Author of this amazing script: Pontus Wendt
"@ 

#Format etc
$BGHT = @{
 Text  =  $t;
 Theme = "Current" ;
 FontName = "Segoe UI" ;
 UseCurrentWallpaperAsSource = $true ;
}

$WallPaper = New-BGinfo @BGHT

#Runing the function
Set-Wallpaper -Path $WallPaper.FullName -Style stretch

