#!/usr/bin/env bash
# ai-doc-stack — Linux setup (Ubuntu/Debian-based)
# For other distros, adapt the apt commands to your package manager.

set -euo pipefail

cyan()  { printf '\033[1;36m%s\033[0m\n' "$*"; }
green() { printf '\033[1;32m  %s\033[0m\n' "$*"; }
white() { printf '  %s\n' "$*"; }
warn()  { printf '\033[1;33m  %s\033[0m\n' "$*"; }
section() { echo; cyan "== $* =="; }

# --- 1. mise ---
section "mise"
if ! command -v mise >/dev/null; then
    white "Installing mise..."
    curl https://mise.run | sh
    warn "Add to ~/.bashrc:  eval \"\$(~/.local/bin/mise activate bash)\""
    export PATH="$HOME/.local/bin:$PATH"
fi
green "mise: $(mise --version 2>/dev/null || echo 'install pending — open new shell')"

# --- 2. Runtimes ---
section "Runtimes (Node, Python)"
mise install
green "Node $(node --version) / Python $(python --version)"

# --- 3. APT packages ---
section "Helper tools (apt)"
sudo apt-get update -qq
sudo apt-get install -y ffmpeg poppler-utils libreoffice
green "FFmpeg / Poppler / LibreOffice installed"

# --- 4. Python ---
section "Python packages (--user)"
python -m pip install --user --upgrade \
    python-pptx pydantic pdf2image markitdown \
    numpy mammoth markdownify beautifulsoup4 \
    requests openpyxl PyMuPDF \
    svglib reportlab playwright
python -m playwright install chromium
green "Python deps + Chromium installed"

# --- 5. Node ---
section "Node packages"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
cd "$SCRIPT_DIR/../exports"
[ -f package.json ] || npm init -y >/dev/null
npm install playwright

section "Next steps"
echo
white "1. claude"
white "2. /plugin marketplace add anthropics/skills"
white "3. /plugin install document-skills@anthropic-agent-skills"
white "4. /plugin install example-skills@anthropic-agent-skills"
white "5. /reload-plugins"
white "6. bash scripts/verify.sh"
echo
green "ai-doc-stack setup complete."
