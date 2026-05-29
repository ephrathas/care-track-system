# Downloads Unsplash JPEGs into assets/images/products/ (same base names as .svg).
# Run from project root: powershell -ExecutionPolicy Bypass -File scripts/download_product_images.ps1

$dir = Join-Path $PSScriptRoot "..\assets\images\products"
New-Item -ItemType Directory -Force -Path $dir | Out-Null

$pairs = @(
  @("school_starter_kit.jpg", "https://images.unsplash.com/photo-1588072432836-e345f2c79d54?w=480&q=80"),
  @("classic_polo_uniform.jpg", "https://images.unsplash.com/photo-1519238263530-7522f504fee8?w=480&q=80"),
  @("stem_activity_pack.jpg", "https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=480&q=80"),
  @("vitamin_gummies.jpg", "https://images.unsplash.com/photo-1550572017-edd226bffa55?w=480&q=80"),
  @("reading_adventure_set.jpg", "https://images.unsplash.com/photo-1512820790803-83ca734da794?w=480&q=80"),
  @("art_craft_box.jpg", "https://images.unsplash.com/photo-1513364776144-60967b33f800?w=480&q=80"),
  @("promo_back_to_school.jpg", "https://images.unsplash.com/photo-1503676260728-1c00da280a02?w=720&q=80")
)

foreach ($pair in $pairs) {
  $out = Join-Path $dir $pair[0]
  Write-Host "Downloading $($pair[0])..."
  Invoke-WebRequest -Uri $pair[1] -OutFile $out -UseBasicParsing
}

Get-ChildItem $dir -Filter *.jpg | Format-Table Name, Length
