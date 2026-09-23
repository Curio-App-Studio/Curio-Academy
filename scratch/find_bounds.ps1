Add-Type -AssemblyName System.Drawing

$srcPath = "C:\Users\vivek\.gemini\antigravity\brain\c84f467a-bb93-4024-a5e5-d170bef9d128\.user_uploaded\media_1790105597613.jpg"
$bmp = [System.Drawing.Bitmap]::FromFile($srcPath)

$corner = $bmp.GetPixel(5, 5)
Write-Output "Corner pixel: R=$($corner.R), G=$($corner.G), B=$($corner.B)"

$minX = $bmp.Width
$maxX = 0
$minY = $bmp.Height
$maxY = 0

for ($y = 0; $y -lt $bmp.Height; $y++) {
    for ($x = 0; $x -lt $bmp.Width; $x++) {
        $p = $bmp.GetPixel($x, $y)
        $diff = [Math]::Abs([int]$p.R - [int]$corner.R) + [Math]::Abs([int]$p.G - [int]$corner.G) + [Math]::Abs([int]$p.B - [int]$corner.B)
        # Using a sensitive threshold to catch all tips of stars and sparkles
        if ($diff -gt 12) {
            if ($x -lt $minX) { $minX = $x }
            if ($x -gt $maxX) { $maxX = $x }
            if ($y -lt $minY) { $minY = $y }
            if ($y -gt $maxY) { $maxY = $y }
        }
    }
}

Write-Output "Full bounds (including stars): minX=$minX, maxX=$maxX, minY=$minY, maxY=$maxY"
$width = $maxX - $minX
$height = $maxY - $minY
$centerX = [int](($minX + $maxX) / 2)
$centerY = [int](($minY + $maxY) / 2)

Write-Output "Content size: ${width}w x ${height}h, center=($centerX, $centerY)"
$bmp.Dispose()
