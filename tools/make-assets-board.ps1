Add-Type -AssemblyName System.Drawing

$W = 1800
$H = 1620
$margin = 90
$gap = 24
$cellW = 524
$cellH = 366
$radius = 8

$imgDir = 'E:\作品集\特效'
$outPng = 'E:\作品集\作品集网页\media\texiao-assets.png'

$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

# background
$bgBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(239, 235, 228))
$g.FillRectangle($bgBrush, 0, 0, $W, $H)

$cDark = [System.Drawing.Color]::FromArgb(33, 29, 24)
$cMid = [System.Drawing.Color]::FromArgb(122, 114, 102)
$cLine = [System.Drawing.Color]::FromArgb(214, 207, 194)
$cBorder = [System.Drawing.Color]::FromArgb(216, 210, 200)

$fam = New-Object System.Drawing.FontFamily('Microsoft YaHei')
$fTitle = New-Object System.Drawing.Font($fam, 42, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fSub = New-Object System.Drawing.Font($fam, 21, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$fNum = New-Object System.Drawing.Font($fam, 17, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$fSec = New-Object System.Drawing.Font($fam, 27, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fSecEn = New-Object System.Drawing.Font($fam, 17, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$fCap = New-Object System.Drawing.Font($fam, 21, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)

$bDark = New-Object System.Drawing.SolidBrush($cDark)
$bMid = New-Object System.Drawing.SolidBrush($cMid)
$penLine = New-Object System.Drawing.Pen($cLine, 1)
$penBorder = New-Object System.Drawing.Pen($cBorder, 1)

# header
$g.DrawString('特效制作 · 资产设定', $fTitle, $bDark, 88, 56)
$g.DrawString('ASSET DESIGN   ·   人物 / 道具 / 场景', $fSub, $bMid, 92, 122)
$g.DrawLine($penLine, $margin, 158, $W - $margin, 158)

$sections = @(
  @{ num='01'; zh='人物资产'; en='CHARACTERS'; y=176; items=@(
      @{ file='银发冷俊古代剑客.png'; cap='银发剑士 · 角色设定'; anchor=0.10 },
      @{ file='贵族少年站姿四视图.png'; cap='贵族少年 · 四视图设定'; anchor=0.50 },
      @{ file='郑夏恩.png'; cap='少女 · 角色设定'; anchor=0.10 }
    )},
  @{ num='02'; zh='道具资产'; en='PROPS'; y=654; items=@(
      @{ file='剑.png'; cap='长剑 · 紫晶能量'; anchor=0.50 },
      @{ file='狂暴奇幻长枪特写.png'; cap='长枪 · 猩红暗铁'; anchor=0.50 },
      @{ file='悬浮奇幻战弓.png'; cap='战弓 · 白金羽刃'; anchor=0.50 }
    )},
  @{ num='03'; zh='场景资产'; en='ENVIRONMENTS'; y=1132; items=@(
      @{ file='奇幻史诗场景图.png'; cap='史诗城邦 · 场景概念'; anchor=0.50 },
      @{ file='远古遗迹巨兽头骨.png'; cap='远古遗迹 · 场景概念'; anchor=0.50 },
      @{ file='弓场景.png'; cap='都市天台 · 场景概念'; anchor=0.50 }
    )}
)

function Add-RoundedRect($path, [float]$x, [float]$y, [float]$w, [float]$h, [float]$r) {
  $d = $r * 2
  $path.AddArc($x, $y, $d, $d, 180, 90)
  $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
  $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
  $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
  $path.CloseFigure()
}

foreach ($sec in $sections) {
  $sy = $sec.y
  $g.DrawString($sec.num, $fNum, $bMid, $margin, $sy + 8)
  $g.DrawString($sec.zh, $fSec, $bDark, $margin + 34, $sy + 2)
  $zhW = $g.MeasureString($sec.zh, $fSec).Width
  $g.DrawString($sec.en, $fSecEn, $bMid, $margin + 34 + $zhW + 14, $sy + 12)

  $iy = $sy + 42
  for ($i = 0; $i -lt 3; $i++) {
    $it = $sec.items[$i]
    $ix = $margin + $i * ($cellW + $gap)
    $srcPath = Join-Path $imgDir $it.file
    $src = [System.Drawing.Image]::FromFile($srcPath)
    try {
      $scale = [Math]::Max($cellW / $src.Width, $cellH / $src.Height)
      $sw = $cellW / $scale
      $sh = $cellH / $scale
      $sx = ($src.Width - $sw) / 2
      $sy2 = ($src.Height - $sh) * [double]$it.anchor

      $path = New-Object System.Drawing.Drawing2D.GraphicsPath
      Add-RoundedRect $path $ix $iy $cellW $cellH $radius
      $oldClip = $g.Clip
      $g.SetClip($path)
      $destRect = New-Object System.Drawing.RectangleF($ix, $iy, $cellW, $cellH)
      $srcRect = New-Object System.Drawing.RectangleF([float]$sx, [float]$sy2, [float]$sw, [float]$sh)
      $g.DrawImage($src, $destRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
      $g.ResetClip()
      $g.DrawPath($penBorder, $path)
      $path.Dispose()

      $g.DrawString($it.cap, $fCap, $bMid, $ix + 2, $iy + $cellH + 10)
    } finally {
      $src.Dispose()
    }
  }
}

$bmp.Save($outPng, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()
Write-Output ("Saved: {0} ({1:N0} KB)" -f $outPng, ((Get-Item $outPng).Length / 1KB))
