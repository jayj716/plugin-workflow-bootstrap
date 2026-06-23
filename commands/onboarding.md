---
description: spec-driven-workflow 대화형 온보딩 — 구조와 사용법을 단계별로 배우기
argument-hint: "[배우고 싶은 것 — 예: '전체 흐름', '기획만', '실습']"
---

# /onboarding — 워크플로우 온보딩

이 플러그인(아이디어 기획 → OpenSpec 명세 → TDD 구현)의 구조와 사용법을 **대화하며** 배운다.

## Dispatch

1. 같은 플러그인의 번들 스킬 지침을 그대로 읽고 따른다: `skills/workflow-tutor/SKILL.md`
2. `/onboarding` 뒤에 배우고 싶은 것(`$ARGUMENTS`)이 있으면 그것을 0단계(학습자 파악)의 답으로 삼아 바로 해당 모듈로 들어간다. 비어 있으면 0단계 질문부터 시작한다.
3. 한 모듈씩, 이해를 확인하며 진행한다. 학습자가 "쭉 설명해줘"라면 연속 진행한다.
