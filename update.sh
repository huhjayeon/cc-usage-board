#!/bin/bash
set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
npx -y ccusage@latest daily --json  > "$DIR/data-daily.json"
npx -y ccusage@latest monthly --json > "$DIR/data-monthly.json"
npx -y ccusage@latest session --json > "$DIR/data-session.json" 2>/dev/null || echo '{"sessions":[]}' > "$DIR/data-session.json"

# 브라우저 file:// 프로토콜에서도 로드되도록 JS 파일로 변환
{
  echo "window.CLAUDE_DATA = {"
  echo "  generatedAt: \"$(date -Iseconds)\","
  echo "  daily: $(cat "$DIR/data-daily.json"),"
  echo "  monthly: $(cat "$DIR/data-monthly.json")"
  echo "};"
} > "$DIR/data.js"

echo "Updated: $(date)"
