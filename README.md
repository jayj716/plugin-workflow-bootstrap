# spec-driven-workflow

아이디어 한 줄을 **제품 기획 → 스펙주도 구현**까지 끌고 가는 Claude Code 플러그인.
manyfast의 "Manny" 기획 흐름과 OpenSpec/Superpowers 워크플로우를 하나로 묶었다.

```
[아이디어] ─▶ /plan (idea-to-plan)         ─▶ agentic-coding-workflow ─▶ 구현
            PRD·기능명세·유저플로우·와이어프레임   OpenSpec(What) + TDD(How)
```

## 구성

| 종류 | 이름 | 역할 |
|---|---|---|
| Skill | **idea-to-plan** | 대화형 인터뷰 → PRD·기능명세서·유저플로우·와이어프레임 4종 생성, 변경 전파로 정합성 유지 |
| Skill | **agentic-coding-workflow** | OpenSpec(What)+Superpowers TDD(How) 스펙주도 방법론. 방법론 문서 2종 + 온보딩 번들 |
| Skill | **workflow-tutor** | 처음 쓰는 사람을 위한 **대화형 온보딩** — 구조·사용법을 모듈별로 가르침 |
| Command | **/plan** | idea-to-plan 진입점 |
| Command | **/bootstrap** | 셋업 스크립트 실행(인자 없으면 dry-run 먼저) |
| Command | **/onboarding** | workflow-tutor 진입점 (대화형 학습) |
| Script | **scripts/bootstrap.sh** | OpenSpec + 런타임 + TDD 규율 한 방 셋업 |

```
spec-driven-workflow/
├── .claude-plugin/{plugin.json, marketplace.json}
├── skills/
│   ├── idea-to-plan/            # 기획 파이프라인 (SKILL.md + references 6종)
│   ├── agentic-coding-workflow/ # 방법론 (SKILL.md + references 2종)
│   └── workflow-tutor/          # 대화형 온보딩 튜터
├── commands/{plan.md, bootstrap.md, onboarding.md}
├── scripts/bootstrap.sh
└── README.md
```

## 설치 (로컬 개발)

플러그인 디렉터리를 직접 로드한다 — 마켓플레이스 없이 어디서든:

```bash
claude --plugin-dir ~/spec-driven-workflow
```

이미 실행 중인 세션에서 플러그인을 고쳤다면:

```
/reload-plugins
```

설치되면 `/plan`, 그리고 `idea-to-plan`·`agentic-coding-workflow` 스킬이 활성화된다.

## 사용

```
/plan 동네 클라이밍장 회원용 볼더링 기록 앱을 만들고 싶어
```

또는 그냥 자연어로 "이런 아이디어가 있는데 기획해줘"라고 하면 `idea-to-plan` 스킬이 트리거된다.
기획이 끝나면 "이제 구현하자"로 `agentic-coding-workflow`(OpenSpec/TDD)로 넘어간다.

## 팀 배포 (나중에 — git 마켓플레이스)

1. 이 디렉터리를 git 저장소로 만들어 push
2. `.claude-plugin/marketplace.json` 추가 (plugins 배열에 이 플러그인 등록, `source: "./"`)
3. 팀원: `/plugin marketplace add <repo-url>` → `/plugin install spec-driven-workflow@<marketplace>`

## 의존성

- **Superpowers (자동 설치)** — TDD 규율(RED→GREEN→REFACTOR)을 강제하는 플러그인. `plugin.json`의
  `dependencies`에 `superpowers@claude-plugins-official`로 선언돼 있어, 이 플러그인을 설치하면 **함께 자동 설치**된다.
  (Claude Code v2.1.110+ 필요. 다른 마켓플레이스라 `marketplace.json`의 `allowCrossMarketplaceDependenciesOn`도 선언됨.)
  자동 설치가 안 되면 수동으로: `/plugin install superpowers@claude-plugins-official`.
- **OpenSpec (별도)** — `agentic-coding-workflow`의 `/opsx:*` 슬래시 커맨드는 OpenSpec이 자체 설치한다
  (`openspec init`/`update`, 또는 번들 `/bootstrap`). 이 플러그인은 방법론·문서·bootstrap만 제공하고 OpenSpec 도구 자체는 번들하지 않는다.
