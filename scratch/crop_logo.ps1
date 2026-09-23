Add-Type -AssemblyName System.Drawing

$srcPath = "C:\Users\vivek\.gemini\antigravity\brain\c84f467a-bb93-4024-a5e5-d170bef9d128\.user_uploaded\media_1790105597613.jpg"
$bmp = [System.Drawing.Bitmap]::FromFile($srcPath)

# Bounding box found: minX=408, maxX=632, minY=96, maxY=356
# Center is (520, 226)
# Emblem size is 224w x 260h
# We want a square crop with balanced padding around the emblem
$size = 330
$cropX = 520 - [int]($size / 2) # 355
$cropY = 226 - [int]($size / 2) # 61

Write-Output "Crop rect: X=$cropX, Y=$cropY, W=$size, H=$size"

# Ensure output directory exists
$assetsDir = "d:\AI Learning\assets\images"
if (-not (Test-Path $assetsDir)) {
    New-Item -ItemType Directory -Path $assetsDir -Force | Out-Null
}

# 1. High-res square crop (512x512) with original background
$cropRect = New-Object System.Drawing.Rectangle($cropX, $cropY, $size, $size)
$destBmp512 = New-Object System.Drawing.Bitmap(512, 512, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($destBmp512)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.DrawImage($bmp, (New-Object System.Drawing.Rectangle(0, 0, 512, 512)), $cropRect, [System.Drawing.GraphicsUnit]::Pixel)
$g.Dispose()

$destBmp512.Save("$assetsDir\curio_logo_emblem.png", [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "Saved curio_logo_emblem.png (512x512)"

# 2. Transparent version: detect background and apply smooth alpha
$transBmp = New-Object System.Drawing.Bitmap(512, 512, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
# Background corner reference color: R=250, G=251, B=246
for ($y = 0; $y -lt 512; $y++) {
    for ($x = 0; $x -lt 512; $x++) {
        $p = $destBmp512.GetPixel($x, $y)
        # Calculate color difference from near-white background
        # Background is roughly > 240 in all channels and near gray/cream
        $isBg = ($p.R -ge 245 -and $p.G -ge 245 -and $p.B -ge 240)
        if ($isBg) {
            # Completely transparent
            $transBmp.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(0, 0, 0, 0))
        } elseif ($p.R -ge 230 -and $p.G -ge 230 -and $p.B -ge 225) {
            # Soft edge antialiasing
            $factor = [Math]::Max(0.0, [Math]::Min(1.0, (245 - [Math]::Max($p.R, [Math]::Max($p.G, $p.B))) / 15.0))
            $alpha = [int]($factor * 255)
            $transBmp.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($alpha, $p.R, $p.G, $p.B))
        } else {
            $transBmp.SetPixel($x, $y, $p)
        }
    }
}
$transBmp.Save("$assetsDir\curio_logo_transparent.png", [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "Saved curio_logo_transparent.png (512x512)"

# 3. Android mipmap icons
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
    $gi.DrawImage($destBmp512, 0, 0, $targetSize, $targetSize)
    $gi.Dispose()

    $outDir = "d:\AI Learning\android\app\src\main\res\$folder"
    if (Test-Path $outDir) {
        $iconBmp.Save("$outDir\ic_launcher.png", [System.Drawing.Imaging.ImageFormat]::Png)
        Write-Output "Saved $outDir\ic_launcher.png ($targetSize x $targetSize)"
    }
    $iconBmp.Dispose()
}

$destBmp512.Dispose()
$transBmp.Dispose()
$bmp.Dispose()
Write-Output "All icons successfully created!"
