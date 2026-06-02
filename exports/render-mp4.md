# lecture.html → MP4 변환 가이드

HyperFrames(HeyGen, Apache 2.0)와 Playwright를 사용해 강의 자료를 영상으로 렌더링하는 방법.

## 사전 요구사항

| 항목 | 상태 |
|------|------|
| Node.js ≥ 22 | ✅ v24.15.0 |
| Playwright + Chromium | ✅ 설치됨 |
| **FFmpeg** | ✅ **v8.1.1 essentials** (Gyan, MSYS2 빌드) |
| HyperFrames 저장소 | 삭제됨 — 필요 시 `git clone https://github.com/heygen-com/hyperframes ~/tools/hyperframes` |

FFmpeg 위치 (winget 설치, user PATH 등록 — 새 셸에서 자동 인식):
```
C:\Users\YourName\AppData\Local\Microsoft\WinGet\Packages\Gyan.FFmpeg.Essentials_*\ffmpeg-8.1.1-essentials_build\bin\ffmpeg.exe
```
현재 셸에서 즉시 쓰려면 새 PowerShell을 열거나, `capture-slides.mjs`를 사용하세요 (스크립트가 PATH 미등록 시 winget 캐시를 자동 탐색합니다).

## 두 가지 접근

### A. Playwright 단순 캡처 (간단, 비결정론적) — 권장

이미 만든 `capture-slides.mjs` 스크립트로 한 줄 변환.

```bash
# 1. 로컬 서버 (별도 셸)
cd ./workspace/exports && python -m http.server 8000

# 2. 캡처 + 인코딩
cd ./workspace/exports && node capture-slides.mjs
```

스크립트가 처리하는 것:
- 슬라이드별 강제 visible 상태로 만들기 (`.reveal` opacity 1, SVG `stroke-dashoffset: 0`)
- 1920×1080 PNG 캡처 25장
- FFmpeg로 mp4 인코딩 (슬라이드당 6초, 30fps)

산출: `./workspace/exports/lecture.mp4` (약 2~3분)

환경 변수로 조정:
```bash
SECONDS_PER_SLIDE=8 node capture-slides.mjs  # 더 천천히
LECTURE_URL=http://localhost:8000/lecture.html OUTPUT=./demo.mp4 node capture-slides.mjs
```

### B. HyperFrames 정식 composition (복잡, 결정론적)

장점: 동일 코드 → 동일 영상, TTS·배경 음악·타이밍 정밀 제어.

```bash
# 1. HyperFrames 재클론
git clone https://github.com/heygen-com/hyperframes ~/tools/hyperframes

# 2. 새 composition 프로젝트
cd ./workspace/exports
npx hyperframes init lecture-video
cd lecture-video

# 3. 스킬 설치 (Claude Code 안에서 자동 작업 가능)
npx skills add heygen-com/hyperframes

# 4. lecture.html 내용을 composition으로 변환 (Claude Code 안에서)
# > /hyperframes 로 lecture.html을 25-slide composition으로 변환해줘

# 5. 미리보기 + 렌더링
npx hyperframes preview
npx hyperframes render --out lecture.mp4
```

HyperFrames는 자체 composition 포맷이라 lecture.html을 그대로 입력할 수 없고, 슬라이드 전환·타이밍을 명시한 composition으로 다시 작성해야 합니다. 한 번 만들면 강의 내용 업데이트마다 동일 입력으로 재렌더 가능.

## 추천 흐름

**프로토타입·내부 검토** → A (Playwright + capture-slides.mjs)
- 5~10분 안에 동작
- lecture.html 그대로 사용

**프로덕션·반복 갱신** → B (HyperFrames composition)
- 검수·외주 친화적 (결정론적)
- TTS 보이스오버, 배경 음악, 트랜지션 효과 가능
- 우리 lecture.html의 스피커 노트(JSON 24개)를 TTS로 변환해 영상에 입힐 수 있음

## 산출물 채널

`lecture.html` → 동시에 4가지 산출:

| 채널 | 도구 | 상태 |
|------|------|------|
| HTML | 그대로 | ✅ |
| PPTX | `document-skills:pptx` 또는 `pptx-from-layouts` | ✅ 스킬 준비됨 |
| PDF | `frontend-slides/scripts/export-pdf.sh` 또는 Ctrl+P | ✅ |
| MP4 | `capture-slides.mjs` (A) 또는 HyperFrames (B) | ⚠️ FFmpeg 필요 |

라이선스: HyperFrames Apache 2.0, FFmpeg LGPL. 상업 사용 가능.
