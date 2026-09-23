Add-Type -AssemblyName System.Drawing

$bmp = [System.Drawing.Bitmap]::FromFile("d:\AI Learning\assets\images\curio_heading_transparent.png")
Write-Output "Heading image size: $($bmp.Width) x $($bmp.Height)"

# Find where text begins on the X axis
# Emblem is on the left (x: 0 to ~250)
# Gap is ~250 to ~270
# Text "Curio Acadmy" is on the right
for ($x = 240; $x -lt 320; $x += 5) {
    $hasPixel = $false
    for ($y = 0; $y -lt $bmp.Height; $y += 2) {
        $p = $bmp.GetPixel($x, $y)
        if ($p.A -gt 50) { $hasPixel = $true; break }
    }
    Write-Output "x=$x hasPixel=$hasPixel"
}
$bmp.Dispose()
