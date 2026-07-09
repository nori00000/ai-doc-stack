#requires -version 5.1
# Environment verification — Windows / PowerShell version of verify.sh

$ErrorActionPreference = "Continue"
$failed = $false

function Ok($m)   { Write-Host "  $([char]0x2713)  $m" -ForegroundColor Green }
function Miss($m) { Write-Host "  $([char]0x2717)  $m" -ForegroundColor Red; $script:failed = $true }
function Info($m) { Write-Host "     $m" -ForegroundColor DarkGray }

Write-Host ""
Write-Host "== ai-doc-stack environment check ==" -ForegroundColor Cyan
Write-Host ""

# Runtimes
if (Get-Command node -EA SilentlyContinue) { Ok "Node.js: $(node --version)" } else { Miss "Node.js missing" }
$pyExe = (Get-Command python -EA SilentlyContinue).Source
if ($pyExe -and -not $pyExe.EndsWith("WindowsApps\python.exe")) {
    Ok "Python: $(& python --version 2>&1)"
} else {
    Miss "Python missing (or only the WindowsApps stub) — install via mise or winget Python.Python.3.12"
}
if (Get-Command npm -EA SilentlyContinue) { Ok "npm: $(npm --version)" } else { Miss "npm missing" }

# Helper tools
$ffmpeg = Get-Command ffmpeg -EA SilentlyContinue
if ($ffmpeg) { Ok "FFmpeg: $((& ffmpeg -version 2>&1 | Select-Object -First 1).ToString().Split(' ')[2])" }
else {
    # Try winget cache fallback
    $cache = Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages\Gyan.FFmpeg*\ffmpeg-*\bin\ffmpeg.exe" -EA SilentlyContinue | Select-Object -First 1
    if ($cache) { Ok "FFmpeg: at $($cache.FullName) (open new shell to put on PATH)" }
    else { Miss "FFmpeg missing" }
}
if (Get-Command pdftoppm -EA SilentlyContinue) { Ok "Poppler: $((& pdftoppm -v 2>&1 | Select-Object -First 1).ToString())" } else { Miss "Poppler missing" }
$soffice = "$env:ProgramFiles\LibreOffice\program\soffice.com"
if (Test-Path $soffice) { Ok "LibreOffice: $((& $soffice --version 2>&1).ToString())" } else { Miss "LibreOffice missing" }

# Python packages
Write-Host ""
Write-Host "  -- Python packages --" -ForegroundColor Cyan
$pyScript = @'
import importlib, sys
mods = ["pptx","pdf2image","markitdown","numpy","mammoth","markdownify",
        "bs4","requests","openpyxl","fitz","playwright","pydantic",
        "svglib","reportlab"]
missing = []
for m in mods:
    try:
        importlib.import_module(m)
        print(f"     OK   {m}")
    except Exception:
        print(f"     MISS {m}")
        missing.append(m)
sys.exit(1 if missing else 0)
'@
$pyScript | & python -
if ($LASTEXITCODE -ne 0) { $failed = $true }

# Claude skills
Write-Host ""
Write-Host "  -- Claude Code skills --" -ForegroundColor Cyan
$skillsDir = "$env:USERPROFILE\.claude\skills"
if (Test-Path $skillsDir) {
    $count = (Get-ChildItem $skillsDir -Directory).Count
    Ok "$skillsDir ($count skills)"
} else {
    Miss "$skillsDir not present (run 'claude' once)"
}

Write-Host ""
if (-not $failed) {
    Write-Host "$([char]0x2713) All checks passed." -ForegroundColor Green
} else {
    Write-Host "$([char]0x2717) Some checks failed — see above." -ForegroundColor Red
    exit 1
}
