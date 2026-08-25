# 제안서 작성 가이드

이 레포(`ai-doc-stack/`)에서 Claude Code로 제안서를 작성·변환하는 방법을 정리한 문서입니다.

---

## 1. 워크스페이스 구조

```
ai-doc-stack/
├── templates/   회사 PPT 템플릿(.pptx), 마크다운 양식, 브랜드 자산
├── drafts/      작업 중인 제안서 (.md, .html, .pptx)  ← gitignored
├── assets/      이미지, 로고, 차트 원본               ← gitignored
├── exports/     강의·슬라이드 예시 및 변환 스크립트
├── scripts/     OS별 설치·검증 스크립트
├── GUIDE.md     이 문서
└── README.md    빠른 시작
```

작업 시작 전: `cd <ai-doc-stack 레포 경로> && claude` 로 Claude Code 진입.

---

## 2. 설치된 도구 한눈에 보기

### 환경
| 항목 | 버전 | 용도 |
|------|------|------|
| Node.js | 24.15.0 | omc, npm 도구 |
| Python | 3.12.10 | 스킬 스크립트 실행 |
| Poppler | 26.04.0 ※ | PDF→이미지 변환 (pdf2image) |
| LibreOffice | 26.2.2.2 ※ | PPTX 썸네일·검증·폴백 변환 |
| Playwright Chromium | 1.60.0 | HTML→PDF 렌더링 |
| FFmpeg | 8.1.x ※ | HTML→MP4 인코딩 (`exports/capture-slides.mjs`, 상세: `exports/render-mp4.md`) |

> ※ Node.js·Python 버전은 `.tool-versions`로 고정. Poppler·LibreOffice 버전은 Windows winget 기준 참고값이며 Mac(brew)·Linux(apt)에서는 설치 시점의 최신 버전이 사용됩니다.

### 스킬 (총 19개 — 공식 16개 + 커뮤니티 3개, 제안서 관련 핵심만 발췌)

<!-- DOC-SYNC: 2026-08-12 정정 — `anthropics/skills`의 marketplace.json 실측 결과, doc-coauthoring·
     frontend-design·theme-factory·brand-guidelines·canvas-design은 `document-skills` 플러그인이
     아니라 별도의 `example-skills` 플러그인 소속(document-skills는 xlsx/docx/pptx/pdf 4개만
     포함). 네임스페이스 열을 정정하고 README.md Quick Start §3에 `example-skills` 설치 줄 추가. -->

| 네임스페이스 | 스킬 | 핵심 용도 |
|--------------|------|-----------|
| `document-skills:` | **pptx** | .pptx 생성·편집·OOXML 직접 조작 (Anthropic 공식) |
| `document-skills:` | **docx** | Word 문서, 트랙 체인지·테이블·헤더 |
| `document-skills:` | **pdf** | PDF 읽기·합치기·폼 채우기·OCR |
| `document-skills:` | **xlsx** | 표·차트·수식 시트 |
| `example-skills:` | **doc-coauthoring** | 제안서·기술 스펙·결정 문서의 구조적 공동 저술 |
| `example-skills:` | **frontend-design** | HTML/React 랜딩페이지·대시보드 |
| `example-skills:` | **theme-factory** | 10개 프리셋 테마 적용 (슬라이드·문서 통일) |
| `example-skills:` | **brand-guidelines** | Anthropic 공식 브랜드 컬러·타이포 |
| `example-skills:` | **canvas-design** | 포스터·정적 시각물 (.png/.pdf) |
| (커뮤니티) | **frontend-slides** | HTML 슬라이드 데크 (zero-dep, 애니메이션) |
| (커뮤니티) | **pptx-from-layouts** | 회사 PPT 템플릿의 슬라이드 마스터 그대로 사용 |
| (커뮤니티) | **ppt-master** | PDF/DOCX/URL → SVG → PPTX 파이프라인 |

> 설치: `document-skills`와 `example-skills` 둘 다 `/plugin install`이 필요합니다 (README.md Quick Start §3 참고). 하나만 설치하면 위 표의 절반(4개)만 활성화됩니다.

> **설치 미기재** <!-- DOC-SYNC: UNVERIFIED — 커뮤니티 스킬 3개(frontend-slides/pptx-from-layouts/ppt-master) 설치 명령이 이 저장소 문서에 없음 (최초 2026-08-10, 최종확인 2026-08-25) -->: 위 커뮤니티 스킬 3개는 §4~5의 메인 워크플로가 실제로 의존하는데, README.md·GUIDE.md 어디에도 설치 명령이 없습니다. 웹 검색으로 이름·기능 설명이 일치하는 후보 저장소를 찾았고, `gh repo view`로 셋 다 현재 존재·비보관(active) 상태임을 확인했습니다:
> - **frontend-slides** → `zarazhangrui/frontend-slides` (확정 — 이 레포의 `exports/lecture.html` L1389-1391에 이 저장소를 `git clone https://github.com/zarazhangrui/frontend-slides ~/.claude/skills/frontend-slides`로 설치하는 명령이 예시 데크에 이미 포함됨. `gh repo view`: isArchived=false)
> - **pptx-from-layouts** → 후보: `tristan-mcinnis/pptx-from-layouts-skill` ("슬라이드 마스터 레이아웃" 설명과 일치, isArchived=false) — <!-- DOC-SYNC: UNVERIFIED — 레포 내 어디에도 설치 명령 없음, 설치 전 각자 확인 필요 -->
> - **ppt-master** → 후보: `hugohe3/ppt-master` ("문서/주제 → PPTX 네이티브 변환" 설명과 일치, isArchived=false) — <!-- DOC-SYNC: UNVERIFIED — 레포 내 어디에도 설치 명령 없음, 설치 전 각자 확인 필요 -->
>
> frontend-slides 설치 명령(레포 내 실증):
> ```bash
> git clone https://github.com/zarazhangrui/frontend-slides ~/.claude/skills/frontend-slides
> ```
> pptx-from-layouts·ppt-master는 같은 `git clone https://github.com/<owner>/<repo> ~/.claude/skills/<name>` 패턴을 따를 가능성이 높으나(`render-mp4.md`의 `npx skills add heygen-com/hyperframes`처럼 `npx skills add <owner>/<repo>` 패턴일 수도 있음), 레포 안에 확증 근거가 없어 설치 전 각자 확인이 필요합니다.

---

## 3. 스킬 선택 가이드 (가장 중요)

같은 "PPT 만들어줘" 요청이라도 결과가 다릅니다. **결과물 형식과 입력 소스로 결정**합니다.

```
산출물이 무엇인가?
├─ Word 문서(.docx)        → docx
├─ Excel(.xlsx)            → xlsx
├─ PDF (편집/생성/추출)    → pdf
├─ 포스터/정적 이미지       → canvas-design
├─ 웹페이지/대시보드       → frontend-design
├─ HTML 슬라이드 데크      → frontend-slides
└─ PowerPoint(.pptx)
   ├─ 회사 템플릿 사용     → pptx-from-layouts
   ├─ 소스 문서에서 변환    → ppt-master
   └─ 그 외 일반           → pptx (공식)
```

**제안서 작성 단계가 불명확할 때** → `doc-coauthoring`으로 시작. 구조화·반복 개선 워크플로를 안내해줍니다.

**스타일 통일이 필요할 때** → `theme-factory` (10개 프리셋) 또는 `brand-guidelines` (Anthropic 브랜드).

---

## 4. 메인 워크플로: HTML 우선 → PPT 변환

가장 유연한 방식. HTML로 빠르게 만들고 검토 후 필요시 PPT로 내려보냅니다.

### Step 1. HTML 슬라이드 데크 만들기
프롬프트 예시:
```
drafts/ 에 [고객사명] 제안서 슬라이드 데크를 frontend-slides 로 만들어줘.
주제: [한 줄 요약]
필수 슬라이드: 표지 / 문제 정의 / 솔루션 / 사례 / 가격 / 다음 단계
톤: [예: 전문적이고 미니멀, 다크 모드]
```

frontend-slides는 먼저 3가지 시각 스타일 미리보기를 만들어 보여줍니다. 마음에 드는 걸 고르면 본격 작성.

### Step 2. 브라우저에서 검토
생성된 `index.html`을 열어 확인. 슬라이드 단위로 수정 요청.

### Step 3. PPT가 필요하면 변환
두 가지 방법:

**(a) 회사 PPT 템플릿이 있다면** — `pptx-from-layouts`
```
templates/회사템플릿.pptx 의 레이아웃을 사용해서
drafts/제안서.md (현재 HTML 데크의 내용을 마크다운으로 정리)로
PPT를 만들어줘. 출력: exports/제안서.pptx
```

**(b) 일반 변환** — Anthropic 공식 `pptx` 스킬
```
방금 만든 HTML 슬라이드를 .pptx 로 변환해줘.
출력: exports/제안서.pptx
```

### Step 4. PDF로도 내보내기 (이메일 첨부용)
```
drafts/index.html 을 exports/제안서.pdf 로 내보내줘.
```
브라우저에서 해당 HTML을 열고 Ctrl+P → PDF로 저장하거나, Playwright를 통해 변환합니다.

---

## 5. 대체 워크플로

### 5-1. 마크다운 → 회사 템플릿 PPT (회사 표준 양식이 엄격할 때)

```
templates/표준제안서.pptx 의 슬라이드 마스터를 분석하고
drafts/제안서.md 의 헤딩 구조에 맞춰 PPT를 생성해줘.
```

`pptx-from-layouts`는 템플릿의 레이아웃 ID와 플레이스홀더를 그대로 사용해서, 회사가 정한 폰트·로고·여백을 깨뜨리지 않습니다.

### 5-2. 기존 자료(PDF/DOCX) → PPT (참고 자료가 많을 때)

```
assets/시장분석.pdf, assets/내부정책.docx 를 읽어서
요점만 추려 PPT 슬라이드 데크를 만들어줘.
```

`ppt-master`가 PDF→마크다운(PyMuPDF), DOCX→마크다운(mammoth) 변환 후 SVG→PPTX로 출력.

### 5-3. 제안서 본문(Word) 함께 작성

PPT 외에 본문 제안서가 별도로 필요할 때:
```
doc-coauthoring 으로 [고객사] 제안서 본문(.docx) 작성을 도와줘.
RFP 응답 형식, 한국어, 회사 톤.
```

---

## 6. 공통 패턴

### 테마 통일
프로젝트 시작 시 한 번:
```
theme-factory 로 이 프로젝트에 어울리는 테마를 정해줘.
용도: B2B SaaS 제안서. 키워드: 신뢰감, 전문성, 진취적.
```
선택한 테마를 슬라이드·문서·랜딩페이지에 일관되게 적용 요청 가능.

### 시각 자산 생성
포스터·표지 이미지:
```
canvas-design 으로 제안서 표지 이미지를 만들어줘.
크기: 1920x1080, 형식: png, 분위기: [...]
```

### 데이터 시각화가 들어가는 슬라이드
`xlsx` 스킬로 데이터 처리 → 차트 생성 → `pptx`로 슬라이드 합치기.

---

## 7. 검증 / 문제 해결

### 설치 상태 빠른 점검
```bash
python --version                # Python 3.12.10
node --version                  # v24.15.0
pdftoppm -v                     # 26.04.0 (Poppler)
"C:\Program Files\LibreOffice\program\soffice.com" --version  # 26.2.2.2
python -c "import pptx, pdf2image, playwright, markitdown; print('ok')"
```

### 자주 발생할 이슈
| 증상 | 원인 / 해결 |
|------|-------------|
| `pdftoppm not found` | 새 PowerShell 열어서 Poppler PATH 적용. user PATH에 자동 등록됨 |
| Playwright 렌더링 실패 | `python -m playwright install chromium` 재실행 |
| 한글 폰트 깨짐 (PPT) | 시스템에 해당 폰트 설치 또는 `frontend-slides`로 웹폰트 사용 |
| 스킬이 잘못 트리거됨 | 프롬프트에 결과물 형식·도구 명시 ("pptx-from-layouts로", "HTML로") |

### tmux (오마이클로드코드 보조)
필요해지면:
```
winget install -e --id marlocarlo.psmux
omc setup
```
(winget 패키지 ID `marlocarlo.psmux` 확인됨, 2026-07-08 재검증)

---

## 8. 추가 메모

- **API 키 사용 안 함**: 모든 작업이 Claude Code Max 구독 내에서 처리됩니다. Anthropic API 키 별도 결제 불필요.
- **민감 정보**: 클라이언트 비공개 자료는 `drafts/` 에만 두고 외부 서비스(웹 fetch 등)에 노출되지 않게 주의.
- **버전 관리**: 이 레포는 이미 git으로 관리됩니다. `assets/` 의 큰 파일은 `.gitignore`에 추가되어 있습니다.

---

마지막 업데이트: 2026-08-24 (doc-sync 전체 재검증, 변경 실질 없음: `gh api`로 marketplace.json(document-skills 4 + example-skills 12 = 16) 재확인, `nori00000/ai-doc-stack` visibility=PUBLIC 재확인. `scripts/setup-*.sh`·`scripts/verify.sh`·`verify.ps1`의 파이썬 패키지 14종, `exports/lecture.html`의 25슬라이드(`data-slide` 마커·p.25/25 재카운트), `exports/capture-slides.mjs`의 env var 4종 전부 문서와 코드 일치 확인. 커뮤니티 스킬 3종(frontend-slides/pptx-from-layouts/ppt-master) 및 HyperFrames 업스트림 `gh repo view` 재확인 — 전부 active·public 유지, ppt-master pushedAt만 2026-08-20→08-22로 갱신(§2). MISMATCH·STALE_DOC 없음. 이전 이력은 git으로 보존.)
