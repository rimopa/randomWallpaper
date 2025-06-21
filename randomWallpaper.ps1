#-------------------------------------------------------------------#
# ScriptName : randomWallpaper.ps1                                  #
# Description : Change your wallpaper to a random one in one or     #
# more folders.                                                     #
# Credits: rimopa                                                   #
# Date : 20/6/2025                                                  #
#-------------------------------------------------------------------#
$folders = $args;

# If you'd rather hardcode the folder paths insted of passing them as arguments, uncomment this and add it here::
# If you do this, remember that powershell version 5 uses UTF-8 with BOM encoding. For more information, read https://en.wikipedia.org/wiki/Byte_order_mark
#
#$folders = @(
#    "C:\Users\Usuario\OneDrive\Imágenes\wallpaper\PC",
#    "C:\Users\Usuario\OneDrive\Imágenes\wallpaper\PC+Phone"
#)

# Validate that folders were provided
if ($folders.Count -eq 0) {
    Write-Error "No folder paths provided. Please provide one or more folders using the -folders parameter."
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

# Set registry keys (this affects the current user)
$regPath = "HKCU:\Control Panel\Desktop"

Set-ItemProperty -Path $regPath -Name "Wallpaper" -Value $imgPath

# Define the SPI constants
$SPI_SETDESKWALLPAPER = 0x0014
$SPIF_UPDATEINIFILE = 0x01
$SPIF_SENDWININICHANGE = 0x02

# Add type to call the SystemParametersInfo function from user32.dll
Add-Type @"
using System;
using System.Runtime.InteropServices;

public class Wallpaper {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@

# Call the function to update the wallpaper immediately
$result = [Wallpaper]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $imgPath, $SPIF_UPDATEINIFILE -bor $SPIF_SENDWININICHANGE)

if (-not $result) {
    Write-Error "Failed to set wallpaper. Error code: $([System.Runtime.InteropServices.Marshal]::GetLastWin32Error())"
}
