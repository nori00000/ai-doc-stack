#!/usr/bin/env node
/**
 * lecture.html → MP4 변환 — Playwright 단순 캡처 방식
 *
 * 사용법:
 *   1. 별도 셸에서 로컬 서버: cd ai-doc-stack/exports && python -m http.server 8000
 *   2. 이 스크립트: node capture-slides.mjs
 *   3. 산출: ./lecture.mp4
 *
 * 요구사항: Node 24+, Playwright(이미 설치됨), FFmpeg
 */

import { chromium } from 'playwright';
import { spawnSync } from 'child_process';
import { mkdirSync, rmSync, existsSync, readdirSync, statSync } from 'fs';
import { join } from 'path';
import { homedir } from 'os';

/** Resolve ffmpeg.exe — try PATH first, then winget install location. */
function findFfmpeg() {
    if (process.env.FFMPEG_PATH && existsSync(process.env.FFMPEG_PATH)) return process.env.FFMPEG_PATH;
    const probe = spawnSync(process.platform === 'win32' ? 'where' : 'which', ['ffmpeg'], { encoding: 'utf8' });
    if (probe.status === 0) {
        const first = probe.stdout.split(/\r?\n/).find((l) => l.trim());
        if (first && existsSync(first.trim())) return first.trim();
    }
    if (process.platform === 'win32') {
        const wingetBase = join(homedir(), 'AppData', 'Local', 'Microsoft', 'WinGet', 'Packages');
        if (existsSync(wingetBase)) {
            const dirs = readdirSync(wingetBase).filter((d) => d.startsWith('Gyan.FFmpeg'));
            for (const d of dirs) {
                const stack = [join(wingetBase, d)];
                while (stack.length) {
                    const cur = stack.pop();
                    let entries;
                    try { entries = readdirSync(cur); } catch { continue; }
                    for (const e of entries) {
                        const p = join(cur, e);
                        if (e === 'ffmpeg.exe') return p;
                        try { if (statSync(p).isDirectory()) stack.push(p); } catch {}
                    }
                }
            }
        }
    }
    return null;
}

const URL = process.env.LECTURE_URL || 'http://localhost:8000/lecture.html';
const OUT = process.env.OUTPUT || './lecture.mp4';
const FRAMES_DIR = './_frames';
const SECONDS_PER_SLIDE = Number(process.env.SECONDS_PER_SLIDE || 6);
const WIDTH = 1920;
const HEIGHT = 1080;

if (existsSync(FRAMES_DIR)) rmSync(FRAMES_DIR, { recursive: true });
mkdirSync(FRAMES_DIR, { recursive: true });

const browser = await chromium.launch();
const ctx = await browser.newContext({ viewport: { width: WIDTH, height: HEIGHT } });
const page = await ctx.newPage();

console.log(`Loading ${URL} ...`);
await page.goto(URL, { waitUntil: 'networkidle' });

// Clear any persisted slide index so we always start fresh
await page.evaluate(() => { try { localStorage.removeItem('lecture-slide-index'); } catch (_) {} });

// Disable smooth scroll & scroll-snap, unlock body height, and freeze all motion
// so .visible state lands instantly (no mid-animation captures).
await page.addStyleTag({ content: `
    html, body { height: auto !important; min-height: 100% !important; }
    html { scroll-behavior: auto !important; scroll-snap-type: none !important; }
    .slide { scroll-snap-align: none !important; }
    *, *::before, *::after {
        animation-duration: 0s !important;
        animation-delay: 0s !important;
        transition-duration: 0s !important;
        transition-delay: 0s !important;
    }
` });

const slideCount = await page.evaluate(() => document.querySelectorAll('.slide').length);
console.log(`Found ${slideCount} slides — capturing at ${WIDTH}×${HEIGHT}`);

for (let i = 0; i < slideCount; i++) {
    // Pre-set: force visible state + freeze animations to end states for slide i
    await page.evaluate((idx) => {
        const slides = document.querySelectorAll('.slide');
        const target = slides[idx];
        target.classList.add('visible');
        target.querySelectorAll('.reveal').forEach((el) => {
            el.style.opacity = '1';
            el.style.transform = 'none';
        });
        target.querySelectorAll('.workflow-svg .arrow, .tree-svg .branch, .tree-svg .branch-sub').forEach((el) => {
            el.style.strokeDashoffset = '0';
        });
        target.querySelectorAll('.workflow-svg g[transform], .tree-svg text, .tree-svg .dot, .tree-svg .dot-sub').forEach((el) => {
            el.style.opacity = '1';
        });
    }, i);

    // Playwright-native scroll — most reliable in headless
    const slideHandle = await page.locator('.slide').nth(i);
    await slideHandle.scrollIntoViewIfNeeded();

    // Verify scroll actually landed where expected
    const { scrollY, expectedY } = await page.evaluate((idx) => ({
        scrollY: window.scrollY,
        expectedY: document.querySelectorAll('.slide')[idx].getBoundingClientRect().top + window.scrollY,
    }), i);

    await page.waitForTimeout(700);
    const out = join(FRAMES_DIR, `slide-${String(i + 1).padStart(2, '0')}.png`);
    await page.screenshot({ path: out, fullPage: false });
    console.log(`  ${out}  scrollY=${scrollY} (slide expected at ${expectedY})`);
}

await browser.close();
console.log(`Captured ${slideCount} frames. Encoding to ${OUT} ...`);

// FFmpeg encode — each slide held for SECONDS_PER_SLIDE seconds at 30fps
const ffmpeg = findFfmpeg();
if (!ffmpeg) {
    console.error('FFmpeg not found. winget install Gyan.FFmpeg.Essentials');
    process.exit(1);
}
console.log(`Using ffmpeg: ${ffmpeg}`);
const ffmpegResult = spawnSync(ffmpeg, [
    '-y',
    '-framerate', `1/${SECONDS_PER_SLIDE}`,
    '-i', join(FRAMES_DIR, 'slide-%02d.png'),
    '-c:v', 'libx264',
    '-pix_fmt', 'yuv420p',
    '-vf', `fps=30,scale=${WIDTH}:${HEIGHT}:flags=lanczos`,
    '-movflags', '+faststart',
    OUT,
], { stdio: 'inherit' });

if (ffmpegResult.status !== 0) {
    console.error('FFmpeg encode failed.');
    process.exit(1);
}

console.log(`✓ Done: ${OUT}`);
