Add-Type -AssemblyName System.Drawing

$srcImg = [System.Drawing.Bitmap]::FromFile("d:\AI Learning\assets\images\curio_heading_transparent.png")

# Emblem is on the left: from x=0 to x=240, height=266
$emblemCrop = New-Object System.Drawing.Rectangle(0, 0, 240, 266)

# Create an 800 x 266 canvas
$outBmp = New-Object System.Drawing.Bitmap(820, 266, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($outBmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

# Draw emblem
$g.DrawImage($srcImg, (New-Object System.Drawing.Rectangle(0, 0, 240, 266)), $emblemCrop, [System.Drawing.GraphicsUnit]::Pixel)

# Find a nice font: Poppins, Montserrat, Segoe UI, Arial
$fontName = "Segoe UI"
$fonts = [System.Drawing.FontFamily]::Families
foreach ($f in $fonts) {
    if ($f.Name -eq "Montserrat" -or $f.Name -eq "Poppins") {
        $fontName = $f.Name
        break
    }
}

$titleFont = New-Object System.Drawing.Font($fontName, 52, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
# Color sampled from original image: #4A6572 / #3C5A71
$titleBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 60, 90, 115))
$g.DrawString("Curio Academy", $titleFont, $titleBrush, 260, 72)

$tagFont = New-Object System.Drawing.Font($fontName, 28, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$tagBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 90, 115, 142))
$g.DrawString("Spark Your Potential", $tagFont, $tagBrush, 264, 148)

$g.Dispose()
$titleBrush.Dispose()
$tagBrush.Dispose()
$titleFont.Dispose()
$tagFont.Dispose()
$srcImg.Dispose()

$outBmp.Save("d:\AI Learning\assets\images\curio_heading_logo.png", [System.Drawing.Imaging.ImageFormat]::Png)
$outBmp.Dispose()
Write-Output "Successfully generated curio_heading_logo.png!"
