# 🧠 English Brain Training App

한국인을 위한 이미지 기반 영어 회화 학습 앱.
핵심 동사를 **방향 이미지**로 형상화 — 번역 없이 바로 말하게.

| HAVE 📦 | GET →📥 | TAKE ✊→ | MAKE ✦ |
|---|---|---|---|
| 내 안에 있음 | 안으로 들어옴 | 잡아서 이동 | 새로 만듦 |

---

## 시작하기

```bash
# 1. DB (Supabase)
psql < db/schema.sql
psql < db/seed.sql

# 2. 앱
cd app && flutter pub get
flutter run --dart-define=SUPABASE_URL=xxx --dart-define=SUPABASE_ANON_KEY=yyy
```

## GitHub Pages (UI 데모)

Settings → Pages → Branch: **main / (root)** → 저장
→ `https://[사용자명].github.io/[저장소명]/`

> Flutter 앱은 `flutter run` 빌드 필요. GitHub 업로드만으로 실행되지 않음.

## 구조

```
├── index.html          # GitHub Pages 랜딩
├── app/                # Flutter 앱
├── db/                 # schema.sql + seed.sql
├── content/            # 예문 관리 (엑셀·CSV)
├── docs/               # 기획문서 + MVP명세 + 녹음대본
│   └── archive/        # 이전 버전 산출물
└── design/             # UI 시안
```

## 스택

Flutter · Supabase(PostgreSQL) · Google Sheets 동기화 · 원어민 녹음(TTS) + STT

## 버전

`v1.4.0` — 변경 이력: [CHANGELOG.md](CHANGELOG.md)
