# Generates the native Flutter scaffolding (android/, .metadata, etc.) for the
# app WITHOUT overwriting our own lib/, assets/ or pubspec.yaml.
#
# `flutter create .` would clobber pubspec.yaml and main.dart, so instead we run
# `flutter create` into a temp folder and copy only the missing platform files.
#
# Usage (from repo root, after installing the Flutter SDK and adding it to PATH):
#   powershell -ExecutionPolicy Bypass -File tools\scaffold.ps1
$ErrorActionPreference = "Stop"

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Error "Flutter no esta en el PATH. Instala el SDK (ver README.md) y reintenta."
    exit 1
}

$root = Split-Path -Parent $PSScriptRoot
$app  = Join-Path $root "app"
$tmp  = Join-Path $env:TEMP ("ps_scaffold_" + [guid]::NewGuid().ToString("N").Substring(0,8))

Write-Host "Creando esqueleto temporal en $tmp ..."
flutter create --org cl.pschile --project-name ps_estatutos --platforms=android "$tmp" | Out-Null

# Copy only platform / tooling files that this repo does not already own.
$copyDirs  = @("android")
$copyFiles = @(".metadata", "analysis_options.yaml")

foreach ($d in $copyDirs) {
    $srcD = Join-Path $tmp $d
    $dstD = Join-Path $app $d
    if (Test-Path $srcD) {
        if (Test-Path $dstD) { Write-Host "Ya existe (se omite): app\$d" }
        else { Copy-Item $srcD $dstD -Recurse; Write-Host "Copiado: app\$d" }
    }
}
foreach ($f in $copyFiles) {
    $srcF = Join-Path $tmp $f
    $dstF = Join-Path $app $f
    if ((Test-Path $srcF) -and -not (Test-Path $dstF)) {
        Copy-Item $srcF $dstF; Write-Host "Copiado: app\$f"
    }
}

Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "Listo. Ahora:"
Write-Host "  cd app"
Write-Host "  flutter pub get"
Write-Host "  flutter run        (con emulador o telefono conectado)"
Write-Host ""
Write-Host "Recuerda fijar el nombre visible de la app en"
Write-Host "  app\android\app\src\main\AndroidManifest.xml  (android:label=\"Estatutos PS\")"
