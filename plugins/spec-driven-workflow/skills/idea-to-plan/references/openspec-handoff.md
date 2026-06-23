# OpenSpec 핸드오프 (5단계)

기획(PRD~와이어프레임)이 끝나고 사용자가 "이제 구현하자"라고 할 때만 수행한다.
에이전틱 코딩 워크플로우 — OpenSpec(What) → Superpowers(How·TDD) — 로 넘기는 다리다.
(프로젝트에 워크플로우 문서가 있으면 `workflows/Agentic-Coding-Workflow.md` 참조. OpenSpec이 설치돼 있지 않으면 이 단계는 생략 가능하다.)

## 핵심 매핑: 상세기능 → EARS 요구사항

기능명세서의 **상세기능(`#### N.M.K`)** 하나가 OpenSpec의 **EARS 요구사항** 한 줄이 된다.
EARS는 `WHEN/WHILE/IF·THEN/WHERE + "~해야 한다"` 패턴 (워크플로우 문서 §8.1 참조).

| 기능명세 | OpenSpec |
|---|---|
| 요구사항 `## N` | 하나의 change (`openspec/changes/{slug}/`) |
| 기능 `### N.M` | specs 안의 한 그룹 |
| 상세기능 `#### N.M.K` | EARS 요구사항 1줄 → `tasks.md` 1줄 → RED 테스트 1개 |
| 수용 기준 | change의 검증 기준 |

### 변환 예시

```
기능명세 상세기능:
  #### 1.1.2 세션 생성 API 엔드포인트
  클라이언트의 세션 생성 요청을 처리. 입력 검증, 메타데이터 저장, VM 초기화 명령 전송.

EARS 요구사항:
  - WHEN 사용자가 유효한 세션 생성 요청을 보내면, 시스템은 입력을 검증하고 세션 메타데이터를 저장한 뒤 VM에 초기화 명령을 전송해야 한다.
  - IF 입력 검증에 실패하면, THEN 시스템은 세션을 생성하지 않고 검증 오류를 반환해야 한다.
```

## 절차

1. 구현할 **요구사항(`## N`) 하나**를 고른다 — 한 번에 하나의 change.
2. 그 아래 상세기능들을 위 패턴으로 EARS 요구사항으로 변환.
3. `/opsx:propose`(Claude Code) 또는 `/opsx-propose`(Codex/Cursor)를 호출하고, 변환한 내용을 입력으로 준다.
   - 슬래시 커맨드가 없으면 `openspec` CLI를 직접 쓰고 나머지는 자연어로 지시한다 (워크플로우 §5 폴백).
4. 생성된 `openspec/changes/{change-slug}/`의 proposal·specs·tasks를 사람이 검토·**동결**.
5. 이후는 워크플로우의 2단계(TDD 구현)로 — 이 스킬의 책임 범위를 벗어난다.

## 추적성

- change의 proposal.md 상단에 `기획 출처: planning/{slug}/feature-spec.md §N` 을 남겨, 어느 기획 항목에서 왔는지 역추적 가능하게 한다.
- 기획이 SOT가 아니라 **OpenSpec 동결 명세가 구현의 SOT**다(워크플로우 원칙). 기획 문서는 그 앞단 입력일 뿐 — 동결 이후 충돌 시 명세가 이긴다.
