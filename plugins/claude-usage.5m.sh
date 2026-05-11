#!/bin/bash
# SwiftBar plugin: Claude Code 일일 토큰 사용량
# 파일명 규칙: claude-usage.5m.sh → 5분마다 자동 갱신
# <bitbar.title>Claude Token Usage</bitbar.title>
# <bitbar.author>huhjayeon</bitbar.author>
# <bitbar.github>huhjayeon</bitbar.github>
# <bitbar.desc>오늘 Claude Code 사용 토큰 표시</bitbar.desc>

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

# 스크립트 자신의 위치에서 대시보드 폴더 도출 (심볼릭 링크 대응)
SELF="$0"
[ -L "$SELF" ] && SELF="$(readlink "$SELF")"
DASH_DIR="$(cd "$(dirname "$SELF")/.." && pwd)"
DATA="$DASH_DIR/data-daily.json"

# 데이터 없으면 즉시 갱신 (최초 1회)
[ -f "$DATA" ] || "$DASH_DIR/update.sh" >/dev/null 2>&1

# 최신 데이터로 백그라운드 갱신 (5분 이상 오래된 경우)
if [ -f "$DATA" ]; then
  AGE=$(( $(date +%s) - $(stat -f %m "$DATA") ))
  if [ "$AGE" -gt 300 ]; then
    ("$DASH_DIR/update.sh" >/dev/null 2>&1) &
  fi
fi

TODAY=$(date +%Y-%m-%d)
YESTERDAY=$(date -v-1d +%Y-%m-%d)
WEEK_START=$(date -v-6d +%Y-%m-%d)
MONTH=$(date +%Y-%m)

# jq 경로 (Homebrew)
JQ=$(command -v jq)
if [ -z "$JQ" ]; then
  echo "🤖 jq 필요"
  echo "---"
  echo "brew install jq | bash=brew param1=install param2=jq terminal=true"
  exit 0
fi

# 숫자 포맷터 (한국식 만/억)
fmt() {
  awk -v n="$1" 'BEGIN {
    if (n >= 1e8) {
      eok = n / 1e8;
      if (eok >= 10) printf "%d억", int(eok + 0.5);
      else printf "%.1f억", eok;
    } else if (n >= 1e4) {
      man = int(n/1e4 + 0.5);
      s = sprintf("%d", man);
      out = "";
      i = length(s);
      while (i > 3) {
        out = "," substr(s, i-2, 3) out;
        i -= 3;
      }
      out = substr(s, 1, i) out;
      printf "%s만", out;
    } else {
      printf "%d", n;
    }
  }'
}

fmt_usd() {
  awk -v n="$1" 'BEGIN {
    if (n < 10) printf "$%.2f", n;
    else printf "$%d", n + 0.5;
  }'
}

TODAY_TOK=$($JQ -r --arg d "$TODAY" '.daily[] | select(.date==$d) | .totalTokens' "$DATA" 2>/dev/null || echo 0)
TODAY_COST=$($JQ -r --arg d "$TODAY" '.daily[] | select(.date==$d) | .totalCost' "$DATA" 2>/dev/null || echo 0)
YEST_TOK=$($JQ -r --arg d "$YESTERDAY" '.daily[] | select(.date==$d) | .totalTokens' "$DATA" 2>/dev/null || echo 0)
YEST_COST=$($JQ -r --arg d "$YESTERDAY" '.daily[] | select(.date==$d) | .totalCost' "$DATA" 2>/dev/null || echo 0)
WEEK_TOK=$($JQ -r --arg s "$WEEK_START" '[.daily[] | select(.date >= $s) | .totalTokens] | add // 0' "$DATA")
WEEK_COST=$($JQ -r --arg s "$WEEK_START" '[.daily[] | select(.date >= $s) | .totalCost] | add // 0' "$DATA")
MONTH_TOK=$($JQ -r --arg m "$MONTH" '[.daily[] | select(.date | startswith($m)) | .totalTokens] | add // 0' "$DATA")
MONTH_COST=$($JQ -r --arg m "$MONTH" '[.daily[] | select(.date | startswith($m)) | .totalCost] | add // 0' "$DATA")

# 기본값
TODAY_TOK=${TODAY_TOK:-0}
TODAY_COST=${TODAY_COST:-0}

# 메뉴바 표시: 오늘 토큰 (이모지로 작업량 강도 표시)
INTENSITY="🟢"
if   awk "BEGIN{exit !($TODAY_TOK > 50000000)}"; then INTENSITY="🔥"
elif awk "BEGIN{exit !($TODAY_TOK > 20000000)}"; then INTENSITY="🟠"
elif awk "BEGIN{exit !($TODAY_TOK > 5000000)}"; then INTENSITY="🟡"
elif awk "BEGIN{exit !($TODAY_TOK > 0)}"; then INTENSITY="🟢"
else INTENSITY="💤"; fi

echo "$INTENSITY $(fmt $TODAY_TOK)"

# Dropdown
echo "---"
echo "Claude Code 사용량 | size=11 color=gray"
echo "---"
echo "오늘  $(fmt $TODAY_TOK)  ·  $(fmt_usd $TODAY_COST) | size=13"
echo "어제  $(fmt $YEST_TOK)  ·  $(fmt_usd $YEST_COST) | size=12 color=gray"
echo "최근 7일  $(fmt $WEEK_TOK)  ·  $(fmt_usd $WEEK_COST) | size=12 color=gray"
echo "이번 달  $(fmt $MONTH_TOK)  ·  $(fmt_usd $MONTH_COST) | size=12 color=gray"
echo "---"
echo "📊 대시보드 열기 | bash=open param1=$DASH_DIR/dashboard.html terminal=false"
echo "🔄 지금 갱신 | bash=$DASH_DIR/update.sh terminal=false refresh=true"
echo "📁 폴더 열기 | bash=open param1=$DASH_DIR terminal=false"
echo "---"
echo "마지막 갱신: $(stat -f '%Sm' -t '%H:%M' "$DATA" 2>/dev/null) | size=10 color=gray"
