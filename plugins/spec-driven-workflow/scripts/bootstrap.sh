#!/usr/bin/env bash
#
# bootstrap.sh — Agentic Coding Workflow 프로젝트 부트스트랩
#
# 워크플로우 명세(Agentic-Coding-Workflow.md)와 온보딩 문서
# (Agentic-Workflow-Onboarding.md §3 "처음 한 번 — 셋업")을 그대로 자동화한다.
#
#   1) 사전 점검   : Node 20.19+ / git / npm
#   2) 저장소 클론 : --repo 지정 시 (이미 있으면 건너뜀)
#   3) OpenSpec    : 설치 확인 후 전역(npm -g) 또는 프로젝트(node_modules) 선택 설치
#   4) 런타임      : Claude Code / Codex / Cursor 중 택1 설치
#   5) 구조 생성   : 신규 → openspec init --tools / 기존 → openspec update
#   6) TDD 규율    : Codex→AGENTS.md / Cursor→.cursor/rules / Claude→Superpowers 안내
#   7) 검증·다음 단계 안내
#
# 신규/기존 프로젝트 모두에 적용 가능 — openspec/ 존재 여부로 자동 분기한다.
#
set -euo pipefail

# ─────────────────────────────────────────────────────────────── 기본값
DRY_RUN=false
ASSUME_YES=false
NO_TDD=false
SKIP_OPENSPEC_INSTALL=false
REINSTALL_OPENSPEC=false
SKIP_RUNTIME_INSTALL=false
USE_COLOR=true
REPO=""
DIR=""
RUNTIME=""
TOOLS=""
OPENSPEC_SCOPE=""
OPENSPEC=""

usage() {
  cat <<'EOF'
사용법:  ./bootstrap.sh [옵션]

  -r, --repo <url>          클론할 git 저장소 (선택; 생략 시 현재/--dir 폴더에 적용)
  -d, --dir <path>          프로젝트 디렉터리 (미지정 시 대화형 입력; 기본: 현재 폴더)
  -t, --runtime <name>      실행 런타임: claude | codex | cursor | none
      --tools <list>        openspec init --tools 값 직접 지정 (기본: 런타임에서 유도)
      --openspec-scope <s>  OpenSpec 설치 위치: global | project (미지정 시 대화형 선택)
      --skip-openspec-install   OpenSpec 설치 건너뜀(기존 설치 사용)
      --reinstall-openspec      이미 있어도 OpenSpec 재설치
      --skip-runtime-install    런타임 CLI 설치 건너뜀(구조·설정만)
      --no-tdd              TDD 규율 스캐폴딩 생략
  -y, --yes                 비대화형(기본값/확인 자동 수락)
      --dry-run             실제 실행 없이 계획만 출력
      --no-color            색상 출력 끔
  -h, --help                도움말

예시:
  # 신규 프로젝트를 클론하고 Claude Code 기준으로 부트스트랩
  ./bootstrap.sh --repo git@github.com:team/app.git --runtime claude

  # 현재 폴더(기존 프로젝트)를 Codex 기준으로 갱신, 비대화형
  ./bootstrap.sh --runtime codex --yes

  # 무엇을 할지 먼저 미리보기
  ./bootstrap.sh --repo https://github.com/team/app.git --runtime cursor --dry-run

  # OpenSpec을 전역이 아닌 이 프로젝트에만 설치(디렉터리 지정)
  ./bootstrap.sh --dir ./my-app --runtime claude --openspec-scope project
EOF
}

# ─────────────────────────────────────────────────────────────── 인자 파싱
while [ $# -gt 0 ]; do
  case "$1" in
    -r|--repo)                REPO="${2:?--repo 값 필요}"; shift 2;;
    --repo=*)                 REPO="${1#*=}"; shift;;
    -d|--dir)                 DIR="${2:?--dir 값 필요}"; shift 2;;
    --dir=*)                  DIR="${1#*=}"; shift;;
    -t|--runtime)             RUNTIME="${2:?--runtime 값 필요}"; shift 2;;
    --runtime=*)              RUNTIME="${1#*=}"; shift;;
    --tools)                  TOOLS="${2:?--tools 값 필요}"; shift 2;;
    --tools=*)                TOOLS="${1#*=}"; shift;;
    --openspec-scope)         OPENSPEC_SCOPE="${2:?--openspec-scope 값 필요}"; shift 2;;
    --openspec-scope=*)       OPENSPEC_SCOPE="${1#*=}"; shift;;
    --skip-openspec-install)  SKIP_OPENSPEC_INSTALL=true; shift;;
    --reinstall-openspec)     REINSTALL_OPENSPEC=true; shift;;
    --skip-runtime-install)   SKIP_RUNTIME_INSTALL=true; shift;;
    --no-tdd)                 NO_TDD=true; shift;;
    -y|--yes)                 ASSUME_YES=true; shift;;
    --dry-run)                DRY_RUN=true; shift;;
    --no-color)               USE_COLOR=false; shift;;
    -h|--help)                usage; exit 0;;
    *) printf '알 수 없는 옵션: %s (--help 참고)\n' "$1" >&2; exit 2;;
  esac
done

# ─────────────────────────────────────────────────────────────── 색상·로깅
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ] && $USE_COLOR; then
  C_RED=$'\033[31m'; C_GRN=$'\033[32m'; C_YEL=$'\033[33m'
  C_BLU=$'\033[34m'; C_DIM=$'\033[2m'; C_BLD=$'\033[1m'; C_RST=$'\033[0m'
else
  C_RED=""; C_GRN=""; C_YEL=""; C_BLU=""; C_DIM=""; C_BLD=""; C_RST=""
fi

section() { printf '\n%s%s━━ %s%s\n' "$C_BLD" "$C_BLU" "$1" "$C_RST"; }
ok()      { printf '  %s✓%s %s\n' "$C_GRN" "$C_RST" "$*"; }
warn()    { printf '  %s!%s %s\n' "$C_YEL" "$C_RST" "$*"; }
note()    { printf '  %s· %s%s\n' "$C_DIM" "$*" "$C_RST"; }
step()    { printf '  %s▸%s %s\n' "$C_BLU" "$C_RST" "$*"; }
die()     { printf '\n%s✗ %s%s\n' "$C_RED" "$*" "$C_RST" >&2; exit 1; }

# 명령 실행 래퍼: 항상 출력하고, --dry-run이면 실행하지 않는다
exec_cmd() {
  printf '    %s$ %s%s\n' "$C_DIM" "$*" "$C_RST"
  $DRY_RUN && return 0
  "$@"
}

# $1 >= $2 (점 구분 버전 비교)이면 0 반환
version_ge() {
  local IFS=.
  local -a A B
  A=($1); B=($2)
  local i x y
  for i in 0 1 2; do
    x="${A[i]:-0}"; y="${B[i]:-0}"
    if [ "$((10#$x))" -gt "$((10#$y))" ]; then return 0; fi
    if [ "$((10#$x))" -lt "$((10#$y))" ]; then return 1; fi
  done
  return 0
}

# ─────────────────────────────────────────────────────────────── 런타임 결정
case "${RUNTIME:-}" in
  ""|claude|codex|cursor|none) : ;;
  *) die "런타임 값 오류: '$RUNTIME' (claude | codex | cursor | none)";;
esac
case "${OPENSPEC_SCOPE:-}" in
  ""|global|project) : ;;
  *) die "OpenSpec 설치 위치 오류: '$OPENSPEC_SCOPE' (global | project)";;
esac

if [ -z "$RUNTIME" ]; then
  if $ASSUME_YES || [ ! -t 0 ]; then
    RUNTIME=claude
    note "런타임 미지정 → 기본값 'claude' 사용 (--runtime 으로 변경)"
  else
    printf '실행 런타임을 선택하세요 (팀 표준 하나):\n'
    printf '  1) claude  — Claude Code (+ Superpowers TDD)\n'
    printf '  2) codex   — OpenAI Codex\n'
    printf '  3) cursor  — Cursor\n'
    printf '  4) none    — 런타임 CLI 설치 안 함\n'
    printf '선택 [1-4] (기본 1): '
    read -r _ans || _ans=""
    case "${_ans:-1}" in
      1|claude) RUNTIME=claude;;
      2|codex)  RUNTIME=codex;;
      3|cursor) RUNTIME=cursor;;
      4|none)   RUNTIME=none;;
      *)        RUNTIME=claude;;
    esac
  fi
fi

# openspec init --tools 기본값: 런타임에서 유도 (none → claude)
if [ -z "$TOOLS" ]; then
  case "$RUNTIME" in
    claude|codex|cursor) TOOLS="$RUNTIME";;
    none) TOOLS="claude"; note "런타임 none → 슬래시 커맨드는 'claude'로 설치 (--tools 로 변경)";;
  esac
fi

# 런타임의 슬래시 커맨드가 이미 깔려 있는지 (init 추가 필요 판단용)
runtime_commands_present() {
  case "$RUNTIME" in
    claude) [ -d "$PROJECT_DIR/.claude/commands/opsx" ];;
    cursor) ls "$PROJECT_DIR"/.cursor/commands/opsx-*.md >/dev/null 2>&1;;
    codex)  ls "${CODEX_HOME:-$HOME/.codex}"/prompts/opsx-*.md >/dev/null 2>&1;;
    none)   return 0;;
  esac
}

printf '%s%sAgentic Coding Workflow — 프로젝트 부트스트랩%s\n' "$C_BLD" "$C_BLU" "$C_RST"
$DRY_RUN && warn "DRY-RUN: 실제로는 아무 것도 실행하지 않습니다 (계획만 출력)"
note "런타임=$RUNTIME · openspec tools=$TOOLS"

# ─────────────────────────────────────────────────────── 1) 사전 점검
section "1. 사전 점검 (Node 20.19+, git, npm)"
_fail=0
if command -v node >/dev/null 2>&1; then
  _nv="$(node -v 2>/dev/null | sed 's/^v//')"
  if version_ge "$_nv" "20.19.0"; then ok "Node $_nv"; else warn "Node $_nv — 20.19.0+ 필요"; _fail=1; fi
else
  warn "node 없음 — Node.js 20.19+ 설치 필요"; _fail=1
fi
if command -v npm >/dev/null 2>&1; then ok "npm $(npm -v 2>/dev/null)"; else warn "npm 없음"; _fail=1; fi
if command -v git >/dev/null 2>&1; then ok "git $(git --version 2>/dev/null | awk '{print $3}')"; else warn "git 없음"; _fail=1; fi
if [ "$_fail" -ne 0 ]; then
  $DRY_RUN && warn "사전 점검 경고 (dry-run이라 계속 진행)" || die "사전 요건 불충족 — 위 항목을 먼저 설치하세요"
fi

# ─────────────────────────────────────────────────────── 2) 저장소 클론 / 디렉터리 결정
section "2. 저장소 / 디렉터리"
if [ -n "$REPO" ]; then
  [ -z "$DIR" ] && DIR="$(basename "${REPO%.git}")"
  if [ -e "$DIR/.git" ]; then
    note "이미 클론됨: $DIR (클론 건너뜀)"
  else
    step "git clone $REPO → $DIR"
    exec_cmd git clone "$REPO" "$DIR" || die "git clone 실패: $REPO"
  fi
else
  # 디렉터리 미지정 시 대화형 입력 (비대화형/-y면 현재 폴더)
  if [ -z "$DIR" ]; then
    if ! $ASSUME_YES && [ -t 0 ]; then
      printf '프로젝트 디렉터리 경로를 입력하세요 (없으면 새로 생성, 기본 "."): '
      read -r _dir || _dir=""
      DIR="${_dir:-.}"
    else
      DIR="."
    fi
  fi
  note "클론 없이 적용: $DIR"
fi
DIR="${DIR/#\~/$HOME}"                          # ~ 확장
# 클론이 아닌데 디렉터리가 없으면 생성 (신규 프로젝트)
if [ -z "$REPO" ] && [ ! -d "$DIR" ]; then
  if $DRY_RUN; then note "(dry-run) mkdir -p $DIR"
  else step "디렉터리 생성: $DIR"; mkdir -p "$DIR" || die "디렉터리 생성 실패: $DIR"; fi
fi
# 절대경로화 (없으면 — dry-run의 미생성 — 논리 경로 유지)
if [ -d "$DIR" ]; then PROJECT_DIR="$(cd "$DIR" && pwd)"; else PROJECT_DIR="$DIR"; fi
ok "프로젝트 디렉터리: $PROJECT_DIR"

# 신규 vs 기존 판별
if [ -d "$PROJECT_DIR/openspec" ]; then MODE=update; else MODE=init; fi
note "프로젝트 상태: $([ "$MODE" = update ] && echo '기존(openspec/ 있음) → update' || echo '신규(openspec/ 없음) → init')"

# ─────────────────────────────────────────────────────── 3) OpenSpec 설치 (확인 → 위치 선택)
section "3. OpenSpec 설치 (@fission-ai/openspec)"
LOCAL_OSP="$PROJECT_DIR/node_modules/.bin/openspec"
# 기존 설치 확인: 전역(PATH) 우선, 다음 프로젝트 로컬
if command -v openspec >/dev/null 2>&1; then _have=global
elif [ -x "$LOCAL_OSP" ]; then _have=project
else _have=none; fi

# 기존 설치를 그대로 쓸지 결정 (--reinstall, 또는 명시한 scope와 불일치면 새로 설치)
USE_EXISTING=false
if ! $REINSTALL_OPENSPEC; then
  case "$OPENSPEC_SCOPE" in
    "")      [ "$_have" != none ]   && USE_EXISTING=true ;;
    global)  [ "$_have" = global ]  && USE_EXISTING=true ;;
    project) [ "$_have" = project ] && USE_EXISTING=true ;;
  esac
fi

if $USE_EXISTING; then
  if [ "$_have" = global ]; then
    OPENSPEC="openspec"
    ok "OpenSpec(전역) 이미 설치됨: $(openspec --version 2>/dev/null || echo '?') (재설치는 --reinstall-openspec)"
  else
    OPENSPEC="$LOCAL_OSP"
    ok "OpenSpec(프로젝트) 이미 설치됨: $("$LOCAL_OSP" --version 2>/dev/null || echo '?')"
  fi
elif $SKIP_OPENSPEC_INSTALL; then
  case "$_have" in
    global)  OPENSPEC="openspec";;
    project) OPENSPEC="$LOCAL_OSP";;
    *)       OPENSPEC="openspec"; warn "OpenSpec 미설치인데 설치 건너뜀 — 이후 단계가 실패할 수 있음";;
  esac
  note "OpenSpec 설치 건너뜀 (--skip-openspec-install)"
else
  if [ "$_have" = global ] && [ "$OPENSPEC_SCOPE" = project ]; then
    warn "전역 openspec이 있지만 --openspec-scope project 요청 → 이 프로젝트에 별도 설치합니다"
  fi
  # 설치 필요 → 위치 결정: 플래그 → 대화형 → 기본 global
  if [ -z "$OPENSPEC_SCOPE" ]; then
    if $ASSUME_YES || [ ! -t 0 ]; then
      OPENSPEC_SCOPE=global
      note "OpenSpec 설치 위치 미지정 → 기본 'global' (--openspec-scope 로 변경)"
    else
      printf 'OpenSpec을 어디에 설치할까요?\n'
      printf '  1) global   — 전역 설치(npm -g), 모든 프로젝트에서 사용\n'
      printf '  2) project  — 이 프로젝트에만(node_modules), 실행은 npx openspec\n'
      printf '선택 [1-2] (기본 1): '
      read -r _ans || _ans=""
      case "${_ans:-1}" in
        2|project) OPENSPEC_SCOPE=project;;
        *)         OPENSPEC_SCOPE=global;;
      esac
    fi
  fi
  if [ "$OPENSPEC_SCOPE" = project ]; then
    if [ ! -f "$PROJECT_DIR/package.json" ]; then
      step "package.json 생성 (npm init -y)"
      $DRY_RUN || ( cd "$PROJECT_DIR" && npm init -y >/dev/null 2>&1 ) || die "npm init 실패"
    fi
    step "OpenSpec 프로젝트 설치 (npm install -D @fission-ai/openspec@latest)"
    exec_cmd npm install --save-dev --prefix "$PROJECT_DIR" @fission-ai/openspec@latest \
      || die "OpenSpec 프로젝트 설치 실패"
    OPENSPEC="$LOCAL_OSP"
    note "이 프로젝트에선 openspec을 'npx openspec' 으로 실행하세요"
  else
    step "OpenSpec 전역 설치 (npm install -g @fission-ai/openspec@latest)"
    exec_cmd npm install -g @fission-ai/openspec@latest \
      || die "OpenSpec 전역 설치 실패 — 권한 오류면 nvm 사용 또는 npm 전역 prefix(~/.npm-global 등)를 확인하세요"
    OPENSPEC="openspec"
  fi
fi
OPENSPEC="${OPENSPEC:-openspec}"   # 안전장치

# ─────────────────────────────────────────────────────── 4) 런타임 설치
section "4. 실행 런타임 설치 ($RUNTIME)"
if $SKIP_RUNTIME_INSTALL; then
  note "런타임 CLI 설치 건너뜀 (--skip-runtime-install)"
else
  case "$RUNTIME" in
    claude)
      if command -v claude >/dev/null 2>&1; then note "Claude Code 이미 설치됨"; else
        step "npm install -g @anthropic-ai/claude-code"
        exec_cmd npm install -g @anthropic-ai/claude-code || die "Claude Code 설치 실패"
      fi ;;
    codex)
      if command -v codex >/dev/null 2>&1; then note "Codex 이미 설치됨"; else
        step "npm install -g @openai/codex (실패 시 brew --cask 폴백)"
        if exec_cmd npm install -g @openai/codex; then
          :
        elif command -v brew >/dev/null 2>&1; then
          warn "npm 설치 실패 → brew 시도"
          exec_cmd brew install --cask codex || die "Codex 설치 실패 (npm·brew 모두 실패)"
        else
          die "Codex 설치 실패 (npm 실패, brew 없음)"
        fi
      fi ;;
    cursor)
      if command -v cursor >/dev/null 2>&1; then
        note "Cursor CLI(cursor) 이미 있음"
      else
        warn "Cursor는 GUI 앱 — 수동 설치 필요:"
        printf '      1) https://cursor.com 에서 앱 다운로드·설치\n'
        printf '      2) %s\n' "앱에서 Cmd/Ctrl+Shift+P → \"Install 'cursor' command\" 실행"
      fi ;;
    none)
      note "런타임 CLI 설치 안 함 (--runtime none)" ;;
  esac
fi

# ─────────────────────────────────────────────────────── 5) OpenSpec 구조 생성/업데이트
section "5. OpenSpec 구조 ($MODE)"
if ! command -v "$OPENSPEC" >/dev/null 2>&1; then
  if $DRY_RUN; then note "openspec 미설치(dry-run) — 설치되었다고 가정하고 계획 출력"
  else die "openspec 명령을 찾을 수 없습니다 — 3단계 설치를 확인하세요"; fi
fi
FORCE=""; $ASSUME_YES && FORCE="--force"
if [ "$MODE" = update ]; then
  step "openspec update $PROJECT_DIR"
  exec_cmd "$OPENSPEC" update "$PROJECT_DIR" $FORCE || die "openspec update 실패"
fi
# 신규이거나, 기존이지만 내 런타임의 슬래시 커맨드가 없으면 init 으로 (추가) 설치
if [ "$MODE" = init ] || ! runtime_commands_present; then
  [ "$MODE" = update ] && note "기존 프로젝트에 '$RUNTIME' 슬래시 커맨드가 없어 추가 설치합니다"
  step "openspec init $PROJECT_DIR --tools $TOOLS"
  exec_cmd "$OPENSPEC" init "$PROJECT_DIR" --tools "$TOOLS" $FORCE || die "openspec init 실패"
else
  note "'$RUNTIME' 슬래시 커맨드 이미 존재 — init 생략"
fi

# ─────────────────────────────────────────────────────── 6) TDD 규율
section "6. TDD 규율 (RED → GREEN → REFACTOR)"
if $NO_TDD; then
  note "TDD 스캐폴딩 생략 (--no-tdd)"
else
  case "$RUNTIME" in
    claude|none)
      note "Claude Code의 TDD는 Superpowers 플러그인이 강제합니다."
      note "spec-driven-workflow v0.2.0+ 설치 시 의존성으로 자동 설치됩니다."
      printf '      자동 설치가 안 됐다면 Claude Code 세션에서 수동 설치:\n'
      printf '        /plugin install superpowers@claude-plugins-official\n'
      printf '        (또는: /plugin marketplace add obra/superpowers-marketplace\n'
      printf '               → /plugin install superpowers@superpowers-marketplace)\n'
      printf '      확인: /help 목록에 /superpowers:brainstorm 표시\n' ;;
    codex)
      f="$PROJECT_DIR/AGENTS.md"
      if [ -f "$f" ] && grep -q 'openspec-bootstrap:tdd' "$f" 2>/dev/null; then
        note "AGENTS.md에 TDD 규율 이미 있음 (건너뜀)"
      else
        step "AGENTS.md에 TDD 규율 추가"
        if $DRY_RUN; then
          printf '    %s(dry-run) append TDD block → %s%s\n' "$C_DIM" "$f" "$C_RST"
        else
          { [ -f "$f" ] && printf '\n'
            cat <<'TDDBLOCK'
<!-- openspec-bootstrap:tdd -->
## 개발 규율 — TDD

모든 구현은 **실패하는 테스트(RED)** 에서 시작한다.
각 작업(`openspec/changes/<slug>/tasks.md`의 한 줄)마다:

1. **RED** — 그 작업을 표현하는 실패하는 테스트를 먼저 쓴다.
2. **GREEN** — 테스트를 통과시키는 최소 코드만 쓴다.
3. **REFACTOR** — green을 유지하며 정리한다.
4. `tasks.md` 항목을 `[x]`로 바꾸고, change 폴더의 `notes.md`에 핸드오프 한 줄을 남긴다.

규칙:
- 테스트 없는 코드는 워크플로우 위반이다.
- `tasks.md`에 없는 작업은 하지 않는다 — 필요하면 명세(단계 1)부터 고친다.
- 동결된 명세(스펙 = SOT)와 코드가 다르면 명세에 맞춘다. 명세가 틀렸으면 명세를 먼저 고친다.
<!-- /openspec-bootstrap:tdd -->
TDDBLOCK
          } >> "$f"
          ok "AGENTS.md 갱신: $f"
        fi
      fi ;;
    cursor)
      d="$PROJECT_DIR/.cursor/rules"; f="$d/tdd.mdc"
      if [ -f "$f" ]; then
        note ".cursor/rules/tdd.mdc 이미 있음 (건너뜀)"
      else
        step ".cursor/rules/tdd.mdc 생성"
        if $DRY_RUN; then
          printf '    %s(dry-run) create %s%s\n' "$C_DIM" "$f" "$C_RST"
        else
          mkdir -p "$d"
          cat > "$f" <<'CURSORRULE'
---
description: TDD 규율 (RED → GREEN → REFACTOR)
alwaysApply: true
---

모든 구현은 실패하는 테스트(RED)에서 시작한다. 각 작업마다 RED → GREEN → REFACTOR:
- RED: 작업을 표현하는 실패 테스트를 먼저 쓴다.
- GREEN: 통과시키는 최소 코드만 쓴다.
- REFACTOR: green을 유지하며 정리한다.

규칙:
- 테스트 없는 코드는 금지.
- tasks.md에 없는 작업은 하지 않는다 (명세부터 고친다).
- 동결된 명세(SOT)와 코드가 다르면 명세에 맞춘다.
CURSORRULE
          ok ".cursor/rules/tdd.mdc 생성: $f"
        fi
      fi ;;
  esac
fi

# ─────────────────────────────────────────────────────── 7) 검증 (온보딩 §3.4)
section "7. 검증"
if command -v "$OPENSPEC" >/dev/null 2>&1 && ! $DRY_RUN; then
  if ( cd "$PROJECT_DIR" && "$OPENSPEC" list >/dev/null 2>&1 ); then
    ok "openspec list 동작"
  else
    warn "openspec list 실패 — 프로젝트 폴더에서 수동 확인 필요"
  fi
else
  note "openspec list 확인 생략 (dry-run 또는 미설치)"
fi
if [ "$RUNTIME" != none ] && ! $DRY_RUN; then
  if runtime_commands_present; then ok "런타임 슬래시 커맨드 확인됨 ($RUNTIME)"
  else warn "런타임 슬래시 커맨드 미확인 ($RUNTIME) — openspec init --tools $TOOLS 재확인"; fi
fi

# ─────────────────────────────────────────────────────── 다음 단계
RT="$RUNTIME"; [ "$RT" = none ] && RT=claude
if [ "$RT" = claude ]; then PFX="/opsx:"; else PFX="/opsx-"; fi
section "완료 — 다음 단계 (온보딩 §4 Walkthrough)"
printf '  첫 변경을 0→4단계로 완주하세요:\n'
printf '    0. 탐색   %s%sexplore%s\n'  "$C_BLD" "$PFX" "$C_RST"
printf '    1. 명세   %s%spropose%s   (요구사항은 EARS로)\n' "$C_BLD" "$PFX" "$C_RST"
printf '    2. 구현   %s%sapply%s     (RED→GREEN→REFACTOR)\n' "$C_BLD" "$PFX" "$C_RST"
printf '    3. 검증   %s%sverify%s\n'  "$C_BLD" "$PFX" "$C_RST"
printf '    4. 보관   %s%sarchive%s\n' "$C_BLD" "$PFX" "$C_RST"
printf '  진행 상황은 산출물에서 읽습니다: openspec list · tasks.md 체크 · git log\n'
printf '  자세한 내용 → %sAgentic-Workflow-Onboarding.md%s (§4·§5·§6)\n' "$C_DIM" "$C_RST"
$DRY_RUN && warn "DRY-RUN 이었습니다 — 실제 적용하려면 --dry-run 없이 다시 실행하세요"
