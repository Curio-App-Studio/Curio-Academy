Add-Type -AssemblyName System.Drawing

$emblemPath = "d:\AI Learning\assets\images\curio_logo_transparent.png"
$emblem = [System.Drawing.Bitmap]::FromFile($emblemPath)

# We want a high-res banner: 800 x 260
$bannerW = 820
$bannerH = 260
$bmp = New-Object System.Drawing.Bitmap($bannerW, $bannerH, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)

$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

# Draw Emblem on the left: size 230 x 230
$emblemRect = New-Object System.Drawing.Rectangle(10, 15, 230, 230)
$g.DrawImage($emblem, $emblemRect)

# Draw "Curio Academy"
$titleFont = New-Object System.Drawing.Font("Segoe UI", 48, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$titleBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 68, 98, 122)) # #44627A
$g.DrawString("Curio Academy", $titleFont, $titleBrush, 260, 68)

# Draw "Spark Your Potential"
$tagFont = New-Object System.Drawing.Font("Segoe UI Semibold", 28, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$tagBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 98, 125, 152)) # #627D98
$g.DrawString("Spark Your Potential", $tagFont, $tagBrush, 264, 138)

$g.Dispose()
$titleBrush.Dispose()
$tagBrush.Dispose()
$titleFont.Dispose()
$tagFont.Dispose()
$emblem.Dispose()

$bmp.Save("d:\AI Learning\assets\images\curio_brand_banner.png", [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output "Generated curio_brand_banner.png with correct spelling!"
