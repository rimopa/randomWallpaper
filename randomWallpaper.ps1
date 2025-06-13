#-------------------------------------------------------------------#
# ScriptName : SetRandomWallpaper_MultiFolder.ps1                   #
# Description : Random wallpaper from two folders.                  #
# Credits: rimopa                                                   #
# Date : 13/6/2025                                                  #
#-------------------------------------------------------------------#

# Define the folder paths
$folders = @(
    "C:\Users\Usuario\OneDrive\Imágenes\wallpaper\PC",
    "C:\Users\Usuario\OneDrive\Imágenes\wallpaper\PC+Phone"
)

#Allowed extensions
$allowedExtensions = @(".jpg", ".jpeg", ".png", ".bmp", ".gif", ".webp", ".tiff")

# Empty array to store all files
$items = @()

# Helper function to safely get files from a folder
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

# Aggregate files from all folders
foreach ($f in $folders) {
    $items += Get-FilesSafely $f
}

# Check if any files were found
if ($items.Count -eq 0) {
    Write-Error "No images found in any folder. Exiting."
    exit 1
}

# Select a random item
$randomItem = $items | Get-Random

# Output the random item
Write-Output "Random item selected: $($randomItem.FullName)"

# Apply the wallpaper change
$imgPath = $randomItem.FullName
$code = @' 
using System.Runtime.InteropServices; 
namespace Win32{ 
     public class Wallpaper{ 
        [DllImport("user32.dll", CharSet=CharSet.Auto)] 
         static extern int SystemParametersInfo (int uAction , int uParam , string lpvParam , int fuWinIni) ; 
         public static void SetWallpaper(string thePath){ 
            SystemParametersInfo(20,0,thePath,3); 
         }
    }
 } 
'@

add-type $code 
[Win32.Wallpaper]::SetWallpaper($imgPath)
