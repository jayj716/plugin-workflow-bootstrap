---
name: agentic-coding-workflow
description: >-
  에이전트와 코드를 쓸 때 "무엇을(What)"은 OpenSpec으로 동결하고 "어떻게(How)"는 Superpowers TDD로 구현하며,
  진행 상태는 별도 보드 없이 산출물(폴더·tasks.md·커밋)에서 읽는 스펙주도(SDD) 워크플로우. 사용자가 "이 프로젝트는
  어떻게 일하나", "워크플로우/온보딩 알려줘", "OpenSpec·Superpowers·TDD로 셋업하자", "스펙주도 개발", "EARS로
  요구사항 쓰자", "진행 상황 어떻게 추적해", "bootstrap 돌려줘"처럼 개발 방법론·프로세스·온보딩·셋업을 물을 때
  반드시 사용한다. 특정 버그 수정이 아니라 "우리가 어떻게 일하는가"가 주제일 때가 트리거다.
---

# Agentic Coding Workflow (스펙주도 개발)

> 이 워크플로우(방법론·문서)는 **정원규 팀장님**이 설계·구성·작성했다. 정본(SOT)은 upstream 저장소
> [`jayj716/scm-agentic-workflow`](https://github.com/jayj716/scm-agentic-workflow/tree/main/docs)의 `docs/`이며, `references/`의 문서 2종은 그 사본이다.

에이전트 시대의 핵심 문제는 "에이전트가 코드를 못 쓰는 것"이 아니라 **의도(intent)와 공정(process)이 흩어져 사람이 통제권을 잃는 것**이다.
이 워크플로우의 한 줄 요약:

> **OpenSpec으로 "무엇을(What)"을 동결하고, Superpowers의 TDD로 "어떻게(How)"를 구현하며, 진행은 산출물에서 읽는다.**

## 두 축의 분리

| 축 | 질문 | 담당 | 산출물 |
|---|---|---|---|
| **What** | 무엇을 만들 것인가 | OpenSpec | 동결된 명세(EARS) · 작업목록(tasks.md) |
| **How** | 어떻게 만들 것인가 | Superpowers (TDD) | RED→GREEN→REFACTOR 커밋 |

"지금 어디까지 왔나"는 **세 번째 축이 아니다.** 별도 진행판을 두지 않고, change 폴더 위치(`changes/` ↔ `archive/`)·`tasks.md` 체크·커밋 이력에서 *읽는다*. 옮겨 적는 순간 표류(drift)가 시작되기 때문이다.

## 5단계 라이프사이클

```
0.탐색 → 1.명세(What) → 2.구현(How·TDD) → 3.검증·리뷰 → 4.보관
                              ↑__________________|  (반려 시)
```

| 단계 | 트리거 | 산출물 | 통과 게이트 |
|---|---|---|---|
| 0 탐색 | `/opsx:explore` 또는 `/plan`(확장 기획) | 문제 정의·결정 노트 (또는 PRD~와이어프레임) | "무엇을" 한 문장 |
| 1 명세 | `/opsx:propose` | `changes/{slug}/` (proposal·specs(EARS)·tasks) | 사람의 **동결 서명** |
| 2 구현 | `/opsx:apply` + TDD | RED→GREEN→REFACTOR 커밋 | 모든 task `[x]`, green |
| 3 검증 | `/opsx:verify` | 테스트 green·리뷰 | 명세 일치 확인 |
| 4 보관 | `/opsx:archive` | 정식 `specs/` 승격 | `archive/`로 이동 |

> **단계 0(탐색) ↔ idea-to-plan 관계:** 같은 플러그인의 **`idea-to-plan` 스킬**(`/plan`)은 단계 0 탐색을 *확장*한 제품 기획 레이어다(PRD·기능명세·유저플로우·와이어프레임). `/plan`으로 기획을 마쳤다면 탐색은 끝난 것이므로 **`/opsx:explore`를 건너뛰고** 단계 1(`/opsx:propose`)로 간다. 반대로 제품 기획이 필요 없는 가벼운 변경 하나면 `/plan` 없이 `/opsx:explore`만 써도 된다(둘은 형제 진입점). 기획 산출물의 **상세기능**이 단계 1의 EARS 요구사항으로 내려온다.

## 불가침 원칙 (가드레일)

1. **스펙이 SOT다.** 코드·테스트·기억이 명세와 다르면 명세에 맞춘다. 명세가 틀렸으면 코드가 아니라 **명세를 먼저 고친다**.
2. **테스트 없는 구현 금지.** 모든 코드는 실패하는 테스트(RED)에서 시작한다.
3. **명세에 없으면 안 만든다.** `tasks.md`에 없는 작업 금지 — 필요하면 1단계로.
4. **진행판 금지.** 진행은 산출물에서 읽는다.
5. **끝내기 전 노트.** 세션 끝엔 핸드오프 노트, 비자명한 결정엔 결정 노트.

## 더 읽기 (references/)

상세는 아래 문서를 읽는다 — 필요할 때만 로드(progressive disclosure).

- **[references/Agentic-Coding-Workflow.md](references/Agentic-Coding-Workflow.md)** — 워크플로우 **명세 원본**(SOT). 단계별 입력/산출물/게이트, 정보 흐름, EARS 패턴(§8.1), 거버넌스 전문.
- **[references/Agentic-Workflow-Onboarding.md](references/Agentic-Workflow-Onboarding.md)** — 신규 합류자용 실전 온보딩. 셋업(§3), 첫 변경 따라하기(§4), IDE별 슬래시 커맨드 표(§5), FAQ, 치트시트.

## 셋업 (bootstrap)

OpenSpec + 런타임(택1) + TDD 규율을 한 번에 까는 스크립트가 번들돼 있다:

```bash
# 신규(저장소 클론까지)
bash ${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap.sh --repo <팀 저장소> --runtime claude
# 기존(현재 폴더)
bash ${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap.sh --runtime codex --yes
# 계획만 보기
bash ${CLAUDE_PLUGIN_ROOT}/scripts/bootstrap.sh --dry-run
```

옵션 없이 실행하면 대화형으로 디렉터리·OpenSpec 설치 위치·런타임을 묻는다. 자세한 셋업 절차는 온보딩 문서 §3 참조.
