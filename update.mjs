#!/usr/bin/env node
// ccusage로 사용량 JSON을 받아 data-*.json / data.js 생성
// macOS / Linux / Windows 모두에서 동작 (Node 18+)

import { spawnSync } from 'node:child_process';
import { writeFileSync, readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const DIR = dirname(fileURLToPath(import.meta.url));
const NPX = process.platform === 'win32' ? 'npx.cmd' : 'npx';

function runCcusage(subcommand, outPath, fallback) {
  const result = spawnSync(
    NPX,
    ['-y', 'ccusage@latest', subcommand, '--json'],
    { encoding: 'utf8', stdio: ['ignore', 'pipe', 'inherit'] },
  );

  if (result.status === 0 && result.stdout) {
    writeFileSync(outPath, result.stdout);
    return;
  }

  if (fallback !== undefined) {
    writeFileSync(outPath, fallback);
    return;
  }

  console.error(`ccusage ${subcommand} 실패 (exit ${result.status})`);
  process.exit(result.status ?? 1);
}

const dailyPath = join(DIR, 'data-daily.json');
const monthlyPath = join(DIR, 'data-monthly.json');
const sessionPath = join(DIR, 'data-session.json');
const dataJsPath = join(DIR, 'data.js');

runCcusage('daily', dailyPath);
runCcusage('monthly', monthlyPath);
runCcusage('session', sessionPath, '{"sessions":[]}');

const daily = readFileSync(dailyPath, 'utf8').trimEnd();
const monthly = readFileSync(monthlyPath, 'utf8').trimEnd();
const generatedAt = new Date().toISOString();

writeFileSync(
  dataJsPath,
  `window.CLAUDE_DATA = {\n  generatedAt: "${generatedAt}",\n  daily: ${daily},\n  monthly: ${monthly}\n};\n`,
);

console.log(`Updated: ${new Date().toString()}`);
