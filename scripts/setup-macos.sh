#!/usr/bin/env bash
# ai-doc-stack — macOS setup script
# Installs runtimes (via mise), helper tools (FFmpeg, Poppler, LibreOffice),
# Python packages, and Playwright Chromium. One-time.

set -euo pipefail

cyan()  { printf '\033[1;36m%s\033[0m\n' "$*"; }
green() { printf '\033[1;32m  %s\033[0m\n' "$*"; }
white() { printf '  %s\n' "$*"; }
warn()  { printf '\033[1;33m  %s\033[0m\n' "$*"; }

section() { echo; cyan "== $* =="; }

# --- 1. Homebrew ---
section "Homebrew"
if ! command -v brew >/dev/null; then
    white "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    green "brew already installed: $(brew --version | head -1)"
fi

# --- 2. mise (runtime version manager) ---
section "mise"
if ! command -v mise >/dev/null; then
    white "Installing mise via brew..."
    brew install mise
    warn "Add to your shell rc (~/.zshrc or ~/.bashrc):"
    warn "   eval \"\$(mise activate \$(basename \$SHELL))\""
else
    green "mise already installed: $(mise --version)"
fi

# --- 3. Runtimes via mise ---
section "Runtimes (Node, Python)"
white "Reading .tool-versions and installing..."
mise install
green "Node $(node --version) / Python $(python --version)"

# --- 4. Helper tools via brew ---
section "Helper tools"
brew_pkgs=(ffmpeg poppler)
for pkg in "${brew_pkgs[@]}"; do
    white "Ensuring $pkg..."
    brew list "$pkg" >/dev/null 2>&1 || brew install "$pkg"
done

# LibreOffice as cask
if ! brew list --cask libreoffice >/dev/null 2>&1; then
    white "Installing LibreOffice (cask, ~600 MB)..."
    brew install --cask libreoffice
else
    green "LibreOffice already installed"
fi

# --- 5. Python packages ---
section "Python packages (--user scope)"
python -m pip install --user --upgrade \
    python-pptx pydantic pdf2image markitdown \
    numpy mammoth markdownify beautifulsoup4 \
    requests openpyxl PyMuPDF \
    svglib reportlab playwright

white "Installing Playwright Chromium..."
python -m playwright install chromium
green "Python deps + Chromium installed"

# --- 6. Node packages ---
section "Node packages (exports/playwright)"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
cd "$SCRIPT_DIR/../exports"
[ -f package.json ] || npm init -y >/dev/null
npm install playwright

# --- 7. Final ---
section "Next steps"
echo
white "1. Open Claude Code from this directory:"
echo "     claude"
white "2. In Claude Code (one-time):"
echo "     /plugin marketplace add anthropics/skills"
echo "     /plugin install document-skills@anthropic-agent-skills"
echo "     /plugin install example-skills@anthropic-agent-skills"
echo "     /reload-plugins"
white "3. Verify:"
echo "     bash scripts/verify.sh"
echo
green "ai-doc-stack setup complete."
