Add-Type -AssemblyName System.Drawing

$src = [System.Drawing.Bitmap]::FromFile("d:\AI Learning\assets\images\curio_logo_transparent.png")

# Tight bounds from find: minX=121, maxX=413, minY=90, maxY=433
# Let's add 4px padding
$pad = 4
$cropX = [Math]::Max(0, 121 - $pad)
$cropY = [Math]::Max(0, 90 - $pad)
$cropW = [Math]::Min($src.Width - $cropX, (413 - 121) + ($pad * 2))
$cropH = [Math]::Min($src.Height - $cropY, (433 - 90) + ($pad * 2))

$cropRect = New-Object System.Drawing.Rectangle($cropX, $cropY, $cropW, $cropH)
$tightBmp = New-Object System.Drawing.Bitmap($cropW, $cropH, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($tightBmp)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.DrawImage($src, (New-Object System.Drawing.Rectangle(0, 0, $cropW, $cropH)), $cropRect, [System.Drawing.GraphicsUnit]::Pixel)
$g.Dispose()

$tightBmp.Save("d:\AI Learning\assets\images\curio_logo_mark.png", [System.Drawing.Imaging.ImageFormat]::Png)
Write-Output "Saved curio_logo_mark.png: $($cropW)x$($cropH) with zero wasted margins!"

$tightBmp.Dispose()
$src.Dispose()
