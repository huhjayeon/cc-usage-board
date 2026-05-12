// i18n.js — Korean / English bilingual support for the dashboard.
// Loaded by dashboard.html and overview.html before each page's script.
(function () {
  const STRINGS = {
    ko: {
      pageTitleDashboard: 'Claude 토큰 사용량 대시보드',
      pageTitleOverview: 'Claude 토큰 사용량 — 전체 기간',
      pageHeaderDashboard: 'Claude 토큰 사용량 대시보드',
      pageHeaderOverview: 'Claude 토큰 사용량 — 전체 기간',
      navDashboard: '대시보드',
      navOverview: '전체 기간',
      refresh: '🔄 새로고침',
      updateHelpPrefix: '데이터 갱신:',
      updateHelpOr: '또는',
      updateHelpMac: '(macOS/Linux)',
      updateHelpWin: '(Windows)',
      statToday: '오늘',
      statYesterday: '어제',
      statWeek: '최근 7일',
      statMonth: '이번 달',
      statTotal: '전체 누적',
      statPlan: '플랜 대비 (이번 달)',
      panelMonthlyTrend: '월별 추이',
      panelDaily60: '최근 60일 일별 토큰',
      panelHeatmap: '활동 히트맵',
      panelHeatmapSub: '최근 90일 · GitHub 스타일',
      panelModelBreakdownThisMonth: '이번 달 모델별 비중',
      panelRecent30: '최근 30일 일별 상세',
      heatmapLess: '적음',
      heatmapMore: '많음',
      colDate: '날짜',
      colDay: '요일',
      colModel: '모델',
      colTotalTokens: '총 토큰',
      colOutput: 'Output',
      colCacheRead: 'Cache Read',
      colCost: '비용 환산',
      statMCost: '총 비용',
      dsTotalTokens: '총 토큰',
      dsCost: '비용 환산 ($)',
      lastUpdated: '최종 업데이트',
      dataRange: '데이터 범위',
      meta_dailyStats: (avg, peak) => `· 일평균 ${avg} · 피크 ${peak}`,
      tooltip_tokens: (n) => `${n} 토큰`,
      tooltip_cost: (c) => `${c} 환산`,
      deltaVsYesterday: 'vs 어제',
      deltaVsPrev7: 'vs 직전 7일',
      deltaVsLastMonth: (n) => `vs 지난달 1~${n}일`,
      errLoadFailed: '데이터 로드 실패',
      errDataMissing: 'data.js를 찾을 수 없어요. 먼저 ./update.sh (macOS/Linux) 또는 node update.mjs (Windows) 를 실행하세요.',
      errRunFirst: '터미널에서 먼저 실행:',
      dow: ['일','월','화','수','목','금','토'],
      locale: 'ko-KR',
      statTotalCumulative: '전체 누적',
      statMonthlyAvg: '월 평균',
      statPeakMonth: '가장 비싼 월',
      statLowMonth: '가장 적은 월',
      panelAllModelBreakdown: '전체 모델별 비중',
      panelMonthlyDetail: '월별 상세',
      colMonth: '월',
      colActiveDays: '활동일',
      colDailyAvg: '일평균',
      colVsLastMonth: '전월 대비',
      avgCostSuffix: ' / 달',
      currentMonthInProgress: ' (현재 월 진행 중)',
      daysSuffix: '일',
      inProgressTag: ' · 진행 중',
      trendLegendNote: '· 막대=토큰 · 선=비용($) · 점선=월 평균',
      dsMonthlyAvgTokens: '월 평균 토큰',
      tooltip_tokensLabel: (n) => `토큰: ${n}`,
      tooltip_costLabel: (c) => `비용: ${c}`,
      tooltip_monthlyAvgLabel: (n) => `월 평균: ${n}`,
      meta_overviewRange: (start, end, n) => `데이터 범위: ${start} ~ ${end} · ${n}개월`,
      panelCumulative: '누적 사용량',
      panelCumulativeSub: '· 첫 기록 이후 일별 누적',
      panelByWeekday: '요일별 평균',
      panelByWeekdaySub: '· 활동일 기준 평균 토큰',
      panelModelByMonth: '월별 모델 비중',
      panelModelByMonthSub: '· 토큰 기준 적층',
      dsCumulativeTokens: '누적 토큰',
      dsCumulativeCost: '누적 비용 ($)',
      tooltip_avgPerActiveDay: (n) => `평균: ${n}`,
      tooltip_activeDaysCount: (n) => `활동 ${n}일`,
      switchToLabel: 'EN',
      switchToTitle: 'Switch to English',
    },
    en: {
      pageTitleDashboard: 'Claude Token Usage Dashboard',
      pageTitleOverview: 'Claude Token Usage — All Time',
      pageHeaderDashboard: 'Claude Token Usage Dashboard',
      pageHeaderOverview: 'Claude Token Usage — All Time',
      navDashboard: 'Dashboard',
      navOverview: 'All Time',
      refresh: '🔄 Refresh',
      updateHelpPrefix: 'Update data:',
      updateHelpOr: 'or',
      updateHelpMac: '(macOS/Linux)',
      updateHelpWin: '(Windows)',
      statToday: 'Today',
      statYesterday: 'Yesterday',
      statWeek: 'Last 7 days',
      statMonth: 'This month',
      statTotal: 'All time',
      statPlan: 'Plan usage (this month)',
      panelMonthlyTrend: 'Monthly trend',
      panelDaily60: 'Last 60 days · daily tokens',
      panelHeatmap: 'Activity heatmap',
      panelHeatmapSub: 'Last 90 days · GitHub style',
      panelModelBreakdownThisMonth: 'Model breakdown (this month)',
      panelRecent30: 'Last 30 days · daily detail',
      heatmapLess: 'Less',
      heatmapMore: 'More',
      colDate: 'Date',
      colDay: 'Day',
      colModel: 'Model',
      colTotalTokens: 'Total tokens',
      colOutput: 'Output',
      colCacheRead: 'Cache Read',
      colCost: 'Cost',
      statMCost: 'Total cost',
      dsTotalTokens: 'Total tokens',
      dsCost: 'Cost ($)',
      lastUpdated: 'Last updated',
      dataRange: 'Data range',
      meta_dailyStats: (avg, peak) => `· daily avg ${avg} · peak ${peak}`,
      tooltip_tokens: (n) => `${n} tokens`,
      tooltip_cost: (c) => `${c} cost`,
      deltaVsYesterday: 'vs yesterday',
      deltaVsPrev7: 'vs prev 7 days',
      deltaVsLastMonth: (n) => `vs last month 1–${n}`,
      errLoadFailed: 'Failed to load data',
      errDataMissing: "Couldn't find data.js. Run ./update.sh (macOS/Linux) or node update.mjs (Windows) first.",
      errRunFirst: 'Run in terminal first:',
      dow: ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'],
      locale: 'en-US',
      statTotalCumulative: 'All-time total',
      statMonthlyAvg: 'Monthly avg',
      statPeakMonth: 'Most expensive month',
      statLowMonth: 'Cheapest month',
      panelAllModelBreakdown: 'Model breakdown (all time)',
      panelMonthlyDetail: 'Monthly detail',
      colMonth: 'Month',
      colActiveDays: 'Active days',
      colDailyAvg: 'Daily avg',
      colVsLastMonth: 'vs prev month',
      avgCostSuffix: ' / month',
      currentMonthInProgress: ' (current month in progress)',
      daysSuffix: ' days',
      inProgressTag: ' · in progress',
      trendLegendNote: '· bars=tokens · line=cost($) · dashed=monthly avg',
      dsMonthlyAvgTokens: 'Monthly avg tokens',
      tooltip_tokensLabel: (n) => `Tokens: ${n}`,
      tooltip_costLabel: (c) => `Cost: ${c}`,
      tooltip_monthlyAvgLabel: (n) => `Monthly avg: ${n}`,
      meta_overviewRange: (start, end, n) => `Range: ${start} – ${end} · ${n} months`,
      panelCumulative: 'Cumulative usage',
      panelCumulativeSub: '· daily running total since first record',
      panelByWeekday: 'Average by weekday',
      panelByWeekdaySub: '· average tokens per active day',
      panelModelByMonth: 'Model share by month',
      panelModelByMonthSub: '· stacked by tokens',
      dsCumulativeTokens: 'Cumulative tokens',
      dsCumulativeCost: 'Cumulative cost ($)',
      tooltip_avgPerActiveDay: (n) => `Average: ${n}`,
      tooltip_activeDaysCount: (n) => `${n} active days`,
      switchToLabel: 'KO',
      switchToTitle: '한국어로 전환',
    },
  };

  const STORAGE_KEY = 'claude-dashboard-lang';

  function detect() {
    try {
      const saved = localStorage.getItem(STORAGE_KEY);
      if (saved === 'ko' || saved === 'en') return saved;
    } catch (e) { /* localStorage may be blocked on file:// */ }
    const nav = (navigator.language || 'en').toLowerCase();
    return nav.startsWith('ko') ? 'ko' : 'en';
  }

  const I18N = {
    lang: detect(),
    t(key, ...args) {
      const v = STRINGS[this.lang][key];
      if (typeof v === 'function') return v(...args);
      return v == null ? key : v;
    },
    dow() {
      return STRINGS[this.lang].dow;
    },
    locale() {
      return STRINGS[this.lang].locale;
    },
    setLang(lang) {
      if (lang !== 'ko' && lang !== 'en') return;
      try { localStorage.setItem(STORAGE_KEY, lang); } catch (e) {}
      this.lang = lang;
      document.documentElement.lang = lang;
      location.reload();
    },
    toggle() {
      this.setLang(this.lang === 'ko' ? 'en' : 'ko');
    },
    // Number formatter respecting locale.
    // KO: 만/억 units. EN: K/M/B units.
    fmt(n) {
      if (n == null || isNaN(n)) return '0';
      n = Math.round(n);
      if (this.lang === 'ko') {
        if (n >= 1e8) {
          const eok = n / 1e8;
          return (eok >= 10 ? Math.round(eok).toLocaleString() : eok.toFixed(1)) + '억';
        }
        if (n >= 1e4) {
          return Math.round(n / 1e4).toLocaleString() + '만';
        }
        return n.toLocaleString();
      } else {
        if (n >= 1e9) {
          const b = n / 1e9;
          return (b >= 10 ? Math.round(b).toLocaleString() : b.toFixed(1)) + 'B';
        }
        if (n >= 1e6) {
          const m = n / 1e6;
          return (m >= 10 ? Math.round(m).toLocaleString() : m.toFixed(1)) + 'M';
        }
        if (n >= 1e4) {
          return (n / 1e3).toFixed(0) + 'K';
        }
        return n.toLocaleString();
      }
    },
    fmtUSD(n) {
      if (n == null || isNaN(n)) n = 0;
      return '$' + (n < 10 ? n.toFixed(2) : Math.round(n).toLocaleString());
    },
    // Replace [data-i18n] text content and [data-i18n-title] tooltips.
    applyDOM(root = document) {
      root.querySelectorAll('[data-i18n]').forEach(el => {
        const key = el.getAttribute('data-i18n');
        el.textContent = this.t(key);
      });
      root.querySelectorAll('[data-i18n-title]').forEach(el => {
        const key = el.getAttribute('data-i18n-title');
        el.title = this.t(key);
      });
      const titleEl = document.querySelector('title[data-i18n]');
      if (titleEl) document.title = this.t(titleEl.getAttribute('data-i18n'));
      document.documentElement.lang = this.lang;
    },
  };

  // Set <html lang> early so screen readers / browsers know.
  document.documentElement.lang = I18N.lang;
  window.CLAUDE_I18N = I18N;
})();
