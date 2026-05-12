#!/bin/bash
# SwiftBar plugin: Claude Code daily token usage
# Filename convention: claude-usage.5m.sh → refreshes every 5 min
# <bitbar.title>Claude Token Usage</bitbar.title>
# <bitbar.author>huhjayeon</bitbar.author>
# <bitbar.github>huhjayeon</bitbar.github>
# <bitbar.desc>Show today's Claude Code token usage</bitbar.desc>

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

# Derive the dashboard folder from the script's own location (symlink-aware).
SELF="$0"
[ -L "$SELF" ] && SELF="$(readlink "$SELF")"
DASH_DIR="$(cd "$(dirname "$SELF")/.." && pwd)"
DATA="$DASH_DIR/data-daily.json"

# ---- Language selection ---------------------------------------------------
# Precedence: $CC_USAGE_LANG > ~/.claude-dashboard-lang > $LANG prefix > en.
# Set CC_USAGE_LANG=ko (or en) in your SwiftBar variables to force a choice.
LANG_PREF="${CC_USAGE_LANG:-}"
if [ -z "$LANG_PREF" ] && [ -f "$HOME/.claude-dashboard-lang" ]; then
  LANG_PREF="$(tr -d '[:space:]' < "$HOME/.claude-dashboard-lang")"
fi
if [ -z "$LANG_PREF" ]; then
  case "${LANG:-en}" in ko*|KO*) LANG_PREF="ko" ;; *) LANG_PREF="en" ;; esac
fi
[ "$LANG_PREF" != "ko" ] && LANG_PREF="en"

# ---- Translations ---------------------------------------------------------
if [ "$LANG_PREF" = "ko" ]; then
  T_TITLE="Claude Code 사용량"
  T_TODAY="오늘"
  T_YESTERDAY="어제"
  T_WEEK="최근 7일"
  T_MONTH="이번 달"
  T_OPEN_DASH="📊 대시보드 열기"
  T_REFRESH="🔄 지금 갱신"
  T_OPEN_FOLDER="📁 폴더 열기"
  T_LAST_UPDATED="마지막 갱신"
  T_JQ_NEEDED="🤖 jq 필요"
else
  T_TITLE="Claude Code usage"
  T_TODAY="Today"
  T_YESTERDAY="Yesterday"
  T_WEEK="Last 7 days"
  T_MONTH="This month"
  T_OPEN_DASH="📊 Open dashboard"
  T_REFRESH="🔄 Refresh now"
  T_OPEN_FOLDER="📁 Open folder"
  T_LAST_UPDATED="Last updated"
  T_JQ_NEEDED="🤖 jq required"
fi

# Trigger first-time data generation if missing.
[ -f "$DATA" ] || "$DASH_DIR/update.sh" >/dev/null 2>&1

# Background refresh if data is older than 5 minutes.
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

# jq path (Homebrew)
JQ=$(command -v jq)
if [ -z "$JQ" ]; then
  echo "$T_JQ_NEEDED"
  echo "---"
  echo "brew install jq | bash=brew param1=install param2=jq terminal=true"
  exit 0
fi

# Locale-aware number formatter (KO: 만/억, EN: K/M/B).
fmt() {
  awk -v n="$1" -v lang="$LANG_PREF" 'BEGIN {
    if (lang == "ko") {
      if (n >= 1e8) {
        eok = n / 1e8;
        if (eok >= 10) printf "%d억", int(eok + 0.5);
        else printf "%.1f억", eok;
      } else if (n >= 1e4) {
        man = int(n/1e4 + 0.5);
        s = sprintf("%d", man);
        out = "";
        i = length(s);
        while (i > 3) { out = "," substr(s, i-2, 3) out; i -= 3; }
        out = substr(s, 1, i) out;
        printf "%s만", out;
      } else {
        printf "%d", n;
      }
    } else {
      if (n >= 1e9) {
        b = n / 1e9;
        if (b >= 10) printf "%dB", int(b + 0.5);
        else printf "%.1fB", b;
      } else if (n >= 1e6) {
        m = n / 1e6;
        if (m >= 10) printf "%dM", int(m + 0.5);
        else printf "%.1fM", m;
      } else if (n >= 1e4) {
        printf "%dK", int(n/1e3 + 0.5);
      } else {
        printf "%d", n;
      }
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

TODAY_TOK=${TODAY_TOK:-0}
TODAY_COST=${TODAY_COST:-0}

# Menu bar text: today's tokens with workload-intensity emoji.
INTENSITY="🟢"
if   awk "BEGIN{exit !($TODAY_TOK > 50000000)}"; then INTENSITY="🔥"
elif awk "BEGIN{exit !($TODAY_TOK > 20000000)}"; then INTENSITY="🟠"
elif awk "BEGIN{exit !($TODAY_TOK > 5000000)}"; then INTENSITY="🟡"
elif awk "BEGIN{exit !($TODAY_TOK > 0)}"; then INTENSITY="🟢"
else INTENSITY="💤"; fi

echo "$INTENSITY $(fmt $TODAY_TOK)"

# Dropdown
echo "---"
echo "$T_TITLE | size=11 color=gray"
echo "---"
echo "$T_TODAY  $(fmt $TODAY_TOK)  ·  $(fmt_usd $TODAY_COST) | size=13"
echo "$T_YESTERDAY  $(fmt $YEST_TOK)  ·  $(fmt_usd $YEST_COST) | size=12 color=gray"
echo "$T_WEEK  $(fmt $WEEK_TOK)  ·  $(fmt_usd $WEEK_COST) | size=12 color=gray"
echo "$T_MONTH  $(fmt $MONTH_TOK)  ·  $(fmt_usd $MONTH_COST) | size=12 color=gray"
echo "---"
echo "$T_OPEN_DASH | bash=open param1=$DASH_DIR/dashboard.html terminal=false"
echo "$T_REFRESH | bash=$DASH_DIR/update.sh terminal=false refresh=true"
echo "$T_OPEN_FOLDER | bash=open param1=$DASH_DIR terminal=false"
echo "---"
echo "$T_LAST_UPDATED: $(stat -f '%Sm' -t '%H:%M' "$DATA" 2>/dev/null) | size=10 color=gray"
