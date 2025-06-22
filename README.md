# randomWallpaper
Change your Windows wallpaper to a random one in the indicated folder or folders.

Requires PowerShell 5.0+.

The script only allows for .jpg, .jpeg, .png, .bmp, .gif, .webp and .tiff images. If you know of any other file extension Windows supports as a desktop background, feel free to tell me!

## Usage
```
C:\Path\To\randomWallpaper.exe "C:\Path\To\Wallpapers\1" "D:\Path\To\Wallpapers\2" "E:\Path\To\Wallpapers\3" ...
```

If you'd rather hardcode the folder paths insted of passing them as arguments, you can replace the `$folders = $args` at the top of the script with the following code (with your own paths):
```
$folders = @(
    "C:\Path\To\Wallpapers\1",
    "D:\Path\To\Wallpapers\2",
    "E:\Path\To\Wallpapers\3"
)
```
If you do this, remember that powershell version 5 uses UTF-8 with BOM encoding by default, which can mess with your paths depending on the characters you use. For more information, read [this](https://en.wikipedia.org/wiki/Byte_order_mark).
