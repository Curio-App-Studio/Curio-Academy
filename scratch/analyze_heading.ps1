Add-Type -AssemblyName System.Drawing

$srcPath = "C:\Users\vivek\.gemini\antigravity\brain\c84f467a-bb93-4024-a5e5-d170bef9d128\.user_uploaded\media_1790105787600.jpg"
$bmp = [System.Drawing.Bitmap]::FromFile($srcPath)
Write-Output "Image size: $($bmp.Width) x $($bmp.Height)"

$corner = $bmp.GetPixel(5, 5)
Write-Output "Corner pixel: R=$($corner.R), G=$($corner.G), B=$($corner.B)"

$minX = $bmp.Width; $maxX = 0
$minY = $bmp.Height; $maxY = 0

for ($y = 0; $y -lt $bmp.Height; $y += 2) {
    for ($x = 0; $x -lt $bmp.Width; $x += 2) {
        $p = $bmp.GetPixel($x, $y)
        $diff = [Math]::Abs([int]$p.R - [int]$corner.R) + [Math]::Abs([int]$p.G - [int]$corner.G) + [Math]::Abs([int]$p.B - [int]$corner.B)
        if ($diff -gt 35) {
            if ($x -lt $minX) { $minX = $x }
            if ($x -gt $maxX) { $maxX = $x }
            if ($y -lt $minY) { $minY = $y }
            if ($y -gt $maxY) { $maxY = $y }
        }
    }
}

Write-Output "Full Bounding Box: minX=$minX, maxX=$maxX, minY=$minY, maxY=$maxY"
Write-Output "Content Dimensions: width=$($maxX - $minX), height=$($maxY - $minY)"
$bmp.Dispose()
