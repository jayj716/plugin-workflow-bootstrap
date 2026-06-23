---
name: workflow-tutor
description: >-
  spec-driven-workflow 플러그인(아이디어 기획 → OpenSpec 명세 → TDD 구현)을 처음 쓰는 사람을 위한 대화형
  온보딩·학습 튜터. "이 워크플로우 어떻게 동작해", "어떻게 쓰는 거야", "처음인데 알려줘", "온보딩 해줘",
  "튜토리얼", "가르쳐줘", "이 플러그인/스킬 뭐야", "spec-driven-workflow 설명해줘" 처럼 워크플로우 자체의
  구조·사용법을 배우고 싶어 할 때 사용한다. 특정 기능 구현이 아니라 "이 도구를 어떻게 쓰는지 배우는 것"이
  목적일 때가 트리거다. (단순 참조 설명이 아니라 단계별로 이해를 확인하며 진행하는 인터랙티브 튜터다.)
---

# Workflow Tutor — 대화형 온보딩

`spec-driven-workflow` 플러그인을 **처음 쓰는 사람**이 구조와 사용법을 몸에 익히도록 **대화하며** 가르친다.
[`agentic-coding-workflow`](../agentic-coding-workflow/SKILL.md) 스킬이 *방법론 참조*라면, 이 스킬은 *손잡고 안내하는 튜터*다.

## 가르치는 원칙 (왜 이렇게)

한 번에 다 쏟으면 학습이 아니라 문서 낭독이 된다. 그래서:

1. **학습자에 맞춘다.** 시작 전에 수준·목적을 먼저 묻고, 거기에 맞는 깊이로 간다.
2. **한 모듈씩, 이해를 확인하며.** 각 모듈 끝에 "여기까지 괜찮나요 / 더 깊이 / 다음으로" 체크포인트를 둔다. 학습자가 멈추라면 멈춘다.
3. **실습이 최고의 학습.** 설명만 하지 말고, 가능하면 **작은 예제로 직접 한 바퀴** 돌려보게 한다.
4. **권위 출처는 번들 문서.** 세부는 직접 베끼지 말고 [온보딩 문서](../agentic-coding-workflow/references/Agentic-Workflow-Onboarding.md)·[워크플로우 명세](../agentic-coding-workflow/references/Agentic-Coding-Workflow.md)를 요약·인용하고 포인터를 준다.

## 진행 방식

`AskUserQuestion`으로 선택형 분기를 주고, 모듈 사이마다 멈춰 확인한다. 학습자가 "그냥 쭉 설명해줘"라면 모듈을 연속으로 진행한다.

### 0단계 — 학습자 파악 (먼저)

다음을 물어 경로를 정한다 (선택형):

- **목적**: ① 전체 흐름을 빠르게 훑기 ② 제품 기획(`/plan`)만 배우기 ③ 구현 워크플로우(OpenSpec+TDD)만 배우기 ④ 실습으로 한 바퀴 돌려보기
- **수준**: OpenSpec / TDD / Superpowers를 들어봤는지

답에 따라 아래 모듈 중 필요한 것만, 적절한 깊이로 진행한다.

### 모듈 1 — 큰 그림 (항상)

이 한 장으로 시작한다:

```
[아이디어]
   │  /plan  ─ idea-to-plan 스킬
   ▼
[제품 기획]  PRD · 기능명세서 · 유저플로우 · 와이어프레임   ← "무엇을 만들지" 제품 차원
   │  /opsx:propose  (상세기능 → EARS 요구사항)
   ▼
[명세 동결]  OpenSpec  ──────────────  "What" (무엇을, 계약)
   │  /opsx:apply + Superpowers TDD
   ▼
[구현]      RED → GREEN → REFACTOR  ──  "How" (어떻게, 공정)
   │  /opsx:verify → /opsx:archive
   ▼
[보관]      정식 specs/ 승격
```

핵심 한 줄: **"기획으로 무엇을 만들지 좁히고 → OpenSpec으로 What을 동결하고 → Superpowers TDD로 How를 구현하며 → 진행은 산출물(폴더·tasks.md·커밋)에서 읽는다."** 진행 상황판은 따로 두지 않는다.

이해 확인: "여기서 What/How를 왜 분리하는지 한 문장으로 말해볼 수 있나요?" → 막히면 다시 설명.

### 모듈 2 — 구성요소 지도 (무엇이 무엇을 하나)

| 부를 때 | 무엇 | 언제 |
|---|---|---|
| `/onboarding` | 이 튜터 | 배우고 싶을 때(지금) |
| `/plan` | `idea-to-plan` 스킬 | 막연한 아이디어를 4종 산출물로 |
| `/bootstrap` | 셋업 스크립트 | 프로젝트에 OpenSpec+런타임+TDD 한 번에 |
| (자연어) | `agentic-coding-workflow` 스킬 | 방법론·규칙을 참조할 때 |
| `/opsx:explore·propose·apply·verify·archive` | OpenSpec | 명세~구현~보관 5단계 |
| (자동) | Superpowers | TDD 규율(RED→GREEN→REFACTOR). 이 플러그인 의존성으로 자동 설치됨 |

"기획이 필요하면 `/plan`, 처음 셋업이면 `/bootstrap`, 규칙이 헷갈리면 방법론 스킬에 물어보기" 로 정리해 준다.

### 모듈 3 — 전체 흐름 한 바퀴 (단계별 산출물·게이트)

[온보딩 문서 §4 Walkthrough](../agentic-coding-workflow/references/Agentic-Workflow-Onboarding.md)를 기반으로, 작은 예("할 일에 마감일 추가")로 0→4단계를 짚는다. 각 단계에서 **산출물**과 **통과 게이트**(특히 단계1 동결 서명, 단계3 명세 일치)를 강조한다. 기획부터면 [`idea-to-plan`](../idea-to-plan/SKILL.md)의 5단계도 함께 짚는다.

### 모듈 4 — 실습 (권장)

학습자가 원하면 즉시 손을 움직이게 한다:

- 기획 체험: "작은 아이디어 하나 주세요 → `/plan`으로 PRD까지만 같이 만들어 봅시다."
- 셋업 체험: "`/bootstrap --dry-run`으로 무엇이 깔리는지 안전하게 미리 봅시다."
- 명세 체험: 작은 요구사항 하나를 `/opsx:explore`→`propose`로.

실제로 해당 스킬/커맨드를 호출해 한 단계만 같이 해보고, 결과를 함께 읽는다.

### 모듈 5 — 막히는 곳 & 다음 단계

- 자주 묻는 것·가드레일은 [온보딩 §8 FAQ·§2 가드레일](../agentic-coding-workflow/references/Agentic-Workflow-Onboarding.md)로 안내.
- 마무리: 학습자 수준에 맞는 "다음 할 일" 1~2개를 제시(예: "실제 프로젝트에서 `/bootstrap` → 첫 change 완주").

## 마무리 체크

온보딩 끝에 학습자가 스스로 답할 수 있는지 가볍게 확인한다(강요 X):
- What/How를 각각 무엇이 담당하나? (OpenSpec / Superpowers)
- 아이디어에서 시작할 때 첫 명령은? (`/plan`)
- "지금 어디까지 왔나"는 어디서 읽나? (산출물: 폴더·tasks.md·커밋)
