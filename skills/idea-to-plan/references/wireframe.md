# 와이어프레임 규칙 (4단계)

`planning/{slug}/wireframe.html`로 저장. **브라우저로 바로 열어볼 수 있는 단일 HTML 파일**.

> Manny는 와이어프레임을 직접 만들지 못하고(캔버스가 없어서) "재생성 프롬프트"만 제공했다.
> Claude Code는 캔버스는 없지만 **코드는 만들 수 있으므로**, 실제 HTML/CSS로 Manny를 능가한다.

## 목적은 충실도가 아니라 합의

여기서 만드는 건 *완성된 제품 UI*가 아니라 **구조·배치·동선의 합의**다.
저충실도(low-fidelity, "회색 박스" 스타일)로 **빠르게**. 색·폰트·아이콘에 시간 쓰지 않는다.

- 회색 톤 박스 + 라벨로 영역 표현 (실제 색상/브랜딩 X)
- placeholder 텍스트로 콘텐츠 자리 표시
- 인터랙션은 정적으로 (실제 동작 JS 불필요, 탭 전환 정도만 선택적)

## 무엇을 그리나

- **유저플로우의 주요 화면(노드) 각각**을 하나의 화면 블록으로.
- 각 화면의 영역 배치는 **기능명세서의 기능**과 1:1로 맞춘다.
- 단일 페이지/패널형 제품이면 한 화면 안에 좌측바·상단탭·중앙 멀티패널·우측 인스펙터 식으로 영역을 나눠 그린다.

## 기술

- 의존성 없는 순수 HTML + 인라인 `<style>` (한 파일로 자체 완결).
- 고품질·인터랙티브가 필요하면 **`frontend-design` 스킬**을 함께 호출한다. 단 기본은 저충실도 속도 우선.
- 여러 화면은 한 페이지에 세로로 쌓거나, 간단한 탭으로 전환.

## 골격 예시

```html
<!doctype html>
<html lang="ko"><head><meta charset="utf-8">
<title>{제품명} — 와이어프레임</title>
<style>
  body{font-family:system-ui;margin:0;background:#f4f4f5;color:#27272a}
  .screen{background:#fff;border:1px solid #d4d4d8;border-radius:8px;margin:24px auto;max-width:1100px}
  .screen-title{padding:12px 16px;border-bottom:1px solid #e4e4e7;font-weight:600}
  .box{background:#e4e4e7;border:1px dashed #a1a1aa;border-radius:6px;padding:16px;color:#52525b}
  .row{display:flex;gap:12px;padding:16px}
  .sidebar{width:200px} .main{flex:1} .inspector{width:240px}
</style></head>
<body>
  <section class="screen">
    <div class="screen-title">코크핏 — 단일 페이지 워크스페이스 (유저플로우 n13)</div>
    <div class="row">
      <div class="box sidebar">파일 탐색기 (기능 3.6)</div>
      <div class="box main">터미널 그리드 / 파일 뷰어 / Diff (기능 3.1·3.6·4.3)</div>
      <div class="box inspector">인스펙터: 로그·비용 (기능 4.2·4.4)</div>
    </div>
  </section>
</body></html>
```

각 박스 라벨에 대응하는 **기능명세 번호를 괄호로 표기**해 추적성을 남긴다.

## 검증·게이트

- 브라우저로 열어 깨지지 않는가 (가능하면 실제로 열어 스크린샷으로 확인).
- 유저플로우의 주요 화면이 다 표현됐는가.
- 사용자 확인. 이후 필요시 5단계(OpenSpec 핸드오프).
