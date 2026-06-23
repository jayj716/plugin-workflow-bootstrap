---
description: Agentic Coding Workflow 프로젝트 부트스트랩 (OpenSpec + 런타임 + TDD 규율 셋업)
argument-hint: "[--repo <url>] [--dir <path>] [--runtime claude|codex|cursor|none] [--openspec-scope global|project] [--dry-run] [--yes]"
allowed-tools: Bash
---

# /bootstrap — 워크플로우 셋업

번들된 `scripts/bootstrap.sh`를 실행해, 이 프로젝트(또는 새 저장소)에 **OpenSpec + 실행 런타임 + TDD 규율**을
한 번에 깐다. 동작·옵션의 근거는 같은 플러그인의 `agentic-coding-workflow` 스킬과 그 references(온보딩 §3) 참조.

## 실행 방법

스크립트 경로는 `${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap.sh` 이다. 현재 작업 디렉터리(프로젝트 루트)에서 실행한다.

> 주의: 슬래시 커맨드는 TTY 없이 Bash로 실행되므로, `bootstrap.sh`는 **비대화형으로 기본값**(런타임=claude, OpenSpec=global)을 쓴다. 다른 선택이 필요하면 사용자가 플래그로 넘겨야 한다.

### 분기

1. **인자가 있으면**(`$ARGUMENTS` 비어있지 않음): 그대로 실행한다.
   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap.sh" $ARGUMENTS
   ```

2. **인자가 없으면**: 파괴적 변경(전역 설치·파일 생성)을 막기 위해 **먼저 계획만** 보여준다.
   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap.sh" --dry-run --yes
   ```
   그 출력을 사용자에게 보여주고, "이대로 실제 적용할까요? (런타임/OpenSpec 위치를 바꾸려면 플래그를 알려주세요)"라고 물어 **확인을 받은 뒤에만** `--dry-run` 없이(필요 플래그를 붙여) 다시 실행한다.

## 실행 후

- 스크립트의 7단계 출력(사전점검 → … → 다음 단계)을 사용자에게 요약한다.
- 끝나면 첫 변경을 `/opsx:explore` → `/opsx:propose` → `/opsx:apply` → `/opsx:verify` → `/opsx:archive`로 완주하도록 안내한다.
- 기획부터 시작하고 싶다면 `/plan`(idea-to-plan)으로 연결한다.
