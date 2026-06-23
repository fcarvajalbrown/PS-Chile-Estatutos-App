# Generates the native iOS scaffolding (app/ios/) for the Flutter app WITHOUT
# touching our own lib/, assets/ or pubspec.yaml.
#
# `flutter create .` would clobber pubspec.yaml and main.dart, so instead we run
# `flutter create` into a temp folder and copy only the ios/ platform files.
# The files can be generated on Windows; the actual build/run happens on a Mac.
#
# Usage (from repo root, after installing the Flutter SDK and adding it to PATH):
#   powershell -ExecutionPolicy Bypass -File tools\scaffold_ios.ps1
#
# Use -Force to regenerate app/ios/ and app/.metadata from the current Flutter
# template. This DESTROYS the existing app/ios/ folder, so only use it when you
# want a clean slate (e.g., after a Flutter upgrade or to fix scaffolding drift).
param([switch]$Force)
$ErrorActionPreference = "Stop"

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Error "Flutter no esta en el PATH. Instala el SDK (ver README.md) y reintenta."
    exit 1
}

$root = Split-Path -Parent $PSScriptRoot
$app  = Join-Path $root "app"
$tmp  = Join-Path $env:TEMP ("ps_scaffold_ios_" + [guid]::NewGuid().ToString("N").Substring(0,8))

Write-Host "Creando esqueleto temporal en $tmp ..."
flutter create --org cl.pschile --project-name ps_estatutos --platforms=ios "$tmp" | Out-Null

# Copy only the ios/ folder; this repo already owns everything else.
$srcD = Join-Path $tmp "ios"
$dstD = Join-Path $app "ios"
if (Test-Path $srcD) {
    if ((Test-Path $dstD) -and -not $Force) {
        Write-Host "Ya existe (se omite): app\ios"
    }
    else {
        if (Test-Path $dstD) {
            Remove-Item $dstD -Recurse -Force
            Write-Host "Eliminado por -Force: app\ios"
        }
        Copy-Item $srcD $dstD -Recurse
        Write-Host "Copiado: app\ios"
    }
}

# .metadata may not exist yet if android scaffolding was skipped; copy if missing.
$srcF = Join-Path $tmp ".metadata"
$dstF = Join-Path $app ".metadata"
if (Test-Path $srcF) {
    if ((Test-Path $dstF) -and -not $Force) {
        Write-Host "Ya existe (se omite): app\.metadata"
    }
    else {
        Copy-Item $srcF $dstF
        Write-Host "Copiado: app\.metadata"
    }
}

Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "Listo. En el Mac:"
Write-Host "  cd app"
Write-Host "  flutter pub get"
Write-Host "  cd ios"
Write-Host "  pod install   (solo si el proyecto usa CocoaPods; con Swift Package Manager no es necesario)"
Write-Host "  cd .."
Write-Host "  open ios/Runner.xcworkspace   (firmar con tu Apple ID y elegir un dispositivo)"
Write-Host "  flutter run"
