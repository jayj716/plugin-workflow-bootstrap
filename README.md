# spec-driven-workflow

아이디어 한 줄을 **제품 기획 → 스펙주도 구현**까지 끌고 가는 Claude Code 플러그인.
manyfast의 "Manny" 기획 흐름과 OpenSpec/Superpowers 워크플로우를 하나로 묶었다.

```
[아이디어] ─▶ /plan (idea-to-plan)         ─▶ agentic-coding-workflow ─▶ 구현
            PRD·기능명세·유저플로우·와이어프레임   OpenSpec(What) + TDD(How)
```

> **30초 요약** — Claude Code 사용자는 아래 두 줄이면 끝.
> ```bash
> claude plugin marketplace add jayj716/plugin-workflow-bootstrap
> claude plugin install spec-driven-workflow@agentic-coding-workflow   # → 재시작
> ```
> 설치 후 처음이면 **`/onboarding`**, 기획 시작은 **`/plan`**. 자세한 건 [설치](#설치)·[사용](#사용).

---

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
spec-driven-workflow/                       # = 저장소 = 마켓플레이스
├── .claude-plugin/marketplace.json         # Claude 마켓플레이스 카탈로그
├── .agents/plugins/marketplace.json        # Codex 마켓플레이스 카탈로그
├── .cursor-plugin/marketplace.json         # Cursor 마켓플레이스 카탈로그
├── README.md
└── plugins/spec-driven-workflow/           # 플러그인 본체 (Claude·Codex·Cursor 공용 단일 소스)
    ├── .claude-plugin/plugin.json
    ├── .codex-plugin/plugin.json
    ├── .cursor-plugin/plugin.json
    ├── skills/
    │   ├── idea-to-plan/            # 기획 파이프라인 (SKILL.md + references 6종)
    │   ├── agentic-coding-workflow/ # 방법론 (SKILL.md + references 2종)
    │   └── workflow-tutor/          # 대화형 온보딩 튜터
    ├── commands/{plan.md, bootstrap.md, onboarding.md}
    └── scripts/bootstrap.sh
```

> 세 마켓플레이스 카탈로그(Claude · Codex · Cursor)가 모두 `plugins/spec-driven-workflow`
> 한 곳을 가리켜, 세 플랫폼이 **같은 소스**를 공유한다(중복 없음).

---

## 설치

한 저장소를 **Claude Code · Codex · Cursor 플러그인**, 또는 가볍게 **`npx skills`** 로 설치할 수 있다.
공개 GitHub 저장소라 `owner/repo` 단축경로가 그대로 통한다.

> 저장소: **`jayj716/plugin-workflow-bootstrap`** — https://github.com/jayj716/plugin-workflow-bootstrap

### Claude Code (권장 · 팀원용)

```bash
claude plugin marketplace add jayj716/plugin-workflow-bootstrap
claude plugin install spec-driven-workflow@agentic-coding-workflow
```

그다음 **Claude 재시작**. 커맨드 `/plan`·`/bootstrap`·`/onboarding` 과 스킬
`idea-to-plan`·`agentic-coding-workflow`·`workflow-tutor` 가 활성화되고, 의존성인 **Superpowers**도 자동 설치된다.

- 각 명령은 `~/.claude/settings.json`에 영구 기록 → 이후 모든 세션에서 자동 로드.
- 식별자는 `spec-driven-workflow@agentic-coding-workflow` (마켓플레이스 이름은 저장소명과 별개).
- 전제: Claude Code **v2.1.110+** (의존성 자동설치).
- 처음이라면 설치 후 **`/onboarding`** 으로 대화형 학습부터.

### Codex

`codex plugin marketplace add` 는 `owner/repo`·HTTPS·SSH 를 모두 받는다.

```bash
codex plugin marketplace add jayj716/plugin-workflow-bootstrap
codex plugin add spec-driven-workflow@agentic-coding-workflow
```

`.agents/plugins/marketplace.json` 카탈로그를 읽어 `plugins/spec-driven-workflow`(같은 소스)를 설치한다.
Codex의 TDD 규율은 Superpowers가 아니라 `/bootstrap` 이 깔아 주는 `AGENTS.md` 규칙으로 강제되므로,
Codex 플러그인엔 Superpowers 의존성이 없다.

### Cursor (2.5+)

Cursor 2.5부터 플러그인 마켓플레이스를 지원한다(`.cursor-plugin/marketplace.json` + `plugins/spec-driven-workflow/.cursor-plugin/plugin.json`, 같은 `skills/`·`commands/` 재사용). 설치는 **에디터 GUI**로 한다:

- 에디터에서 `/add-plugin` 실행, 또는 `cursor.com/marketplace`에서 추가(공개 저장소라 git 소스로 추가 가능).

> ⚠️ Cursor는 CLI 설치 명령이 없어(GUI 앱) 매니페스트는 **공식 스키마대로 구성**했으나 로컬 설치 검증은 못 했다 — Cursor 2.5+ 에디터에서 확인 필요. 안 되면 아래 **`npx skills`** 로 스킬만 바로 설치(`~/.cursor/skills`).

### 그 외 에이전트 — `npx skills` (Vercel Labs)

[`skills` CLI](https://github.com/vercel-labs/skills)는 저장소의 `SKILL.md`들을 읽어 설치 에이전트(.claude/skills, .agents/skills, ~/.cursor/skills 등)에 넣는다. 스킬 3종만 가볍게 쓸 때:

```bash
npx skills add jayj716/plugin-workflow-bootstrap   # 대화형 선택 (--list 목록, -y 비대화형, --global 전역)
```

> `npx skills` 는 SKILL.md만 설치한다(커맨드·bootstrap·의존성 제외). 전체 워크플로우는 Claude/Codex 플러그인 설치를 권장.

### 로컬 개발 (플러그인을 직접 편집할 때)

마켓플레이스 없이 소스 디렉터리를 그대로 로드한다:

```bash
claude --plugin-dir ~/spec-driven-workflow/plugins/spec-driven-workflow
```

세션 중 소스를 고쳤으면 `/reload-plugins`(편집분 반영; 새 커맨드 추가는 재시작 필요).

---

## 사용

```
/plan 동네 클라이밍장 회원용 볼더링 기록 앱을 만들고 싶어
```

또는 그냥 "이런 아이디어가 있는데 기획해줘"라고 하면 `idea-to-plan` 스킬이 트리거된다.
기획이 끝나면 "이제 구현하자"로 `agentic-coding-workflow`(OpenSpec/TDD)로 넘어간다.

---

## 이미 부트스트랩된 레포를 클론했을 때

> 핵심: **레포에 따라오는 것**과 **머신에 한 번 깔아야 하는 것**은 다르다.

| | 무엇 | 클론하면? |
|---|---|---|
| **레포에 커밋됨** | `openspec/` 명세, 루트 `project.md`, `AGENTS.md`·`.cursor/rules` | ✅ 같이 따라옴 |
| **머신에 1회 설치** | 런타임 CLI, OpenSpec CLI(전역 설치 시), **Superpowers**, 플러그인 본체 | ❌ 따로 설치 |

그래서 팀원이 **이미 부트스트랩된 프로젝트**를 클론하면 명세·규약은 다 있지만 도구가 비어 있을 수 있다.
순서대로 두 단계면 메워진다:

```bash
# 1) 플러그인 설치 (한 번) → Superpowers·/bootstrap·스킬이 함께 따라온다
claude plugin marketplace add jayj716/plugin-workflow-bootstrap
claude plugin install spec-driven-workflow@agentic-coding-workflow   # → 재시작

# 2) 클론한 프로젝트에서 /bootstrap 실행 → update 모드로 빠진 것만 채운다
#    (openspec/ 가 있으면 자동으로 update 모드: OpenSpec CLI·런타임 점검·설치, 검증)
/bootstrap
```

- **Superpowers는 1번에 딸려 온다** — 플러그인의 의존성이라 플러그인을 깔면 자동 설치된다. 자동 설치가 안 되면 수동으로: `/plugin install superpowers@claude-plugins-official`.
- **OpenSpec을 project 스코프로 깐 레포**라면(= `package.json`의 devDependency) `npm install` 이 CLI를 복원한다. `/bootstrap` 도 같은 일을 한다.
- bootstrap은 **멱등(idempotent)** — 여러 번 돌려도 안전하고, 이미 있는 건 건드리지 않는다.

---

## 릴리스 / 업데이트

이 저장소가 곧 마켓플레이스다. 세 카탈로그가 `./plugins/spec-driven-workflow`를 가리킨다. 고친 뒤:

```bash
# 1) 버전을 올린다 — 네 곳을 같은 값으로:
#    plugins/spec-driven-workflow/.claude-plugin/plugin.json
#    plugins/spec-driven-workflow/.codex-plugin/plugin.json
#    plugins/spec-driven-workflow/.cursor-plugin/plugin.json
#    .claude-plugin/marketplace.json (plugins[].version)
# 2) 커밋 & push
git commit -am "vX.Y.Z: ..." && git push
```

> ⚠️ **version bump 필수.** 캐시가 버전별로 고정되어, 버전을 올리지 않으면 팀원에게 갱신이 가지 않는다.
> (Codex·Cursor 카탈로그엔 버전 필드가 없어 위 네 곳만 올리면 된다.)

**팀원 업데이트:**

```bash
claude plugin marketplace update agentic-coding-workflow
claude plugin update spec-driven-workflow@agentic-coding-workflow   # → 재시작
```

---

## 의존성

- **Superpowers (자동 설치)** — TDD 규율(RED→GREEN→REFACTOR)을 강제하는 플러그인.
  `plugin.json`의 `dependencies`에 `superpowers@claude-plugins-official`로 선언돼 있어, 이 플러그인을 설치하면 **함께 자동 설치**된다.
  Claude Code v2.1.110+ 필요. 다른 마켓플레이스라 `marketplace.json`의 `allowCrossMarketplaceDependenciesOn`도 선언됨.
  자동 설치가 안 되면 수동으로: `/plugin install superpowers@claude-plugins-official`.
- **OpenSpec (별도)** — `agentic-coding-workflow`의 `/opsx:*` 슬래시 커맨드는 OpenSpec이 자체 설치한다
  (`openspec init`/`update`, 또는 번들 `/bootstrap`). 이 플러그인은 방법론·문서·bootstrap만 제공하고 OpenSpec 도구 자체는 번들하지 않는다.

---

## 크레딧

- **Agentic Coding Workflow (방법론·문서)** — **정원규 팀장님**이 설계·구성·작성.
  OpenSpec(What) + Superpowers TDD(How)로 "무엇을/어떻게"를 분리하고, 진행 상황은 별도 보드 없이 산출물(폴더·`tasks.md`·커밋)에서 읽는 스펙주도 워크플로우다.
  - **원본(upstream):** [`jayj716/scm-agentic-workflow`](https://github.com/jayj716/scm-agentic-workflow) 의 [`docs/`](https://github.com/jayj716/scm-agentic-workflow/tree/main/docs) — `Agentic-Coding-Workflow.md` · `Agentic-Workflow-Onboarding.md` (비공개 저장소, 접근 권한 필요).
  - 이 플러그인은 그 원본 문서의 **사본**을 `plugins/spec-driven-workflow/skills/agentic-coding-workflow/references/` 에 번들해, 설치 시 함께 따라오도록 한다. 방법론의 정본(SOT)은 upstream이며, 변경은 거기서 시작해 이 사본으로 반영한다.
