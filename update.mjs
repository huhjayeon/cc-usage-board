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

  const useStdout = result.status === 0 && result.stdout;
  const raw = useStdout ? result.stdout : fallback;

  if (raw === undefined) {
    console.error(`ccusage ${subcommand} 실패 (exit ${result.status})`);
    process.exit(result.status ?? 1);
  }

  // JSON 유효성 검증 후 저장 (정규화된 형태로)
  let parsed;
  try {
    parsed = JSON.parse(raw);
  } catch (e) {
    console.error(`ccusage ${subcommand} 출력이 유효한 JSON이 아닙니다: ${e.message}`);
    if (fallback !== undefined) {
      writeFileSync(outPath, fallback);
      return JSON.parse(fallback);
    }
    process.exit(1);
  }
  writeFileSync(outPath, JSON.stringify(parsed, null, 2) + '\n');
  return parsed;
}

const dailyPath = join(DIR, 'data-daily.json');
const monthlyPath = join(DIR, 'data-monthly.json');
const sessionPath = join(DIR, 'data-session.json');
const dataJsPath = join(DIR, 'data.js');

const daily = runCcusage('daily', dailyPath);
const monthly = runCcusage('monthly', monthlyPath);
runCcusage('session', sessionPath, '{"sessions":[]}');

const generatedAt = new Date().toISOString();
const dataJs = `window.CLAUDE_DATA = ${JSON.stringify({ generatedAt, daily, monthly }, null, 2)};\n`;
writeFileSync(dataJsPath, dataJs);

console.log(`Updated: ${new Date().toString()}`);
