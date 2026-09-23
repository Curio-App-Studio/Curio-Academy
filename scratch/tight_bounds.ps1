Add-Type -AssemblyName System.Drawing

$src = [System.Drawing.Bitmap]::FromFile("d:\AI Learning\assets\images\curio_logo_transparent.png")
Write-Output "Source size: $($src.Width) x $($src.Height)"

$minX = $src.Width; $maxX = 0
$minY = $src.Height; $maxY = 0

for ($y = 0; $y -lt $src.Height; $y++) {
    for ($x = 0; $x -lt $src.Width; $x++) {
        $p = $src.GetPixel($x, $y)
        if ($p.A -gt 20) {
            if ($x -lt $minX) { $minX = $x }
            if ($x -gt $maxX) { $maxX = $x }
            if ($y -lt $minY) { $minY = $y }
            if ($y -gt $maxY) { $maxY = $y }
        }
    }
}

Write-Output "Tight content bounds: minX=$minX, maxX=$maxX, minY=$minY, maxY=$maxY"
$w = $maxX - $minX + 1
$h = $maxY - $minY + 1
Write-Output "Tight content size: ${w}w x ${h}h (aspect ratio: $([double]$w / $h))"

$src.Dispose()
