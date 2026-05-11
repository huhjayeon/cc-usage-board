# cc-usage-board

Claude Code 토큰 사용량을 시각화하는 로컬 대시보드.

[ccusage](https://github.com/ryoppippi/ccusage)가 내보낸 JSON을 단일 HTML
파일에서 차트로 그려준다. 추가로 SwiftBar 플러그인이 들어 있어 macOS
메뉴바에서도 오늘 사용량과 비용을 바로 확인할 수 있다.

> Claude Code의 로컬 사용 기록을 읽어 보여주는 도구로, 외부 서버에 데이터를
> 보내지 않는다. 생성된 데이터(`data*.json`, `data.js`)는 `.gitignore`에
> 포함되어 있어 실수로 커밋되지 않는다.

## 화면 구성

- **카드**: 오늘 / 어제 / 최근 7일 / 이번 달 / 누적 / 플랜 대비 사용률
- **월별 추이**: 총 토큰 + 비용 환산 ($)
- **최근 60일 일별 토큰** 차트
- **활동 히트맵**: 최근 90일 (GitHub 스타일)
- **이번 달 모델별 비중** 도넛 차트

## 요구사항

| 항목 | 비고 |
| --- | --- |
| macOS | 스크립트가 BSD `date -v` 옵션을 사용. Linux는 수정 필요 |
| [Node.js](https://nodejs.org/) 18+ | `npx`로 ccusage 실행 |
| [Claude Code](https://docs.claude.com/claude-code) | ccusage가 읽을 로컬 로그가 있어야 함 (`~/.claude/`) |
| [jq](https://jqlang.github.io/jq/) (선택) | SwiftBar 플러그인용. `brew install jq` |
| [SwiftBar](https://swiftbar.app/) (선택) | 메뉴바 플러그인용 |

## 설치 (3분)

```bash
# 1) 클론
git clone https://github.com/huhjayeon/cc-usage-board.git ~/claude-dashboard
cd ~/claude-dashboard

# 2) 실행 권한
chmod +x update.sh plugins/claude-usage.5m.sh

# 3) 데이터 첫 생성 (ccusage가 npx로 자동 설치됨, 30초~1분)
./update.sh

# 4) 브라우저로 열기
open dashboard.html
```

처음 실행 시 `npx`가 ccusage를 다운로드한다. `data-daily.json`,
`data-monthly.json`, `data-session.json`, `data.js`가 생성되면 준비 완료.

## 데이터 갱신

`update.sh`를 실행할 때마다 데이터가 새로고침된다.

```bash
~/claude-dashboard/update.sh
```

대시보드 우상단의 **새로고침** 버튼은 페이지를 다시 로드만 한다(데이터는
파일에서 읽기 때문에 `update.sh`를 먼저 실행해야 최신 값이 보인다).

cron이나 launchd로 주기적으로 돌릴 수도 있다:

```bash
# 예시: 5분마다
*/5 * * * * $HOME/claude-dashboard/update.sh >/dev/null 2>&1
```

## SwiftBar 플러그인 (선택)

메뉴바에 오늘 토큰/비용을 표시하고 5분마다 자동 갱신한다. 작업량에 따라
이모지가 바뀐다 (💤 / 🟢 / 🟡 / 🟠 / 🔥).

```bash
# SwiftBar 설치 (미설치 시)
brew install --cask swiftbar

# 플러그인 폴더에 심볼릭 링크
ln -s ~/claude-dashboard/plugins/claude-usage.5m.sh \
      ~/Library/Application\ Support/SwiftBar/Plugins/claude-usage.5m.sh
```

메뉴 항목:
- 오늘 / 어제 / 최근 7일 / 이번 달 토큰·비용
- **대시보드 열기** — `dashboard.html`을 브라우저에서 열기
- **지금 갱신** — `update.sh` 즉시 실행
- **폴더 열기** — 프로젝트 폴더 열기

## 파일별 역할

| 파일 | 역할 |
| --- | --- |
| `dashboard.html` | 메인 UI (HTML/CSS/JS 단일 파일, Chart.js CDN) |
| `update.sh` | ccusage 호출 → `data*.json` / `data.js` 생성 |
| `plugins/claude-usage.5m.sh` | SwiftBar 메뉴바 플러그인 |
| `data.js`, `data-*.json` | 생성된 데이터 (gitignore) |

## 트러블슈팅

**`./update.sh` 실행 시 "command not found: npx"**
Node.js 미설치. `brew install node` 또는 [공식 설치](https://nodejs.org/).

**`update.sh`가 빈 데이터를 만든다**
Claude Code 로컬 로그가 없는 것. Claude Code를 한 번이라도 써야 `~/.claude/`에
사용 기록이 쌓인다. ccusage 동작 조건은
[ccusage README](https://github.com/ryoppippi/ccusage)를 참고.

**대시보드에서 차트가 비어 보인다**
- `data.js`가 생성됐는지 확인: `ls ~/claude-dashboard/data.js`
- 브라우저 콘솔(⌥⌘I)에서 `window.CLAUDE_DATA` 출력 확인
- 일부 브라우저는 `file://` 프로토콜에서 `<script src="data.js">`를 차단할
  수 있다. 그럴 땐 `python3 -m http.server 8000`로 띄우고
  `http://localhost:8000/dashboard.html`로 접속

**SwiftBar 플러그인에 `🤖 jq 필요`만 보인다**
`brew install jq` 후 SwiftBar 메뉴에서 "Refresh All".

**Linux/WSL에서 쓰고 싶다**
`update.sh`는 이식 가능하지만, 플러그인의 `date -v`(BSD) 옵션을 GNU
`date -d`로 바꿔야 한다. PR 환영.

## 라이선스

MIT — 자세한 내용은 [LICENSE](LICENSE).

내부적으로 [ccusage](https://github.com/ryoppippi/ccusage) (MIT)를 호출한다.
차트는 [Chart.js](https://www.chartjs.org/) (MIT) 사용.
