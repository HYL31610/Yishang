# 把任意图片压成适合模型查看的小尺寸 JPEG，并输出临时文件路径。
# 用法: powershell -File tools/view-image.ps1 -Path "E:\...\xxx.png"
param(
  [Parameter(Mandatory = $true)][string]$Path,
  [int]$MaxWidth = 1000,
  [int]$MaxHeight = 2500,
  [int]$Quality = 70
)

Add-Type -AssemblyName System.Drawing

$resolved = (Resolve-Path -LiteralPath $Path).Path
$img = [System.Drawing.Image]::FromFile($resolved)
try {
  $scale = [Math]::Min([Math]::Min(1.0, $MaxWidth / $img.Width), $MaxHeight / $img.Height)
  $w = [Math]::Max(1, [int][Math]::Round($img.Width * $scale))
  $h = [Math]::Max(1, [int][Math]::Round($img.Height * $scale))

  $bmp = New-Object System.Drawing.Bitmap $w, $h
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.DrawImage($img, 0, 0, $w, $h)
  $g.Dispose()

  $out = Join-Path $env:TEMP ("view_" + [guid]::NewGuid().ToString('N').Substring(0, 8) + ".jpg")
  $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
    Where-Object { $_.MimeType -eq 'image/jpeg' } | Select-Object -First 1
  $ep = New-Object System.Drawing.Imaging.EncoderParameters 1
  $ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality, [long]$Quality)

  $bmp.Save($out, $codec, $ep)
  $bmp.Dispose()

  $kb = [Math]::Round((Get-Item $out).Length / 1KB, 1)
  Write-Output $out
  Write-Output ("({0}x{1}, {2} KB)" -f $w, $h, $kb)
}
finally {
  $img.Dispose()
}
