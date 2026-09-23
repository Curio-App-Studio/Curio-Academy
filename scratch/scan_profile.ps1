Add-Type -AssemblyName System.Drawing

$srcPath = "C:\Users\vivek\.gemini\antigravity\brain\c84f467a-bb93-4024-a5e5-d170bef9d128\.user_uploaded\media_1790105597613.jpg"
$bmp = [System.Drawing.Bitmap]::FromFile($srcPath)
$corner = $bmp.GetPixel(5, 5)

$colMaxDiff = New-Object 'int[]' $bmp.Width
$rowMaxDiff = New-Object 'int[]' $bmp.Height

for ($y = 0; $y -lt $bmp.Height; $y += 2) {
    for ($x = 0; $x -lt $bmp.Width; $x += 2) {
        $p = $bmp.GetPixel($x, $y)
        $diff = [Math]::Abs([int]$p.R - [int]$corner.R) + [Math]::Abs([int]$p.G - [int]$corner.G) + [Math]::Abs([int]$p.B - [int]$corner.B)
        if ($diff -gt $colMaxDiff[$x]) { $colMaxDiff[$x] = $diff }
        if ($diff -gt $rowMaxDiff[$y]) { $rowMaxDiff[$y] = $diff }
    }
}

Write-Output "--- Significant columns (diff > 25) ---"
$firstCol = 0
$lastCol = 0
for ($x = 0; $x -lt $bmp.Width; $x += 2) {
    if ($colMaxDiff[$x] -gt 25) {
        if ($firstCol -eq 0) { $firstCol = $x }
        $lastCol = $x
    }
}
Write-Output "First col > 25: $firstCol, Last col > 25: $lastCol"

Write-Output "--- Significant rows (diff > 25) ---"
$firstRow = 0
$lastRow = 0
for ($y = 0; $y -lt $bmp.Height; $y += 2) {
    if ($rowMaxDiff[$y] -gt 25) {
        if ($firstRow -eq 0) { $firstRow = $y }
        $lastRow = $y
    }
}
Write-Output "First row > 25: $firstRow, Last row > 25: $lastRow"

$bmp.Dispose()
