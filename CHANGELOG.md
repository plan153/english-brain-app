# 변경 이력 (CHANGELOG)

이 프로젝트의 모든 주요 변경을 초기 버전과 비교하여 기록합니다.
버전 규칙: `주.부.수` (Major.Minor.Patch)

---

## [1.5.0] — QA 버그 수정 (베타 테스터 + QA 검토)

### 버그 수정
- study_screen: 5문장 완료 시 DoneScreen 연결 안 되던 문제 수정
- study_screen: 웹 환경 STT 미지원 → '✅ 맞게 말했어요' 버튼 폴백 추가
- study_screen: 답 보기 5초 잠금 + 힌트 시트 표시 개선
- mission_screen: getTodayMission 실패 시 직접 예문 조회 폴백 추가
- mission_screen: 오류 메시지 사용자에게 표시
- done_screen: verbName·typeName 전달 연결 수정

---

## [1.4.1] — SQL 예약어 버그 수정

### 수정
- `db/schema.sql` — traps 테이블 `right` 컬럼 → `right_ex` (SQL 예약어 충돌)
- `db/seed.sql` — 동일 컬럼명 반영
- `app/lib/models/models.dart` — Trap.fromJson 필드명 업데이트

---

## [1.4.0] — Supabase 연동 완성 + 전체 화면 구현

### 추가
- `config.dart` — 실제 Supabase URL·key 적용
- `stage0_screen.dart` — 0단계 영어 뼈대 학습 화면
- `done_screen.dart` — 미션 완료 + 확장 학습 4가지
- `review_screen.dart` — 복습 현황 + 오늘 복습 리스트
- `scripts/generate_audio.py` — ElevenLabs AI 음성 자동 생성
- `mission_screen.dart` — 0단계·복습·통계·Supabase 완전 연동

---

## [1.3.0] — 중복 제거 + 간결화

### 제거
- `docs/기획문서_v2.html` — PDF 중복
- `docs/archive/기획문서_v2_(v0.2.0).pdf` — docs/에 최신본 있음
- `docs/archive/README.md` — CHANGELOG와 중복

### 간결화
| 파일 | 전 | 후 |
|---|---|---|
| README.md | 134줄 | 49줄 |
| config.dart | 22줄 | 10줄 |
| models.dart | 84줄 | 49줄 |
| content_service.dart | 84줄 | 55줄 |
| main.dart | 35줄 | 27줄 |
| schema.sql | 212줄 | 201줄 |

---

## [1.2.1] — 이전 버전 산출물 복원

### 수정 (중요)
- 누락 발견: 초기 기획문서 v1, 최초 UI 시안(JSX)이 프로젝트에 없었음
- `docs/archive/` 신설 — 버전별 산출물 보존 (비교 가능)
  - `기획문서_v1_(v0.1.0).pdf` (모든 비교의 기준점)
  - `기획문서_v2_(v0.2.0).pdf`
- `design/`에 최초 UI 시안 React 원본 복원 `app_ui_prototype_react_(v0.1.0).jsx`
- `docs/archive/README.md` — 버전 흐름 한눈에 보기 추가

---

## [1.2.0] — GitHub Pages 지원 + 버전 체계 (현재)

### 추가
- 루트 `index.html` — GitHub Pages용 프로젝트 랜딩 + UI 데모 진입
- `VERSION` 파일 + `CHANGELOG.md` (버전 추적 체계)
- README에 GitHub Pages 설정법 추가

### 수정
- 초기에 잘못 생성된 빈 폴더(`{db,content,docs,design}`) 제거
- 압축파일명에 버전 넘버링 적용 (`english-brain-app-v1.2.0.zip`)

### 명확화
- "GitHub 업로드 = 자동 실행" 오해 해소: Flutter 앱은 빌드 필요,
  UI 데모만 GitHub Pages로 바로 공개 가능

---

## [1.1.0] — Flutter 앱 코드 + 원어민 녹음 대본

### 추가
- `app/` Flutter 앱 뼈대 (main, config, models, services, screens)
- `content_service.dart` — DB 접근 단일 창구 (콘텐츠/코드 분리)
- `study_screen.dart` — 학습 핵심 플로우 (능동 인출 5초 잠금 등 UX 원칙 반영)
- `docs/원어민_녹음대본.md` — 275문장 × 2속도 녹음 대본

---

## [1.0.0] — 개발 산출물 패키지 (GitHub 프로젝트화)

### 추가
- `db/schema.sql` — DB 스키마 (콘텐츠/학습 분리, 자동화 함수 2종)
- `db/seed.sql` — 기획문서 v2 콘텐츠 180개 예문 SQL
- `content/콘텐츠_관리시트.xlsx` — 비개발자용 콘텐츠 관리 (4시트)
- `content/*.csv` — sentences / traps / stage0
- `docs/MVP_명세서.md` — 개발자 전달용 명세서
- `README.md`, `.gitignore`

### 설계 원칙 확립
- 콘텐츠와 코드 완전 분리 → 비개발자가 시트로 콘텐츠 관리
- 나선형 복습(간격 반복) 알고리즘을 DB 함수로 구현

---

## [0.2.0] — 기획 문서 v2 (전문가 검토 반영)

### 추가
- "0단계: 영어 문장의 뼈대" 신설 (주어+동사·be·관사·"있다"3종)
- 동사별 "한국인 함정 카드" (❌→⭕ + 이유)
- 5인 전문가 검토 (교육공학·언어습득·원어민·영어뇌교사·초보자)

### 변경
- 원어민 검수로 어색한 예문 교체 (have had→I've had it 등, 축약형 기본)
- 모든 실수에 "왜 그런지" 이유 명시

---

## [0.1.0] — 기획 문서 v1 (초기 버전)

### 추가
- 핵심 동사 형상화: HAVE / GET 5타입, TAKE / MAKE 4타입
- BE / GET / HAVE 비교 (한국인 최대 난관)
- 관계 동사 8그룹 (GO↔COME, SAY/TELL/SPEAK/TALK 등)
- 100일 커리큘럼 구조
- 동사별 타입별 실생활 예문 180선
- 앱 UI 시안 (Grok 디자인 참고)

### 기준점
- 이 버전이 모든 비교의 **기준(baseline)**입니다.

---

## 버전 넘버링 규칙

| 자리 | 의미 | 올리는 경우 |
|---|---|---|
| **주(Major)** | 큰 방향 전환 | 앱 정식 출시, 구조 전면 개편 |
| **부(Minor)** | 기능/산출물 추가 | 새 문서·코드·기능 추가 |
| **수(Patch)** | 작은 수정 | 버그·오타·예문 교정 |

다음 작업 시 이 CHANGELOG 상단에 새 버전 블록을 추가하고
`VERSION` 파일과 압축파일명을 함께 갱신합니다.
