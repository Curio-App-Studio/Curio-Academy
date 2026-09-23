Add-Type -AssemblyName System.Drawing

$srcPath = "C:\Users\vivek\.gemini\antigravity\brain\c84f467a-bb93-4024-a5e5-d170bef9d128\.user_uploaded\media_1790105787600.jpg"
$bmp = [System.Drawing.Bitmap]::FromFile($srcPath)

# Bounding box: minX=210, maxX=858, minY=168, maxY=394
# Let's add nice padding: 20px all around
$padding = 20
$cropX = [Math]::Max(0, 210 - $padding)
$cropY = [Math]::Max(0, 168 - $padding)
$cropW = [Math]::Min($bmp.Width - $cropX, (858 - 210) + ($padding * 2))
$cropH = [Math]::Min($bmp.Height - $cropY, (394 - 168) + ($padding * 2))

Write-Output "Crop rect: X=$cropX, Y=$cropY, W=$cropW, H=$cropH"

$cropRect = New-Object System.Drawing.Rectangle($cropX, $cropY, $cropW, $cropH)
$destBmp = New-Object System.Drawing.Bitmap($cropW, $cropH, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($destBmp)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.DrawImage($bmp, (New-Object System.Drawing.Rectangle(0, 0, $cropW, $cropH)), $cropRect, [System.Drawing.GraphicsUnit]::Pixel)
$g.Dispose()

# Make transparent
$transBmp = New-Object System.Drawing.Bitmap($cropW, $cropH, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
for ($y = 0; $y -lt $cropH; $y++) {
    for ($x = 0; $x -lt $cropW; $x++) {
        $p = $destBmp.GetPixel($x, $y)
        $isBg = ($p.R -ge 245 -and $p.G -ge 246 -and $p.B -ge 242)
        if ($isBg) {
            $transBmp.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(0, 0, 0, 0))
        } elseif ($p.R -ge 230 -and $p.G -ge 230 -and $p.B -ge 225) {
            $dist = [Math]::Max($p.R, [Math]::Max($p.G, $p.B))
            $factor = [Math]::Max(0.0, [Math]::Min(1.0, (245 - $dist) / 15.0))
            $alpha = [int]($factor * 255)
            $transBmp.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($alpha, $p.R, $p.G, $p.B))
        } else {
            $transBmp.SetPixel($x, $y, $p)
        }
    }
}

$assetsDir = "d:\AI Learning\assets\images"
$destBmp.Save("$assetsDir\curio_heading_original_bg.png", [System.Drawing.Imaging.ImageFormat]::Png)
$transBmp.Save("$assetsDir\curio_heading_transparent.png", [System.Drawing.Imaging.ImageFormat]::Png)

$destBmp.Dispose()
$transBmp.Dispose()
$bmp.Dispose()
Write-Output "Successfully generated curio_heading_transparent.png!"
