# 제안서 작성 가이드

이 워크스페이스(`~/proposals/`)에서 Claude Code로 제안서를 작성·변환하는 방법을 정리한 문서입니다.

---

## 1. 워크스페이스 구조

```
~/proposals/
├── templates/   회사 PPT 템플릿(.pptx), 마크다운 양식, 브랜드 자산
├── drafts/      작업 중인 제안서 (.md, .html, .pptx)
├── assets/      이미지, 로고, 차트 원본
├── exports/     최종 산출물 (.pdf, .pptx, .html)
└── GUIDE.md     이 문서
```

작업 시작 전: `cd ~/proposals && claude` 로 Claude Code 진입.

---

## 2. 설치된 도구 한눈에 보기

### 환경
| 항목 | 버전 | 용도 |
|------|------|------|
| Node.js | 24.15.0 | omc, npm 도구 |
| Python | 3.12.10 | 스킬 스크립트 실행 |
| Poppler | 25.07.0 | PDF→이미지 변환 (pdf2image) |
| LibreOffice | 26.2.3.2 | PPTX 썸네일·검증·폴백 변환 |
| Playwright Chromium | 1.60.0 | HTML→PDF 렌더링 |

### 스킬 (총 20+, 제안서 관련 핵심만)
| 네임스페이스 | 스킬 | 핵심 용도 |
|--------------|------|-----------|
| `document-skills:` | **doc-coauthoring** | 제안서·기술 스펙·결정 문서의 구조적 공동 저술 |
| `document-skills:` | **pptx** | .pptx 생성·편집·OOXML 직접 조작 (Anthropic 공식) |
| `document-skills:` | **docx** | Word 문서, 트랙 체인지·테이블·헤더 |
| `document-skills:` | **pdf** | PDF 읽기·합치기·폼 채우기·OCR |
| `document-skills:` | **xlsx** | 표·차트·수식 시트 |
| `document-skills:` | **frontend-design** | HTML/React 랜딩페이지·대시보드 |
| `document-skills:` | **theme-factory** | 10개 프리셋 테마 적용 (슬라이드·문서 통일) |
| `document-skills:` | **brand-guidelines** | Anthropic 공식 브랜드 컬러·타이포 |
| `document-skills:` | **canvas-design** | 포스터·정적 시각물 (.png/.pdf) |
| (커뮤니티) | **frontend-slides** | HTML 슬라이드 데크 (zero-dep, 애니메이션) |
| (커뮤니티) | **pptx-from-layouts** | 회사 PPT 템플릿의 슬라이드 마스터 그대로 사용 |
| (커뮤니티) | **ppt-master** | PDF/DOCX/URL → SVG → PPTX 파이프라인 |

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
~/proposals/drafts/ 에 [고객사명] 제안서 슬라이드 데크를 frontend-slides 로 만들어줘.
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
~/proposals/templates/회사템플릿.pptx 의 레이아웃을 사용해서
~/proposals/drafts/제안서.md (현재 HTML 데크의 내용을 마크다운으로 정리)로
PPT를 만들어줘. 출력: ~/proposals/exports/제안서.pptx
```

**(b) 일반 변환** — Anthropic 공식 `pptx` 스킬
```
방금 만든 HTML 슬라이드를 .pptx 로 변환해줘.
출력: ~/proposals/exports/제안서.pptx
```

### Step 4. PDF로도 내보내기 (이메일 첨부용)
```
~/proposals/drafts/index.html 을 ~/proposals/exports/제안서.pdf 로 내보내줘.
```
내부적으로 `bash scripts/export-pdf.sh` (Playwright 기반)이 실행됩니다.

---

## 5. 대체 워크플로

### 5-1. 마크다운 → 회사 템플릿 PPT (회사 표준 양식이 엄격할 때)

```
~/proposals/templates/표준제안서.pptx 의 슬라이드 마스터를 분석하고
~/proposals/drafts/제안서.md 의 헤딩 구조에 맞춰 PPT를 생성해줘.
```

`pptx-from-layouts`는 템플릿의 레이아웃 ID와 플레이스홀더를 그대로 사용해서, 회사가 정한 폰트·로고·여백을 깨뜨리지 않습니다.

### 5-2. 기존 자료(PDF/DOCX) → PPT (참고 자료가 많을 때)

```
~/proposals/assets/시장분석.pdf, ~/proposals/assets/내부정책.docx 를 읽어서
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
python --version                # 3.12.10
node --version                  # v24.15.0
pdftoppm -v                     # 25.07.0 (Poppler)
"C:\Program Files\LibreOffice\program\soffice.com" --version  # 26.2.3.2
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
winget install psmux
omc setup
```

---

## 8. 추가 메모

- **API 키 사용 안 함**: 모든 작업이 Claude Code Max 구독 내에서 처리됩니다. OpenAI API 키 별도 결제 불필요.
- **민감 정보**: 클라이언트 비공개 자료는 `~/proposals/drafts/` 에만 두고 외부 서비스(웹 fetch 등)에 노출되지 않게 주의.
- **버전 관리**: 필요하면 `cd ~/proposals && git init` 후 `assets/` 의 큰 파일은 `.gitignore`에 추가.

---

마지막 업데이트: 2026-05-19
