# cc-usage-board

Claude Code 토큰 사용량을 시각화하는 로컬 대시보드.

[ccusage](https://github.com/ryoppippi/ccusage)가 내보낸 JSON을 읽어서 단일
HTML 파일로 차트/카드를 그려준다. 추가로 SwiftBar 플러그인이 들어 있어
macOS 메뉴바에서도 오늘 토큰 사용량을 바로 확인할 수 있다.

![preview](docs/preview.png)

## 화면 구성

- 오늘 / 어제 / 최근 7일 / 이번 달 / 누적 / 플랜 대비 사용률 카드
- 월별 추이 (총 토큰 + 비용 환산) 차트
- 최근 60일 일별 토큰 차트
- 최근 90일 활동 히트맵 (GitHub 스타일)
- 이번 달 모델별 비중

## 요구사항

- macOS (스크립트가 `date -v` BSD 옵션을 사용)
- [Node.js](https://nodejs.org/) — `npx`로 ccusage 실행
- [jq](https://jqlang.github.io/jq/) — SwiftBar 플러그인이 사용 (`brew install jq`)
- (선택) [SwiftBar](https://swiftbar.app/) — 메뉴바 플러그인용

ccusage 자체 동작 조건은 ccusage 문서를 따른다 (Claude Code의 로컬 로그를 읽음).

## 설치

```bash
git clone https://github.com/huhjayeon/cc-usage-board.git ~/claude-dashboard
cd ~/claude-dashboard
./update.sh           # 데이터 첫 생성
open dashboard.html   # 브라우저에서 열기
```

`update.sh`가 `data-daily.json`, `data-monthly.json`, `data-session.json`,
`data.js`를 생성한다. 이 파일들은 `.gitignore`에 들어 있으니 커밋되지 않는다.

## 데이터 갱신

대시보드 우상단의 **새로고침** 버튼은 페이지를 다시 로드만 한다.
실제 데이터 갱신은 터미널에서 한다:

```bash
~/claude-dashboard/update.sh
```

## SwiftBar 플러그인 (선택)

메뉴바에 오늘 토큰을 표시하고 5분마다 자동 갱신한다.

```bash
ln -s ~/claude-dashboard/plugins/claude-usage.5m.sh \
      ~/Library/Application\ Support/SwiftBar/Plugins/claude-usage.5m.sh
```

플러그인 메뉴에서 "대시보드 열기"를 누르면 `dashboard.html`이 열린다.

## 파일별 역할

| 파일 | 역할 |
| --- | --- |
| `dashboard.html` | 메인 UI (HTML/CSS/JS 단일 파일) |
| `update.sh` | ccusage 호출 → `data*.json` / `data.js` 생성 |
| `plugins/claude-usage.5m.sh` | SwiftBar 메뉴바 플러그인 |
| `data.js`, `data-*.json` | 생성된 데이터 (gitignore) |

## 라이선스

MIT — 자세한 내용은 [LICENSE](LICENSE).

내부적으로 [ccusage](https://github.com/ryoppippi/ccusage) (MIT)를 호출한다.
