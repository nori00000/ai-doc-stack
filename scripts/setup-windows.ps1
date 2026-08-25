#requires -version 5.1
<#
.SYNOPSIS
    ai-doc-stack — Windows setup script
.DESCRIPTION
    Installs runtimes (via mise), helper tools (FFmpeg, Poppler, LibreOffice),
    Python packages, and Playwright Chromium. One-time setup.
#>

$ErrorActionPreference = "Stop"
$Host.UI.RawUI.WindowTitle = "ai-doc-stack setup"

function Section($name) { Write-Host "`n== $name ==" -ForegroundColor Cyan }
function Step($msg)    { Write-Host "  $msg" -ForegroundColor White }
function Ok($msg)      { Write-Host "  $msg" -ForegroundColor Green }
function Warn($msg)    { Write-Host "  $msg" -ForegroundColor Yellow }

# --- 1. mise (runtime version manager) ---
Section "mise (runtime version manager)"
if (-not (Get-Command mise -ErrorAction SilentlyContinue)) {
    Step "Installing mise via winget..."
    winget install jdx.mise --silent --accept-source-agreements --accept-package-agreements
    Warn "Open a NEW PowerShell after this script finishes, then re-run 'mise install'."
} else {
    Ok "mise already installed: $((mise --version) -join ' ')"
}

# --- 2. Runtimes (Node, Python) via mise ---
Section "Runtimes (Node, Python via mise)"
if (Get-Command mise -ErrorAction SilentlyContinue) {
    Step "Reading .tool-versions and installing..."
    mise install
    Ok "Node $(node --version) / Python $((python --version) -join ' ')"
} else {
    Warn "mise not on PATH yet — re-run this script after opening a new shell."
}

# --- 3. Helper tools (winget) ---
Section "Helper tools (FFmpeg, Poppler, LibreOffice)"
$winget_pkgs = @(
    @{ Id = 'Gyan.FFmpeg.Essentials'; Name = 'FFmpeg' },
    @{ Id = 'oschwartz10612.Poppler'; Name = 'Poppler' },
    @{ Id = 'TheDocumentFoundation.LibreOffice'; Name = 'LibreOffice' }
)
foreach ($pkg in $winget_pkgs) {
    Step "Installing $($pkg.Name)..."
    try {
        winget install $pkg.Id --silent --accept-source-agreements --accept-package-agreements 2>$null
        Ok "$($pkg.Name) installed (or already present)"
    } catch {
        Warn "$($pkg.Name) install hit an error — may already be installed: $_"
    }
}

# --- 4. Python packages ---
Section "Python packages (--user scope)"
$pyPackages = @(
    "python-pptx", "pydantic", "pdf2image", "markitdown",
    "numpy", "mammoth", "markdownify", "beautifulsoup4",
    "requests", "openpyxl", "PyMuPDF",
    "svglib", "reportlab", "playwright"
)
Step "pip install --user $($pyPackages -join ' ')"
python -m pip install --user --upgrade @pyPackages
Ok "Python packages installed"

Step "Installing Playwright Chromium..."
python -m playwright install chromium
Ok "Playwright Chromium installed"

# --- 5. Node packages (Playwright for capture-slides.mjs) ---
Section "Node packages (exports/playwright)"
Push-Location "$PSScriptRoot\..\exports"
if (-not (Test-Path package.json)) {
    npm init -y | Out-Null
}
npm install playwright
Pop-Location
Ok "Node Playwright installed"

# --- 6. Final guidance ---
Section "Next steps"
Write-Host ""
Write-Host "  1. " -NoNewline; Write-Host "Open Claude Code from this directory:" -ForegroundColor White
Write-Host "       claude" -ForegroundColor DarkGray
Write-Host "  2. " -NoNewline; Write-Host "In Claude Code (one-time):" -ForegroundColor White
Write-Host "       /plugin marketplace add anthropics/skills" -ForegroundColor DarkGray
Write-Host "       /plugin install document-skills@anthropic-agent-skills" -ForegroundColor DarkGray
Write-Host "       /plugin install example-skills@anthropic-agent-skills" -ForegroundColor DarkGray
Write-Host "       /reload-plugins" -ForegroundColor DarkGray
Write-Host "  3. " -NoNewline; Write-Host "Verify environment:" -ForegroundColor White
Write-Host "       .\scripts\verify.ps1" -ForegroundColor DarkGray
Write-Host ""
Ok "ai-doc-stack setup complete."
