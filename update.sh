#!/bin/bash
# update.mjs로 위임 (실제 로직은 거기 있음).
# macOS/Linux용 편의 래퍼. Windows에서는 `node update.mjs`를 직접 실행하세요.
exec node "$(cd "$(dirname "$0")" && pwd)/update.mjs"
