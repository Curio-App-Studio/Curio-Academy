Add-Type -AssemblyName System.Drawing

$srcPath = "C:\Users\vivek\.gemini\antigravity\brain\c84f467a-bb93-4024-a5e5-d170bef9d128\.user_uploaded\media_1790105597613.jpg"
$bmp = [System.Drawing.Bitmap]::FromFile($srcPath)

# Bounding box of the central emblem (book + lightbulb + stars + cap):
# Leftmost star tip: ~365, Rightmost star tip: ~655  -> width ~ 290
# Topmost cap/star: ~78, Bottom of book: ~358       -> height ~ 280
# Emblem Center: X = 512, Y = 222
# Source crop box: 320 x 320 centered at (512, 222)
# cropX = 512 - 160 = 352, cropY = 222 - 160 = 62
$cropSize = 320
$cropX = 512 - [int]($cropSize / 2) # 352
$cropY = 222 - [int]($cropSize / 2) # 62
$cropRect = New-Object System.Drawing.Rectangle($cropX, $cropY, $cropSize, $cropSize)

$assetsDir = "d:\AI Learning\assets\images"
if (-not (Test-Path $assetsDir)) {
    New-Item -ItemType Directory -Path $assetsDir -Force | Out-Null
}

# 1. Master 1024x1024 icon
$icon1024 = New-Object System.Drawing.Bitmap(1024, 1024, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g1024 = [System.Drawing.Graphics]::FromImage($icon1024)
$g1024.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g1024.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g1024.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
# Fill with the warm background color
$bgColor = [System.Drawing.Color]::FromArgb(250, 251, 248)
$g1024.Clear($bgColor)
# Emblem drawn with generous 12% padding for adaptive icon safe-zone (bounds: 120 to 904 -> size 784)
$targetRect1024 = New-Object System.Drawing.Rectangle(120, 120, 784, 784)
$g1024.DrawImage($bmp, $targetRect1024, $cropRect, [System.Drawing.GraphicsUnit]::Pixel)
$g1024.Dispose()
$icon1024.Save("$assetsDir\curio_logo_1024.png", [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "Generated curio_logo_1024.png (1024x1024)"

# 2. App 512x512 emblem
$emblem512 = New-Object System.Drawing.Bitmap(512, 512, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g512 = [System.Drawing.Graphics]::FromImage($emblem512)
$g512.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g512.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g512.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g512.Clear($bgColor)
$targetRect512 = New-Object System.Drawing.Rectangle(48, 48, 416, 416)
$g512.DrawImage($bmp, $targetRect512, $cropRect, [System.Drawing.GraphicsUnit]::Pixel)
$g512.Dispose()
$emblem512.Save("$assetsDir\curio_logo_emblem.png", [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "Generated curio_logo_emblem.png (512x512)"

# 3. Transparent version (512x512) - seamless alpha blending
$transBmp = New-Object System.Drawing.Bitmap(512, 512, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
for ($y = 0; $y -lt 512; $y++) {
    for ($x = 0; $x -lt 512; $x++) {
        $p = $emblem512.GetPixel($x, $y)
        # Check proximity to background
        $isBg = ($p.R -ge 247 -and $p.G -ge 248 -and $p.B -ge 245)
        if ($isBg) {
            $transBmp.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(0, 0, 0, 0))
        } elseif ($p.R -ge 232 -and $p.G -ge 234 -and $p.B -ge 230) {
            # Smooth antialiasing gradient
            $dist = [Math]::Max($p.R, [Math]::Max($p.G, $p.B))
            $factor = [Math]::Max(0.0, [Math]::Min(1.0, (247 - $dist) / 15.0))
            $alpha = [int]($factor * 255)
            $transBmp.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($alpha, $p.R, $p.G, $p.B))
        } else {
            $transBmp.SetPixel($x, $y, $p)
        }
    }
}
$transBmp.Save("$assetsDir\curio_logo_transparent.png", [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "Generated curio_logo_transparent.png (512x512)"

# 4. Generate Android Mipmaps
$mipmaps = @{
    "mipmap-mdpi" = 48
    "mipmap-hdpi" = 72
    "mipmap-xhdpi" = 96
    "mipmap-xxhdpi" = 144
    "mipmap-xxxhdpi" = 192
}

foreach ($folder in $mipmaps.Keys) {
    $targetSize = $mipmaps[$folder]
    $iconBmp = New-Object System.Drawing.Bitmap($targetSize, $targetSize, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $gi = [System.Drawing.Graphics]::FromImage($iconBmp)
    $gi.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $gi.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $gi.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $gi.DrawImage($emblem512, 0, 0, $targetSize, $targetSize)
    $gi.Dispose()

    $outDir = "d:\AI Learning\android\app\src\main\res\$folder"
    if (Test-Path $outDir) {
        $iconBmp.Save("$outDir\ic_launcher.png", [System.Drawing.Imaging.ImageFormat]::Png)
        Write-Output "Generated $outDir\ic_launcher.png ($targetSize x $targetSize)"
    }
    $iconBmp.Dispose()
}

$bmp.Dispose()
$icon1024.Dispose()
$emblem512.Dispose()
$transBmp.Dispose()
Write-Output "All image dimension corrections completed successfully!"
