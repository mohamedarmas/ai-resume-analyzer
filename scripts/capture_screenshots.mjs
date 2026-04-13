import { chromium } from 'playwright';
import path from 'node:path';
import { mkdir } from 'node:fs/promises';

const baseUrl = process.env.BASE_URL ?? 'http://127.0.0.1:8123/';
const outputDir = process.env.OUTPUT_DIR ?? 'assets/screenshots';
const viewport = { width: 1440, height: 1800 };
const seededJobDescription =
  'Frontend Engineer focused on Flutter Web, analytics dashboards, developer tooling, testing discipline, and accessible admin experiences. Own product quality, collaborate across design and product, and improve release reliability.';

await mkdir(outputDir, { recursive: true });

const browser = await chromium.launch({
  headless: true,
  args: ['--force-renderer-accessibility'],
});

function buildHashUrl(hashRoute) {
  const url = new URL(baseUrl);
  url.hash = hashRoute;
  return url.toString();
}

async function captureStaticRoute(hashRoute, fileName, waitFor = 1800) {
  const context = await browser.newContext({ viewport });
  const page = await context.newPage();
  await page.goto(buildHashUrl(hashRoute), { waitUntil: 'networkidle' });
  await page.waitForTimeout(waitFor);
  await page.screenshot({
    path: path.join(outputDir, fileName),
    fullPage: true,
  });
  await context.close();
}

async function enableAccessibility(page) {
  await page.evaluate(() => {
    document.querySelector('flt-semantics-placeholder')?.click();
  });
  await page.waitForTimeout(1200);
}

async function setHash(page, hashRoute) {
  await page.evaluate((nextHash) => {
    window.location.hash = nextHash;
  }, hashRoute);
}

async function captureSeededFlow() {
  const context = await browser.newContext({ viewport });
  const page = await context.newPage();

  await page.goto(buildHashUrl('/upload'), { waitUntil: 'networkidle' });
  await page.waitForTimeout(1200);
  await enableAccessibility(page);
  await page.getByRole('button', { name: 'Use demo resume' }).click();
  await page.waitForTimeout(1400);

  await setHash(page, '#/analysis');
  await page.waitForTimeout(1500);
  await page.screenshot({
    path: path.join(outputDir, 'analysis.png'),
    fullPage: true,
  });

  await setHash(page, '#/job-match');
  await page.waitForTimeout(1200);
  await page.locator('textarea').fill(seededJobDescription);
  await page.waitForTimeout(1500);
  await page.screenshot({
    path: path.join(outputDir, 'job-match.png'),
    fullPage: true,
  });

  await setHash(page, '#/ai-assist');
  await page.waitForTimeout(1500);
  await page.screenshot({
    path: path.join(outputDir, 'ai-assist.png'),
    fullPage: true,
  });

  await setHash(page, '#/report');
  await page.waitForTimeout(1500);
  await page.screenshot({
    path: path.join(outputDir, 'report.png'),
    fullPage: true,
  });

  await context.close();
}

await captureStaticRoute('/', 'landing.png', 2200);
await captureStaticRoute('/demo', 'demo.png', 2200);
await captureSeededFlow();

await browser.close();
