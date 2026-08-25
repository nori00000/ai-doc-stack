# lecture.DESIGN.md

Design system for `lecture.html` — "AI로 제안서 만들기" lecture deck.
Read this **before** adding, editing, or restyling any slide. The constraints below are intentional.

> "자연스럽고 뛰어난 결과물은 철저하게 기획된 통제와 규칙에서 나온다." — 박준, Claude Design 시스템 프롬프트 분석

---

## 1. Identity

Paper & Ink editorial — a printed magazine that breathes on screen.
*The page is paper, not plastic.* (Mercury DESIGN.md)

Reference family — what we're inheriting from:

- **Stripe Press** — serif headlines, sans body, generous margins, optical color choices
- **WIRED** — broadsheet density, custom serif display, ink-blue links
- **Mercury DESIGN.md** (rohitg00/awesome-claude-design, warm family) — direct ancestor of this style
- **Anthropic Opus 4.7 fallback** — `#f5f4ed` parchment + Anthropic Serif + terracotta accent
- **NYT scrolly-telling** — animations that teach, not decorate

What we explicitly reject:

- Vercel/Linear monochrome minimalism (different aesthetic register — too plastic for paper-feel)
- "Glassmorphism" or any frosted-glass blur effect
- Notion-style rounded cards everywhere (rounded-2xl epidemic)
- "Generic SaaS" gradients and floating shapes

---

## 2. Color tokens (locked)

```
--paper        #faf8f3   cream parchment, canvas
--paper-2      #f3eee3   paper section, code background tint
--paper-3      #ece5d4   rare divider tint
--ink          #1a1a1a   primary text
--ink-2        #4a4540   secondary text
--ink-3        #8a8580   tertiary, captions, marginalia
--ink-4        #b8b3aa   dotted underlines, hairlines
--rule         rgba(26,26,26,0.18)
--rule-strong  rgba(26,26,26,0.55)
--crimson      #b73e3a   single accent — see §5
--crimson-tint rgba(183,62,58,0.08)
--code-bg      #f0ebde
```

**Backgrounds per deck: max 2** (paper + paper-2). Never a third.

<!-- DOC-SYNC: 2026-07-12 정정 — exports/lecture.html 실측(L2347-2426)에서 Tweaks 클래스의
     saveState()/loadState()가 theme을 localStorage['lecture-tweaks']에 함께 영속화함을 확인.
     2026-07-11에 추가된 "localStorage에 영속화되지 않음" 서술은 §11과도 모순되는 오기였음 — 정정. -->
<!-- DOC-SYNC: 2026-07-20 정정 — exports/lecture.html L88(루트)·L1067-1080(ink 블록) 실측:
     ink 블록은 --crimson-tint만 rgba(183,62,58,0.08)→0.18로 재정의하고, --crimson(#b73e3a)은
     ink 블록에 아예 등장하지 않아 라이트 값 그대로 상속됨. "--crimson/--crimson-tint 둘 다
     진하기가 올라간다"는 기존 서술은 부정확했음 — --crimson-tint만 진해진다고 정정. -->
### 2b. Ink theme (dark mode toggle)

`lecture.html`에는 위 라이트 팔레트("Paper")와 별도로 `html[data-theme="ink"]`
다크 테마가 구현되어 있고, 헤더의 Paper/Ink 버튼(`.theme-btn[data-theme]`)으로
런타임에 전환됩니다. 토큰은 라이트 팔레트를 반전한 값(`--paper: #1a1916`,
`--ink: #faf8f3` 등)이며, `--crimson`(`#b73e3a`) 자체는 재정의되지 않고 라이트 값을
그대로 유지합니다 — `--crimson-tint`만 진하기가 살짝 올라갑니다
(`rgba(183,62,58,0.08)` → `rgba(183,62,58,0.18)`). 기본값은 `"paper"`(`TWEAK_DEFAULTS.theme`)이지만, 선택한
테마는 다른 tweak 설정(폰트 스케일·accent)과 함께 `localStorage['lecture-tweaks']`에
영속화되어 새로고침 후에도 유지됩니다(§11 참고). 새 슬라이드를 추가할 때 다크
테마에서도 §5(crimson 규칙)와 §7(금지 목록)을 동일하게 지켜야 합니다.

---

## 3. Typography

```
--f-display   'Cormorant Garamond', 'Noto Serif KR', Georgia, serif
--f-body      'Pretendard Variable', 'Source Serif 4', system-ui, sans-serif
--f-mono      'JetBrains Mono', 'D2Coding', ui-monospace, monospace
```

Magazine pairing: **serif display + sans body** (Stripe Press strategy).

OpenType always on:
- `font-feature-settings: "kern", "liga", "clig", "calt", "palt", "pkna"`
- `font-variant-numeric: oldstyle-nums proportional-nums`
- `font-synthesis: none`
- `letter-spacing: -0.012em` on body (Pretendard guidance)

Modular scale (ratio 1.5):

| Token | px range | Used for |
|-------|---------|---------|
| `--t-xs` | 11–13 | small caps, page numbers |
| `--t-sm` | 12–15 | labels, captions |
| `--t-base` | 15–18 | body |
| `--t-md` | 18–22 | lede |
| `--t-lg` | 22–32 | section title |
| `--t-xl` | 32–48 | h2 |
| `--t-2xl` | 44–68 | h1, cover |
| `--t-3xl` | 64–104 | hero, closing |
| `--t-watermark` | 128–288 | chapter Roman numerals |

---

## 4. Korean line-breaking (non-negotiable)

```css
html:lang(ko), :lang(ko) {
    word-break: keep-all;
    overflow-wrap: break-word;
    line-break: strict;
}
```

- Headlines: `text-wrap: balance; max-width: 22–28ch`
- Body: `text-wrap: pretty; max-width: 38–46ch; line-height: 1.6`
- Code: explicit opt-out (`word-break: normal`)
- **Never** use `text-align: justify` for Korean

---

## 5. Crimson rule — one accent per slide

Crimson (`--crimson`) appears at most **one or two prominent places per slide**.

Allowed concentrations:
- Drop cap (`::first-letter`)
- Pull quote opening mark
- Chapter Roman numeral watermark
- Eyebrow label of the slide
- Section number (`§ 1.1`)
- Skill labels in decision tree leaves

Forbidden: more than 3 crimson elements competing within one slide.
Audit before shipping any new slide.

Subtle markers (page dividers, ampersands, swash symbols) → use `--ink-3`, not crimson.

---

## 6. Layout

- Slide container: 12-col grid, marginalia in col 1–2, main in col 3–12
- Baseline grid: **8px** for all spacing, padding, gaps
- Slide footprint: exactly `100vh`, no internal scrolling
- Chapter watermark: giant Roman numeral, opacity 0.08, bottom-right corner

---

## 7. Forbidden (AI slop checklist)

Never use:

- Purple / pink / violet gradients
- Stock photography
- Inter, Roboto, Arial, Fraunces as display (overused)
- Card + shadow + rounded-2xl combo without contextual reason
- Container with rounded corners + left-border accent color (most common AI cliché)
- Emoji as decoration (only if brand uses)
- SVG-drawn pseudo-illustrations (placeholders are better than bad attempts)
- "Data slop" — meaningless numbers, gratuitous statistics, ornamental icons
- Filler content to fill empty space
- More than 2 background colors per deck
- `scrollIntoView()` — use `window.scrollTo({top: el.offsetTop})`
- `text-align: justify` for Korean text
- `<br/>` to fix spacing — use CSS `text-wrap: balance` instead

---

## 8. Component conventions

- **Code block** — no window chrome. Gutter with line numbers (9pt, opacity 0.4). Crimson 2px left border. JetBrains Mono.
- **Problem / Solution** — vertical stack with 1px hairline divider. Never side-by-side.
- **Decision tree** — SVG with `<g class="leaf" data-skill="...">`. Hover dims non-targets to 0.35 opacity.
- **Workflow diagram** — SVG with `stroke-dashoffset` draw-in. Curved Bezier paths with `marker-end` arrows.
- **Drop cap** — `::first-letter`, 4.2em, crimson, OpenType `ss01`/`salt`/`swsh`.
- **Pull quote** — giant `❝` at 12rem, opacity 0.18, position absolute.
- **Marginalia** — left 16–22vw column, dashed border-right, ink-3 text, small-caps labels with tabular-nums values.

---

## 9. Outputs

The HTML file must convert cleanly to:

| Format | Skill / tool |
|--------|--------------|
| PPTX | Anthropic `pptx` skill, or `pptx-from-layouts` for company templates |
| PDF | Playwright (`page.pdf()`) or `@media print` |
| MP4 | `capture-slides.mjs` (Playwright + FFmpeg) or HeyGen `hyperframes` (Apache 2.0) — 상세: `render-mp4.md` |

Every animation must have a valid static end state for capture.
**No Canvas/WebGL. No realtime data.** Animation is enhancement, not substance.

---

## 10. Slide labeling

Every `.slide` carries:

```html
<section class="slide" data-screen-label="01 Cover">
```

Two-digit stable identifier assigned at authoring time. Labels are sequential from "01" to "25". The current deck has 25 slides. Used by inline-edit/comment tools to identify which slide a remark applies to.

---

## 11. Persistence

- Slide index → `localStorage['lecture-slide-index']`
- Inline edits → `localStorage['lecture-edits-v2']`
- Tweak settings → `localStorage['lecture-tweaks']`

Refresh-safe by default.

---

## 12. Process

1. Read this file before any slide work.
2. State the system you will use ("I'll add slide 25 as a quote slide, using the pull-quote convention from §8").
3. If breaking a rule, justify why in a code comment above the change.
4. Audit against §5 (crimson) and §7 (slop) before committing.

---

*One thousand no's for every yes. Less is more.*
