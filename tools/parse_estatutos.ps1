# Parses source/estatutos_clean.txt (verbatim PS Chile statute text) into a
# structured JSON asset for the Flutter app. Run from repo root:
#   powershell -ExecutionPolicy Bypass -File tools\parse_estatutos.ps1
#
# Source is pure ASCII: accented regex characters are built from char codes at
# runtime so Windows PowerShell 5.1 (which reads .ps1 as ANSI) cannot corrupt
# them. Statute content is read from the UTF-8 text file and kept verbatim.
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$src  = Join-Path $root "source\estatutos_clean.txt"
$out  = Join-Path $root "app\assets\data\estatutos.json"
New-Item -ItemType Directory -Force (Split-Path $out) | Out-Null

# NOTE: PowerShell variable names are case-insensitive, so these must be
# spelled distinctly (not $Ia / $ia, which would collide).
$upperI = [char]0x00CD   # I acute  (TITULO)
$lowerI = [char]0x00ED   # i acute  (Articulo)
$ordfem = [char]0x00BA   # masculine ordinal (1o)
$reTitulo  = "^T${upperI}TULO\s+([IVXLC]+)(.*)`$"
$reArt     = "^Art${lowerI}culo\s+(\d+${ordfem}?(?:\s*bis)?|final)`$"
$reArtTran = "^Art${lowerI}culo\s+(primero|segundo|tercero|cuarto)\.?\s*[" + ([char]0x2013) + ([char]0x2014) + "-]?\s*(.*)`$"

function Clean([string]$s) {
    $s = $s -replace 'procedimiento descrito 9 en', 'procedimiento descrito en'
    $s = $s -replace '; 14 desde 5\.001', '; desde 5.001'
    $s = $s -replace '\s+', ' '
    return $s.Trim()
}

$lines = Get-Content $src -Encoding utf8
$titles = New-Object System.Collections.ArrayList
$curTitle = $null
$curArticle = $null
$inTransitorias = $false

foreach ($raw in $lines) {
    $line = $raw.Trim()
    if ($line -eq "") { continue }

    if ($line -match '^DISPOSICIONES TRANSITORIAS') {
        if ($curArticle) { [void]$curTitle.articles.Add($curArticle); $curArticle = $null }
        if ($curTitle)   { [void]$titles.Add($curTitle) }
        $curTitle = [pscustomobject]@{ roman=""; heading="Disposiciones Transitorias"; articles=(New-Object System.Collections.ArrayList) }
        $inTransitorias = $true
        continue
    }

    if (-not $inTransitorias) {
        $m = [regex]::Match($line, $reTitulo)
        if ($m.Success) {
            if ($curArticle) { [void]$curTitle.articles.Add($curArticle); $curArticle = $null }
            if ($curTitle)   { [void]$titles.Add($curTitle) }
            $curTitle = [pscustomobject]@{ roman=$m.Groups[1].Value; heading=(Clean $m.Groups[2].Value); articles=(New-Object System.Collections.ArrayList) }
            continue
        }
        $am = [regex]::Match($line, $reArt)
        if ($am.Success) {
            if ($curArticle) { [void]$curTitle.articles.Add($curArticle) }
            $num = ($am.Groups[1].Value -replace $ordfem,'') -replace '\s+',' '
            $curArticle = [pscustomobject]@{ number=$num.Trim(); heading=""; paragraphs=(New-Object System.Collections.ArrayList) }
            continue
        }
        if ($curArticle) {
            if ($curArticle.paragraphs.Count -eq 0 -and $curArticle.heading -eq "" -and $line.Length -lt 70 -and $line -notmatch '[.:]$' -and $line -match '^(De|Del|La|El|Iniciativa)\b') {
                $curArticle.heading = (Clean $line)
            } else {
                [void]$curArticle.paragraphs.Add((Clean $line))
            }
        } elseif ($curTitle) {
            if ($curTitle.heading -eq "") { $curTitle.heading = (Clean $line) }
            else { $curTitle.heading = (Clean ($curTitle.heading + " " + $line)) }
        }
        continue
    }

    $tm = [regex]::Match($line, $reArtTran)
    if ($tm.Success) {
        if ($curArticle) { [void]$curTitle.articles.Add($curArticle) }
        $curArticle = [pscustomobject]@{ number=$tm.Groups[1].Value; heading=""; paragraphs=(New-Object System.Collections.ArrayList) }
        $body = $tm.Groups[2].Value.Trim()
        if ($body -ne "") { [void]$curArticle.paragraphs.Add((Clean $body)) }
        continue
    }
    if ($curArticle) { [void]$curArticle.paragraphs.Add((Clean $line)) }
}
if ($curArticle) { [void]$curTitle.articles.Add($curArticle) }
if ($curTitle)   { [void]$titles.Add($curTitle) }

$doc = [pscustomobject]@{
    title   = "Estatutos del Partido Socialista de Chile"
    source  = "https://www.pschile.cl/estatutos/"
    updated = "2026-05-19"
    titles  = $titles
}
($doc | ConvertTo-Json -Depth 8) | Out-File $out -Encoding utf8
"Titulos: $($titles.Count)"
$artCount = ($titles | ForEach-Object { $_.articles.Count } | Measure-Object -Sum).Sum
"Articulos totales: $artCount"
foreach ($t in $titles) { "  T{0,-5} {1}  [{2} art]" -f $t.roman, $t.heading, $t.articles.Count }
"JSON: $out"
