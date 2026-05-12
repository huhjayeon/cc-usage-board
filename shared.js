// shared.js — utilities used by every dashboard page.
// Globals: modelShort, modelTokens, CHART_COLORS, CHART_THEME, el, buildModelPills

function modelShort(name) {
  if (name.includes('opus')) {
    const m = name.match(/opus-(\d+-\d+)/);
    return { label: 'Opus ' + (m ? m[1].replace('-', '.') : ''), cls: 'opus' };
  }
  if (name.includes('sonnet')) {
    const m = name.match(/sonnet-(\d+-\d+)/);
    return { label: 'Sonnet ' + (m ? m[1].replace('-', '.') : ''), cls: 'sonnet' };
  }
  if (name.includes('haiku')) {
    const m = name.match(/haiku-(\d+-\d+)/);
    return { label: 'Haiku ' + (m ? m[1].replace('-', '.') : ''), cls: 'haiku' };
  }
  return { label: name, cls: '' };
}

// Sum all token columns of a model breakdown entry from ccusage.
const modelTokens = b => b.inputTokens + b.outputTokens + b.cacheCreationTokens + b.cacheReadTokens;

// Format Date in the user's local timezone (NOT UTC like Date#toISOString).
// Use these for "today/yesterday/this month" comparisons — otherwise dates
// near midnight will shift by one because ccusage buckets are local while
// toISOString returns UTC.
function localDateString(d) {
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, '0');
  const dd = String(d.getDate()).padStart(2, '0');
  return `${y}-${m}-${dd}`;
}

function localMonthString(d) {
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, '0');
  return `${y}-${m}`;
}

// Parse "YYYY-MM-DD" as midnight in the user's local timezone.
// (new Date("YYYY-MM-DD") would parse as UTC midnight, which gives the wrong
// day-of-week / day-of-month for users west of UTC.)
function parseLocalDate(s) {
  const [y, m, d] = s.split('-').map(Number);
  return new Date(y, m - 1, d);
}

// Default chart palette. Use .slice(0, n) when fewer colors are needed.
const CHART_COLORS = ['#d97757', '#79c0ff', '#56d364', '#f0a878', '#bc8cff', '#8b949e'];

// Chart styling pulled from CSS variables so styles.css is the single source of
// truth. Fallback values match the original hardcoded colors in case the
// stylesheet hasn't applied yet at script-load time.
const CHART_THEME = (() => {
  const root = getComputedStyle(document.documentElement);
  const v = (name, fallback) => root.getPropertyValue(name).trim() || fallback;
  return {
    tick: v('--muted', '#8b949e'),
    grid: v('--border', '#30363d'),
    legend: v('--text', '#e6edf3'),
    panelBg: v('--panel', '#161b22'),
  };
})();

// Tiny DOM builder: el('div', {class: 'x'}, 'text', el('span', ...))
// String/number children are inserted as text nodes (safe from HTML injection).
// null/undefined/false children are skipped.
function el(tag, attrs, ...children) {
  const node = document.createElement(tag);
  if (attrs) {
    for (const [k, v] of Object.entries(attrs)) {
      if (v == null || v === false) continue;
      if (k === 'class') node.className = v;
      else if (k === 'style' && typeof v === 'object') Object.assign(node.style, v);
      else node.setAttribute(k, v);
    }
  }
  for (const c of children) {
    if (c == null || c === false) continue;
    node.appendChild(typeof c === 'string' || typeof c === 'number'
      ? document.createTextNode(String(c))
      : c);
  }
  return node;
}

// Build a DocumentFragment of <span class="model-pill ..."> for a list of model names.
function buildModelPills(modelNames) {
  const frag = document.createDocumentFragment();
  for (const name of modelNames || []) {
    const s = modelShort(name);
    frag.appendChild(el('span', { class: s.cls ? 'model-pill ' + s.cls : 'model-pill' }, s.label));
  }
  return frag;
}
