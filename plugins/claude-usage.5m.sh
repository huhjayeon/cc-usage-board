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
# Supports ko, ja, en. Set CC_USAGE_LANG in SwiftBar Variables to override.
LANG_PREF="${CC_USAGE_LANG:-}"
if [ -z "$LANG_PREF" ] && [ -f "$HOME/.claude-dashboard-lang" ]; then
  LANG_PREF="$(tr -d '[:space:]' < "$HOME/.claude-dashboard-lang")"
fi
if [ -z "$LANG_PREF" ]; then
  case "${LANG:-en}" in
    ko*|KO*) LANG_PREF="ko" ;;
    ja*|JA*) LANG_PREF="ja" ;;
    *) LANG_PREF="en" ;;
  esac
fi
case "$LANG_PREF" in
  ko|ja|en) ;;
  *) LANG_PREF="en" ;;
esac

# Cycle order matches the web dashboard: ko → ja → en → ko.
case "$LANG_PREF" in
  ko) NEXT_LANG="ja" ;;
  ja) NEXT_LANG="en" ;;
  en) NEXT_LANG="ko" ;;
esac

# ---- Translations ---------------------------------------------------------
case "$LANG_PREF" in
  ko)
    T_TITLE="Claude Code 사용량"
    T_TODAY="오늘"; T_YESTERDAY="어제"; T_WEEK="최근 7일"; T_MONTH="이번 달"
    T_OPEN_DASH="📊 대시보드 열기"
    T_REFRESH="🔄 지금 갱신"
    T_OPEN_FOLDER="📁 폴더 열기"
    T_LAST_UPDATED="마지막 갱신"
    T_JQ_NEEDED="🤖 jq 필요"
    T_SWITCH_LANG="🌐 日本語"
    ;;
  ja)
    T_TITLE="Claude Code 使用量"
    T_TODAY="今日"; T_YESTERDAY="昨日"; T_WEEK="過去7日"; T_MONTH="今月"
    T_OPEN_DASH="📊 ダッシュボードを開く"
    T_REFRESH="🔄 今すぐ更新"
    T_OPEN_FOLDER="📁 フォルダを開く"
    T_LAST_UPDATED="最終更新"
    T_JQ_NEEDED="🤖 jq が必要"
    T_SWITCH_LANG="🌐 English"
    ;;
  en)
    T_TITLE="Claude Code usage"
    T_TODAY="Today"; T_YESTERDAY="Yesterday"; T_WEEK="Last 7 days"; T_MONTH="This month"
    T_OPEN_DASH="📊 Open dashboard"
    T_REFRESH="🔄 Refresh now"
    T_OPEN_FOLDER="📁 Open folder"
    T_LAST_UPDATED="Last updated"
    T_JQ_NEEDED="🤖 jq required"
    T_SWITCH_LANG="🌐 한국어"
    ;;
esac

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

# Locale-aware number formatter (KO: 만/억, JA: 万/億, EN: K/M/B).
fmt() {
  awk -v n="$1" -v lang="$LANG_PREF" 'BEGIN {
    if (lang == "ko" || lang == "ja") {
      big   = (lang == "ko") ? "억" : "億";
      small = (lang == "ko") ? "만" : "万";
      if (n >= 1e8) {
        eok = n / 1e8;
        if (eok >= 10) printf "%d%s", int(eok + 0.5), big;
        else printf "%.1f%s", eok, big;
      } else if (n >= 1e4) {
        man = int(n/1e4 + 0.5);
        s = sprintf("%d", man);
        out = "";
        i = length(s);
        while (i > 3) { out = "," substr(s, i-2, 3) out; i -= 3; }
        out = substr(s, 1, i) out;
        printf "%s%s", out, small;
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

# Menu bar text: today's tokens + cost with workload-intensity emoji.
INTENSITY="🟢"
if   awk "BEGIN{exit !($TODAY_TOK > 50000000)}"; then INTENSITY="🔥"
elif awk "BEGIN{exit !($TODAY_TOK > 20000000)}"; then INTENSITY="🟠"
elif awk "BEGIN{exit !($TODAY_TOK > 5000000)}"; then INTENSITY="🟡"
elif awk "BEGIN{exit !($TODAY_TOK > 0)}"; then INTENSITY="🟢"
else INTENSITY="💤"; fi

# Hide cost when there's no usage today (avoids the noisy "$0.00").
if awk "BEGIN{exit !($TODAY_TOK > 0)}"; then
  echo "$INTENSITY $(fmt $TODAY_TOK) · $(fmt_usd $TODAY_COST)"
else
  echo "$INTENSITY $(fmt $TODAY_TOK)"
fi

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
echo "$T_SWITCH_LANG | bash=bash param1=-c param2=\"echo $NEXT_LANG > $HOME/.claude-dashboard-lang\" terminal=false refresh=true"
echo "---"
echo "$T_LAST_UPDATED: $(stat -f '%Sm' -t '%H:%M' "$DATA" 2>/dev/null) | size=10 color=gray"
