#-------------------------------------------------------------------#
# ScriptName : randomWallpaper.ps1                                  #
# Description : Change your wallpaper to a random one in one or     #
# more folders.                                                     #
# Credits: rimopa                                                   #
# Date : 31/7/2025                                                  #
#-------------------------------------------------------------------#
$folders = $args

# Validate that folders were provided
if ($folders.Count -eq 0) {
    Write-Error "No folder paths provided. Please provide one or more folders."
    exit 1
}

if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Error "PowerShell 5.0 or higher required. More information at https://github.com/rimopa/randomWallpaper/"
    exit 1
}

$allowedExtensions = @(".jpg", ".jpeg", ".png", ".bmp", ".gif", ".webp", ".tiff")

$items = @()

function Get-FilesSafely($folderPath) {
    if (Test-Path $folderPath) {
        $files = Get-ChildItem -Recurse -Path $folderPath -File -ErrorAction SilentlyContinue
        if ($files.Count -gt 0) {
            $imageFiles = $files | Where-Object { 
                $allowedExtensions -contains $_.Extension.ToLower()
            }
            return $imageFiles
        }
        else {
            Write-Output "Warning: Folder '$folderPath' contains no files."
            return @()
        }
    }
    else {
        Write-Output "Warning: Folder '$folderPath' does not exist."
        return @()
    }
}

foreach ($f in $folders) {
    $items += Get-FilesSafely $f
}

if ($items.Count -eq 0) {
    Write-Error "No images found in any folder. Exiting."
    exit 1
}

$randomItem = $items | Get-Random

#Write-Output "Random item selected: $($randomItem.FullName)"

$imgPath = $randomItem.FullName

Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "Wallpaper" -Value $imgPath

$SPI_SETDESKWALLPAPER = 0x0014
$SPIF_UPDATEINIFILE = 0x01
$SPIF_SENDWININICHANGE = 0x02

Add-Type @"
using System;
using System.Runtime.InteropServices;

public class Wallpaper {
    [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@

$result = [Wallpaper]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $imgPath, $SPIF_UPDATEINIFILE -bor $SPIF_SENDWININICHANGE)

if (-not $result) {
    Write-Error "Failed to set wallpaper. Error code: $([System.Runtime.InteropServices.Marshal]::GetLastWin32Error())"
}
else {
    Write-Output $imgPath
    exit 0
}
