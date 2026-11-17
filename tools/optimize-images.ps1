# Recompress media images: cap long edge at 1800px, re-encode WebP q80 / JPEG q3.
# Originals are backed up to source/images-backup-20261117.
$srcDir = 'E:\作品集\作品集网页\media'
$bakDir = 'E:\作品集\作品集网页\source\images-backup-20261117'
$tmpDir = 'E:\作品集\作品集网页\_check\opt'
New-Item -ItemType Directory -Force $bakDir | Out-Null
New-Item -ItemType Directory -Force $tmpDir | Out-Null

$files = Get-ChildItem $srcDir -File | Where-Object { ($_.Extension -eq '.webp' -or $_.Extension -eq '.jpg') -and $_.Length -gt 120KB }
$before = 0; $after = 0; $changed = 0; $kept = 0

foreach ($f in $files) {
  $probe = & ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 $f.FullName
  $parts = ($probe -split ',')
  $w = [int]$parts[0]; $h = [int]$parts[1]
  $long = [Math]::Max($w, $h)

  $out = Join-Path $tmpDir $f.Name
  $fargs = @('-y', '-loglevel', 'error', '-i', $f.FullName)
  if ($long -gt 1800) {
    if ($w -ge $h) { $fargs += @('-vf', 'scale=1800:-2') } else { $fargs += @('-vf', 'scale=-2:1800') }
  }
  if ($f.Extension -eq '.webp') {
    $fargs += @('-c:v', 'libwebp', '-quality', '80', '-compression_level', '6')
  } else {
    $fargs += @('-c:v', 'mjpeg', '-q:v', '3', '-huffman', 'optimal', '-pix_fmt', 'yuvj420p')
  }
  $fargs += $out
  & ffmpeg @fargs 2>$null

  if ((Test-Path $out) -and ((Get-Item $out).Length -lt $f.Length * 0.92)) {
    Copy-Item $f.FullName $bakDir -Force
    Move-Item -Force $out $f.FullName
    $before += $f.Length
    $after += (Get-Item $f.FullName).Length
    $changed++
  } else {
    Remove-Item -Force $out -ErrorAction SilentlyContinue
    $kept++
  }
}

Write-Output ("Changed {0} files, kept {1}. {2:N1} MB -> {3:N1} MB (saved {4:N1} MB)" -f $changed, $kept, ($before/1MB), ($after/1MB), (($before-$after)/1MB))
$imgs = Get-ChildItem $srcDir -File | Where-Object { $_.Extension -eq '.webp' -or $_.Extension -eq '.jpg' }
Write-Output ("All images now: {0} files, {1:N1} MB" -f $imgs.Count, ((($imgs | Measure-Object Length -Sum).Sum)/1MB))
