#!/bin/bash
# test.sh — smoke tests for cc-usage-board.
# Run with: ./test.sh
#
# Covers: shell+JS syntax, HTML inline JS, tag balance, i18n key parity
# (ko ≡ en, all used keys defined, no orphans), external file references.

set -u
cd "$(dirname "$0")"

PASS=0
FAIL=0
LAST_ERR=""

check() {
  local label="$1"; shift
  local out
  if out=$("$@" 2>&1); then
    echo "  ✓ $label"
    PASS=$((PASS + 1))
  else
    echo "  ✗ $label"
    [ -n "$out" ] && echo "      $out" | sed 's/^/      /'
    FAIL=$((FAIL + 1))
  fi
}

echo "== Syntax =="
check "i18n.js"                 node --check i18n.js
check "shared.js"               node --check shared.js
check "update.mjs"              node --check update.mjs
check "update.sh"               bash -n update.sh
check "plugins/claude-usage"    bash -n plugins/claude-usage.5m.sh

echo ""
echo "== HTML inline JS =="
for f in dashboard.html overview.html; do
  node -e "
    const fs = require('fs');
    const html = fs.readFileSync('$f', 'utf8');
    const m = html.match(/<script>([\s\S]*?)<\/script>/);
    if (!m) process.exit(1);
    fs.writeFileSync('/tmp/_cc_test.mjs', m[1]);
  "
  check "$f inline JS"          node --check /tmp/_cc_test.mjs
done
rm -f /tmp/_cc_test.mjs

echo ""
echo "== Tag balance =="
for f in dashboard.html overview.html; do
  check "$f balance"            node -e "
    const fs = require('fs');
    const html = fs.readFileSync('$f', 'utf8');
    const TAGS = 'div|script|style|table|head|body|html|tbody|thead|tr|td|th|span|canvas|button|h1|h2|a|label|code|select|option';
    const opens = (html.match(new RegExp('<('+TAGS+')\\\\b[^>]*>', 'g')) || []).filter(t => !t.endsWith('/>'));
    const closes = (html.match(new RegExp('</('+TAGS+')>', 'g')) || []);
    const c = {};
    for (const t of opens) { const tag = t.match(/<(\\w+)/)[1]; c[tag] = (c[tag]||0)+1; }
    for (const t of closes) { const tag = t.match(/<\\/(\\w+)/)[1]; c[tag] = (c[tag]||0)-1; }
    const mm = Object.entries(c).filter(([_, v]) => v !== 0);
    if (mm.length) { console.error('imbalance:', JSON.stringify(mm)); process.exit(1); }
  "
done

echo ""
echo "== i18n parity =="
check "ko ≡ en + no orphans"    node -e "
  const fs = require('fs');
  const code = fs.readFileSync('i18n.js', 'utf8');
  const ctx = { window: {}, document: { documentElement: {}, querySelector: () => null, querySelectorAll: () => [] }, localStorage: { getItem: () => null, setItem: () => {} }, navigator: { language: 'en' } };
  new Function('window', 'document', 'localStorage', 'navigator', code)(ctx.window, ctx.document, ctx.localStorage, ctx.navigator);
  const I18N = ctx.window.CLAUDE_I18N;
  const keys = [...code.matchAll(/^\\s{6}([a-zA-Z_][a-zA-Z0-9_]*):/gm)].map(m => m[1]);
  const ko = new Set(), en = new Set();
  I18N.lang = 'ko'; for (const k of keys) if (I18N.t(k) !== k) ko.add(k);
  I18N.lang = 'en'; for (const k of keys) if (I18N.t(k) !== k) en.add(k);
  ko.add('dow'); ko.add('locale'); en.add('dow'); en.add('locale');
  const used = new Set();
  for (const f of ['dashboard.html', 'overview.html']) {
    const html = fs.readFileSync(f, 'utf8');
    for (const m of html.matchAll(/data-i18n=\\\"([^\\\"]+)\\\"/g)) used.add(m[1]);
    for (const m of html.matchAll(/I18N\\.t\\([\\'\\\"]([^\\'\\\"]+)[\\'\\\"]/g)) used.add(m[1]);
    if (html.includes('I18N.dow()')) used.add('dow');
    if (html.includes('I18N.locale()')) used.add('locale');
  }
  const onlyKo = [...ko].filter(k => !en.has(k));
  const onlyEn = [...en].filter(k => !ko.has(k));
  const undef = [...used].filter(k => !ko.has(k));
  const unused = [...ko].filter(k => !used.has(k));
  if (onlyKo.length) console.error('ko-only:', onlyKo);
  if (onlyEn.length) console.error('en-only:', onlyEn);
  if (undef.length) console.error('used but undefined:', undef);
  if (unused.length) console.error('defined but unused:', unused);
  if (onlyKo.length || onlyEn.length || undef.length || unused.length) process.exit(1);
"

echo ""
echo "== File references =="
for f in dashboard.html overview.html; do
  for ref in i18n.js shared.js styles.css; do
    check "$f → $ref"           grep -q "$ref" "$f"
  done
done

echo ""
echo "== Summary =="
echo "  PASS: $PASS"
echo "  FAIL: $FAIL"
[ "$FAIL" -eq 0 ]
