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
├── .claude-plugin/{plugin.json, marketplace.json}   # Claude Code
├── .codex-plugin/plugin.json                        # Codex (같은 skills/·commands/ 재사용)
├── skills/
│   ├── idea-to-plan/            # 기획 파이프라인 (SKILL.md + references 6종)
│   ├── agentic-coding-workflow/ # 방법론 (SKILL.md + references 2종)
│   └── workflow-tutor/          # 대화형 온보딩 튜터
├── commands/{plan.md, bootstrap.md, onboarding.md}
├── scripts/bootstrap.sh
└── README.md
```

## 설치

하나의 저장소를 **Claude Code 플러그인 · Codex 플러그인 · `npx skills`** 세 가지로 설치할 수 있다.
공통 저장소 URL: `http://gitlab.prd.console.trombone.okestro.cloud/th.oh/agentic-coding-workflow.git`

### Claude Code (권장 · 팀원용)

```bash
claude plugin marketplace add http://gitlab.prd.console.trombone.okestro.cloud/th.oh/agentic-coding-workflow.git
claude plugin install spec-driven-workflow@agentic-coding-workflow
```

그다음 **Claude 재시작**. 설치되면 커맨드 `/plan`·`/bootstrap`·`/onboarding` 과 스킬
`idea-to-plan`·`agentic-coding-workflow`·`workflow-tutor` 가 활성화되고, 의존성인 **Superpowers**도 자동 설치된다.

- 각 명령은 `~/.claude/settings.json`에 영구 기록되어 이후 모든 세션에서 자동 로드된다.
- 식별자: `spec-driven-workflow@agentic-coding-workflow`. 전제: GitLab clone 권한, Claude Code **v2.1.110+**(의존성 자동설치).

> 처음이라면 설치 후 **`/onboarding`** 으로 대화형 학습부터 시작하면 좋다.

### Codex

`codex plugin marketplace add` 는 HTTPS/SSH Git URL을 그대로 받는다(GitHub 불필요):

```bash
codex plugin marketplace add http://gitlab.prd.console.trombone.okestro.cloud/th.oh/agentic-coding-workflow.git
codex plugin add spec-driven-workflow@agentic-coding-workflow
```

`.codex-plugin/plugin.json` 매니페스트가 같은 `skills/`·`commands/`를 가리킨다. (Codex의 TDD 규율은 Superpowers가 아니라
`/bootstrap` 이 깔아 주는 `AGENTS.md` 규칙으로 강제되므로, Codex 플러그인엔 Superpowers 의존성이 없다.)

### 그 외 에이전트 — `npx skills` (Vercel Labs)

[`skills` CLI](https://github.com/vercel-labs/skills)는 저장소의 `SKILL.md`들을 읽어 설치 에이전트(.claude/skills, .agents/skills 등)에 넣는다.
스킬(`idea-to-plan`·`agentic-coding-workflow`·`workflow-tutor`)만 가볍게 쓰고 싶을 때:

```bash
# 저장소를 받아 로컬 경로로 설치 (사내 GitLab은 GitHub 단축경로가 안 되므로 clone 후 로컬 경로 권장)
git clone http://gitlab.prd.console.trombone.okestro.cloud/th.oh/agentic-coding-workflow.git
npx skills add ./agentic-coding-workflow          # 설치할 스킬·에이전트를 대화형 선택 (--list 로 목록, -y 로 비대화형, --global 로 전역)
```

> `npx skills` 는 SKILL.md만 설치한다(커맨드·bootstrap·의존성 제외). 전체 워크플로우는 Claude/Codex 플러그인 설치를 권장.

### 로컬 개발 (플러그인을 직접 편집할 때)

마켓플레이스 없이 소스 디렉터리를 그대로 로드한다:

```bash
claude --plugin-dir ~/spec-driven-workflow
```

세션 중 소스를 고쳤으면 `/reload-plugins`(편집분 반영; 새 커맨드 추가는 재시작 필요).

## 사용

```
/plan 동네 클라이밍장 회원용 볼더링 기록 앱을 만들고 싶어
```

또는 그냥 자연어로 "이런 아이디어가 있는데 기획해줘"라고 하면 `idea-to-plan` 스킬이 트리거된다.
기획이 끝나면 "이제 구현하자"로 `agentic-coding-workflow`(OpenSpec/TDD)로 넘어간다.

## 릴리스 / 업데이트

이 저장소가 곧 마켓플레이스다(`.claude-plugin/marketplace.json`, `source: "./"`). 고친 뒤:

```bash
# 1) plugin.json + marketplace.json 의 version 을 올린다 (예: 0.3.1 → 0.3.2)
# 2) 커밋 & push
git commit -am "vX.Y.Z: ..." && git push
```

> ⚠️ **version bump 필수.** 캐시가 버전별로 고정되어, 버전을 올리지 않으면 팀원에게 갱신이 가지 않는다.

**팀원 업데이트:**

```bash
claude plugin marketplace update agentic-coding-workflow
claude plugin update spec-driven-workflow@agentic-coding-workflow   # → 재시작
```

## 의존성

- **Superpowers (자동 설치)** — TDD 규율(RED→GREEN→REFACTOR)을 강제하는 플러그인. `plugin.json`의
  `dependencies`에 `superpowers@claude-plugins-official`로 선언돼 있어, 이 플러그인을 설치하면 **함께 자동 설치**된다.
  (Claude Code v2.1.110+ 필요. 다른 마켓플레이스라 `marketplace.json`의 `allowCrossMarketplaceDependenciesOn`도 선언됨.)
  자동 설치가 안 되면 수동으로: `/plugin install superpowers@claude-plugins-official`.
- **OpenSpec (별도)** — `agentic-coding-workflow`의 `/opsx:*` 슬래시 커맨드는 OpenSpec이 자체 설치한다
  (`openspec init`/`update`, 또는 번들 `/bootstrap`). 이 플러그인은 방법론·문서·bootstrap만 제공하고 OpenSpec 도구 자체는 번들하지 않는다.

## 크레딧

- **Agentic Coding Workflow (방법론·문서)** — **정원규 팀장님**이 설계·구성·작성.
  OpenSpec(What) + Superpowers TDD(How)로 "무엇을/어떻게"를 분리하고, 진행 상황은 별도 보드 없이 산출물(폴더·`tasks.md`·커밋)에서 읽는 스펙주도 워크플로우다.
  (`skills/agentic-coding-workflow/references/` 의 문서 2종 `Agentic-Coding-Workflow.md`·`Agentic-Workflow-Onboarding.md` 가 원본.)
