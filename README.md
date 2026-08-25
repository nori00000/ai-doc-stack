# ai-doc-stack

> **한눈에 / At a glance**
>
> An HTML-first AI document authoring stack for producing editable documents and exportable HTML, PDF, PPTX, and MP4 outputs.
>
> 한영 프로젝트 설명, 검색 키워드, 저작권 범위: [PROJECT.md](./PROJECT.md) · [NOTICE.md](./NOTICE.md) · [PUBLICATION_REVIEW.md](./PUBLICATION_REVIEW.md)


> Daily document authoring infra — AI 비서(Claude Code)와 함께 제안서·강의 자료·기술 문서를 만드는 작업대.

**한 줄 요약**: Paper & Ink editorial 미학 + HTML-first 작성 + 4채널(HTML/PPTX/PDF/MP4) 자동 변환.

크로스플랫폼(Mac · Windows · Linux). 콘텐츠는 100% 공유되고 설치 스크립트만 OS별로 다름.

---

## Quick Start

### 0. 사전: mise (런타임 버전 매니저)

mise는 Node, Python 등을 `.tool-versions` 파일 기준으로 자동 설치·전환합니다. 이 리포의 `.tool-versions`에 `node 24.15.0 / python 3.12.10`이 명시되어 있어, mise가 알아서 같은 버전을 깔아줍니다.

**Mac/Linux**
```bash
curl https://mise.run | sh
echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc   # zsh이면 .zshrc
```

**Windows (PowerShell)**
```powershell
winget install jdx.mise
```

### 1. Clone

```bash
git clone https://github.com/nori00000/ai-doc-stack.git
cd ai-doc-stack
mise install   # .tool-versions 보고 Node 24 + Python 3.12 자동 설치
```

### 2. OS별 셋업 (한 번만)

**Mac**
```bash
bash scripts/setup-macos.sh
```

**Windows (PowerShell)**
```powershell
.\scripts\setup-windows.ps1
```

**Linux**
```bash
bash scripts/setup-linux.sh
```

스크립트가 처리: FFmpeg · Poppler · LibreOffice · Python 패키지 14개 · Playwright Chromium · Node Playwright. 세부 단계는 각 스크립트 주석 및 `bash scripts/verify.sh` 출력을 참고하세요.

### 3. Claude Code에서 문서 스킬 활성화 (한 번만)

```bash
claude   # ai-doc-stack 디렉터리 안에서
```

Claude Code 입력창에 차례로:

```
/plugin marketplace add anthropics/skills
/plugin install document-skills@anthropic-agent-skills
/plugin install example-skills@anthropic-agent-skills
/reload-plugins
```

이걸로 Anthropic 공식 스킬 16개 활성화 — `document-skills` 플러그인(`pptx`, `docx`, `xlsx`, `pdf` 4개)과 `example-skills` 플러그인(`frontend-design`, `theme-factory`, `brand-guidelines`, `canvas-design`, `doc-coauthoring` 포함 12개). 한 번만 하면 다른 PC에서도 동일.

> 참고: `anthropics/skills` 마켓플레이스 등록과 두 플러그인 ID는 `anthropics/skills`의 `.claude-plugin/marketplace.json` 기준으로 확인됨(2026-08-12 재검증). 다만 이 저장소가 clone된 개별 머신에서 위 4줄을 실제로 실행했는지는 머신마다 다르므로, `bash scripts/verify.sh`의 `~/.claude/skills/` 항목으로 스킬 설치 여부를 먼저 확인하세요.
>
> <!-- DOC-SYNC: 2026-08-12 정정 — 기존 문서는 `document-skills@anthropic-agent-skills` 한 줄 설치만으로 `frontend-design`·`theme-factory`·`brand-guidelines`까지 활성화되는 것처럼 서술했으나, `anthropics/skills` marketplace.json 실측 결과 이 스킬들은 `document-skills`가 아니라 별도의 `example-skills` 플러그인 소속입니다(`document-skills`는 xlsx/docx/pptx/pdf 4개만 포함). 설치 줄과 스킬 개수를 정정하고 `example-skills` 설치 명령을 추가함. GUIDE.md §2 네임스페이스도 함께 정정. -->

> **커뮤니티 스킬 3개 별도 설치 필요**: `GUIDE.md`의 메인 워크플로(§4)와 아래 "다음 단계"에서 쓰는 `frontend-slides`·`pptx-from-layouts`·`ppt-master`는 위 4줄(공식 `document-skills`·`example-skills` 플러그인)에 포함되지 않는 커뮤니티 스킬입니다. 이 저장소 문서 어디에도 이 3개의 설치 명령이 없습니다 — 사용 전 별도로 설치하세요. <!-- DOC-SYNC: 2026-08-10 발견, 설치 명령 미기재 (UNVERIFIED: 정확한 소스 저장소는 각자 확인). 2026-08-12: "위 3줄"→"위 4줄"로 갱신(example-skills 설치 줄 추가에 따른 표현 정합) -->

### 4. 환경 검증

```bash
bash scripts/verify.sh        # Mac/Linux/Git Bash
# or
.\scripts\verify.ps1          # Windows PowerShell
```

모든 도구가 PATH에 있는지, 현재 설치된 버전이 무엇인지 한 번에 확인.

---

## 무엇이 들어 있나

```
.
├── README.md
├── GUIDE.md                  ← 슬라이드·제안서 작성 가이드
├── LICENSE                   ← MIT (코드)
├── NOTICE.md                 ← 저작권·재사용 고지
├── PROJECT.md                ← 프로젝트 메타데이터 (키워드·목적)
├── PUBLICATION_REVIEW.md     ← 공개 준비 점검 기록
├── exports/
│   ├── lecture.html          ← 강의 자료 예시 (25슬라이드 데크)
│   ├── lecture.DESIGN.md     ← Paper & Ink 디자인 시스템 명세
│   ├── capture-slides.mjs    ← HTML → MP4 변환 스크립트
│   ├── package.json          ← Node 의존성 (playwright)
│   └── render-mp4.md         ← MP4 변환 절차
├── scripts/
│   ├── setup-macos.sh
│   ├── setup-windows.ps1
│   ├── setup-linux.sh
│   └── verify.sh / verify.ps1
├── templates/                ← 회사 PPT 템플릿 (*.pptx/docx/key는 gitignored)
├── drafts/                   ← (gitignored) 작업 중 파일
├── assets/                   ← (gitignored) 이미지·자산
├── .tool-versions            ← mise 런타임 핀
├── .gitignore
└── .gitattributes            ← 줄바꿈(LF/CRLF)·바이너리 처리 규칙
```

---

## 크로스플랫폼 — 무엇이 공통이고 무엇이 다른가

| 항목 | Mac | Windows | Linux |
|------|-----|---------|-------|
| **콘텐츠** (HTML/MD/JS) | 동일 | 동일 | 동일 |
| **Node.js, Python, FFmpeg** | mise + brew | mise + winget | mise + apt |
| **Claude Code skills** | `~/.claude/skills/` | `~/.claude/skills/` | `~/.claude/skills/` |
| **회사 PPT 템플릿** | 같은 `.pptx` 파일 | 같은 `.pptx` 파일 | 같은 `.pptx` 파일 |
| 패키지 매니저 | Homebrew | winget | apt/dnf |
| 셸 | bash/zsh | PowerShell (Git Bash 호환) | bash |

**핵심**: 콘텐츠와 클로드 스킬은 모든 PC에서 동일하게 동작. OS별 차이는 "설치 명령" 한 단계뿐.

---

## 4채널 산출

`exports/lecture.html` 하나로 다음 4가지를 생성:

| 채널 | 변환 방법 | 명령 |
|------|-----------|------|
| **HTML** | 그대로 사용 | 브라우저에서 열기 |
| **PPTX** | Claude Code 내 `document-skills:pptx` 또는 `pptx-from-layouts` | `"이 HTML을 회사 템플릿으로 PPT 변환해줘"` |
| **PDF** | 브라우저 Ctrl+P 또는 Playwright | 브라우저에서 열고 Ctrl+P → PDF 저장 |
| **MP4** | Playwright 캡처 + FFmpeg 인코딩 | `node exports/capture-slides.mjs` (상세: `exports/render-mp4.md`) |

---

## 다음 단계 — 새 제안서를 만들 때

1. `drafts/<클라이언트>/` 폴더 생성
2. Claude Code에서: `"frontend-slides로 ~/drafts/<클라이언트>/proposal.html 슬라이드 데크 만들어줘. lecture.DESIGN.md의 톤을 따라줘"`
3. 검토 후 `exports/`로 이동, PPT/PDF 변환
4. 영상이 필요하면 `node exports/capture-slides.mjs` (절차: `exports/render-mp4.md`)

`lecture.DESIGN.md`가 디자인 시스템 가드레일이라, 모든 새 제안서가 같은 톤으로 통일됩니다.

---

## 라이선스

- 코드 (스크립트): MIT
- 콘텐츠 (lecture.html 등): CC BY 4.0
- 회사 템플릿 (`templates/`): 회사 소유, 외부 공유 금지 (gitignored)

---

*"자연스럽고 뛰어난 결과물은 철저하게 기획된 통제와 규칙에서 나온다." — 박준, Claude Design 시스템 프롬프트 분석*
