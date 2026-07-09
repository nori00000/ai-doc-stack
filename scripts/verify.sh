#!/usr/bin/env bash
# Environment verification — checks that every tool ai-doc-stack needs is present.

ok()   { printf '  \033[1;32m✓\033[0m  %s\n' "$*"; }
miss() { printf '  \033[1;31m✗\033[0m  %s\n' "$*"; FAILED=1; }
info() { printf '     %s\n' "$*"; }
FAILED=0

echo
printf '\033[1;36m== ai-doc-stack environment check ==\033[0m\n'
echo

# Runtimes
if command -v node >/dev/null; then ok "Node.js: $(node --version)"; else miss "Node.js missing"; fi
if command -v python >/dev/null; then ok "Python: $(python --version 2>&1)"; else miss "Python missing"; fi
if command -v npm >/dev/null; then ok "npm: $(npm --version)"; else miss "npm missing"; fi

# Helper tools
if command -v ffmpeg >/dev/null; then ok "FFmpeg: $(ffmpeg -version 2>&1 | head -1 | awk '{print $3}')"; else miss "FFmpeg missing — install via brew/winget/apt"; fi
if command -v pdftoppm >/dev/null; then ok "Poppler (pdftoppm): $(pdftoppm -v 2>&1 | head -1)"; else miss "Poppler missing"; fi
if command -v soffice >/dev/null || [ -f "/Applications/LibreOffice.app/Contents/MacOS/soffice" ] || [ -f "/c/Program Files/LibreOffice/program/soffice.com" ]; then
    ok "LibreOffice: present"
else
    miss "LibreOffice missing"
fi

# Python packages
echo
printf '  \033[1;36m-- Python packages --\033[0m\n'
python - <<'PY'
import importlib, sys
mods = ["pptx", "pdf2image", "markitdown", "numpy", "mammoth", "markdownify",
        "bs4", "requests", "openpyxl", "fitz", "playwright", "pydantic",
        "svglib", "reportlab"]
missing = []
for m in mods:
    try:
        importlib.import_module(m)
        print(f"     OK   {m}")
    except Exception:
        print(f"     MISS {m}")
        missing.append(m)
if missing:
    sys.exit(1)
PY
[ $? -eq 0 ] || FAILED=1

# Claude Code skills directory
echo
printf '  \033[1;36m-- Claude Code skills --\033[0m\n'
if [ -d "$HOME/.claude/skills" ]; then
    count=$(ls -1 "$HOME/.claude/skills" 2>/dev/null | wc -l | tr -d ' ')
    ok "~/.claude/skills/ ($count skills)"
else
    miss "~/.claude/skills/ not present (open Claude Code at least once)"
fi

echo
if [ "$FAILED" -eq 0 ]; then
    printf '\033[1;32m✓ All checks passed.\033[0m\n'
    exit 0
else
    printf '\033[1;31m✗ Some checks failed — see above.\033[0m\n'
    exit 1
fi
