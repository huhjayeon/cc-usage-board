// shared.js — utilities used by every dashboard page.
// Globals: modelShort, CHART_COLORS

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

// Default chart palette. Use .slice(0, n) when fewer colors are needed.
const CHART_COLORS = ['#d97757', '#79c0ff', '#56d364', '#f0a878', '#bc8cff', '#8b949e'];
