-- English Brain Training App — Database Schema
-- PostgreSQL / Supabase
-- 핵심 원칙: 콘텐츠 테이블과 학습 테이블을 완전 분리
--           → 콘텐츠를 바꿔도 학습 기록은 안전하게 보존

-- 핵심 동사 (HAVE, GET, TAKE, MAKE ...)
CREATE TABLE verbs (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(20)  NOT NULL UNIQUE,   
    core_image  TEXT         NOT NULL,          -- 핵심 그림 한 줄 설명
    tagline     VARCHAR(50),                    -- 📦 정지·보유 상태
    color       VARCHAR(7),                     -- #0C447C
    order_no    INT          NOT NULL DEFAULT 0,
    is_active   BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- 동사별 타입 (소유, 경험, 먹다 ...)
CREATE TABLE verb_types (
    id          SERIAL PRIMARY KEY,
    verb_id     INT          NOT NULL REFERENCES verbs(id) ON DELETE CASCADE,
    name        VARCHAR(60)  NOT NULL,          -- 소유 — 가지고 있다
    concept     TEXT         NOT NULL,          -- 머릿속 그림 설명
    image_url   TEXT,                           -- 형상화 이미지 경로
    order_no    INT          NOT NULL DEFAULT 0,
    is_active   BOOLEAN      NOT NULL DEFAULT TRUE
);

-- 예문 (★ 콘텐츠 관리의 핵심 테이블)
CREATE TABLE sentences (
    id          SERIAL PRIMARY KEY,
    type_id     INT          NOT NULL REFERENCES verb_types(id) ON DELETE CASCADE,
    ko          TEXT         NOT NULL,          -- 나 차 있어
    en          TEXT         NOT NULL,          -- I have a car.
    chunk_hint  TEXT,                           -- [가지고있다 → 차 한 대를]
    level       SMALLINT     NOT NULL DEFAULT 1 CHECK (level BETWEEN 1 AND 4),
    frequency   VARCHAR(2)   NOT NULL DEFAULT '중' CHECK (frequency IN ('상','중','하')),
    tense       VARCHAR(20),                    -- 현재 / 과거 / 미래 / 현재완료
    audio_url   TEXT,                           -- 원어민 음성 파일
    audio_slow_url TEXT,                        -- 느린 발음 버전
    is_active   BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- 한국인 함정 카드 (실수 예방)
CREATE TABLE traps (
    id          SERIAL PRIMARY KEY,
    verb_id     INT          REFERENCES verbs(id) ON DELETE CASCADE,
    wrong_ex    TEXT         NOT NULL,          -- I have car
    right_ex    TEXT         NOT NULL,          -- I have a car
    why         TEXT         NOT NULL,          -- 차 한 대 → a 필수
    is_active   BOOLEAN      NOT NULL DEFAULT TRUE
);

-- 확장 세트 (시제·긍정부정·장소시간 변형)
CREATE TABLE expansions (
    id          SERIAL PRIMARY KEY,
    sentence_id INT          NOT NULL REFERENCES sentences(id) ON DELETE CASCADE,
    kind        VARCHAR(20)  NOT NULL,          -- 시제 / 부정 / 질문 / 장소
    ko          TEXT         NOT NULL,
    en          TEXT         NOT NULL,
    order_no    INT          NOT NULL DEFAULT 0
);

-- 0단계: 영어 문장의 뼈대
CREATE TABLE stage0_items (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(60)  NOT NULL,          -- 뼈대 1 — 주어+동사
    concept     TEXT         NOT NULL,
    examples    JSONB        NOT NULL,          -- [{wrong,right,why}, ...]
    order_no    INT          NOT NULL DEFAULT 0
);

CREATE TABLE users (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name         VARCHAR(50),
    email        VARCHAR(120) UNIQUE,
    level        VARCHAR(10)  NOT NULL DEFAULT '초급',
    streak_days  INT          NOT NULL DEFAULT 0,
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT now()
);

-- 문장별 학습 기록 (나선형 복습의 핵심)
CREATE TABLE user_progress (
    id            BIGSERIAL PRIMARY KEY,
    user_id       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    sentence_id   INT  NOT NULL REFERENCES sentences(id) ON DELETE CASCADE,
    correct_count INT  NOT NULL DEFAULT 0,
    wrong_count   INT  NOT NULL DEFAULT 0,
    last_seen     TIMESTAMPTZ,
    next_review   DATE,                          -- 다음 복습 예정일 (간격 반복)
    mastered      BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE (user_id, sentence_id)
);

-- 하루 5문장 미션
CREATE TABLE daily_missions (
    id            BIGSERIAL PRIMARY KEY,
    user_id       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    mission_date  DATE NOT NULL,
    sentence_ids  JSONB NOT NULL,                -- [12, 45, 7, 89, 23] (새3+복습2)
    completed     BOOLEAN NOT NULL DEFAULT FALSE,
    completed_at  TIMESTAMPTZ,
    UNIQUE (user_id, mission_date)
);

-- 콘텐츠 변경 이력 (되돌리기 가능)
CREATE TABLE content_version (
    id          SERIAL PRIMARY KEY,
    version     VARCHAR(20) NOT NULL,            -- v2.1
    changed_by  VARCHAR(50),                     -- 준석
    changed_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    note        TEXT,
    snapshot    JSONB                            -- 변경 직전 콘텐츠 백업
);

CREATE INDEX idx_types_verb       ON verb_types(verb_id);
CREATE INDEX idx_sentences_type   ON sentences(type_id);
CREATE INDEX idx_sentences_active ON sentences(is_active) WHERE is_active = TRUE;
CREATE INDEX idx_progress_user    ON user_progress(user_id);
CREATE INDEX idx_progress_review  ON user_progress(user_id, next_review);
CREATE INDEX idx_missions_user    ON daily_missions(user_id, mission_date);

-- 규칙: 복습 2개(틀린 것 우선) + 새 문장으로 5개 채우기 / 완료된 미션은 덮어쓰지 않음
CREATE OR REPLACE FUNCTION generate_daily_mission(p_user_id UUID)
RETURNS JSONB AS $$
DECLARE
    new_ids    INT[];
    review_ids INT[];
    new_limit  INT;
    result     JSONB;
BEGIN
    -- 복습 문장 최대 2개 (틀린 횟수 많은 것 / 복습일 지난 것 우선)
    SELECT array_agg(up.sentence_id) INTO review_ids
    FROM (
        SELECT up.sentence_id
        FROM user_progress up
        WHERE up.user_id = p_user_id
          AND up.mastered = FALSE
          AND (up.next_review IS NULL OR up.next_review <= CURRENT_DATE)
        ORDER BY up.wrong_count DESC, up.last_seen ASC NULLS FIRST
        LIMIT 2
    ) up;

    -- 복습 문장 수만큼 빼서 총 5개 채우기 (복습 0개면 새 문장 5개)
    new_limit := 5 - COALESCE(array_length(review_ids, 1), 0);

    -- 새 문장 (난이도 낮은 것 → 높은 것, 아직 안 본 것만)
    SELECT array_agg(s.id) INTO new_ids
    FROM (
        SELECT s.id
        FROM sentences s
        WHERE s.is_active = TRUE
          AND s.id NOT IN (
              SELECT sentence_id FROM user_progress WHERE user_id = p_user_id
          )
        ORDER BY s.level ASC, s.frequency DESC, random()
        LIMIT new_limit
    ) s;

    result := to_jsonb(COALESCE(new_ids, '{}') || COALESCE(review_ids, '{}'));

    -- 미완료 미션만 업데이트 (완료된 미션은 보호)
    INSERT INTO daily_missions (user_id, mission_date, sentence_ids)
    VALUES (p_user_id, CURRENT_DATE, result)
    ON CONFLICT (user_id, mission_date) DO UPDATE
        SET sentence_ids = EXCLUDED.sentence_ids
        WHERE daily_missions.completed = FALSE;

    -- 완료된 경우 기존 sentence_ids 반환
    SELECT sentence_ids INTO result
    FROM daily_missions
    WHERE user_id = p_user_id AND mission_date = CURRENT_DATE;

    RETURN result;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION record_answer(
    p_user_id UUID, p_sentence_id INT, p_correct BOOLEAN
) RETURNS VOID AS $$
DECLARE
    v_correct INT;
    v_interval INT;
BEGIN
    INSERT INTO user_progress (user_id, sentence_id, correct_count, wrong_count, last_seen)
    VALUES (p_user_id, p_sentence_id,
            CASE WHEN p_correct THEN 1 ELSE 0 END,
            CASE WHEN p_correct THEN 0 ELSE 1 END,
            now())
    ON CONFLICT (user_id, sentence_id) DO UPDATE SET
        correct_count = user_progress.correct_count + CASE WHEN p_correct THEN 1 ELSE 0 END,
        wrong_count   = user_progress.wrong_count   + CASE WHEN p_correct THEN 0 ELSE 1 END,
        last_seen     = now();

    SELECT correct_count INTO v_correct
    FROM user_progress WHERE user_id = p_user_id AND sentence_id = p_sentence_id;

    -- 간격 반복: 맞을수록 복습 간격이 늘어남 (1,2,4,7,15일)
    v_interval := CASE
        WHEN NOT p_correct THEN 1
        WHEN v_correct >= 5 THEN 15
        WHEN v_correct = 4 THEN 7
        WHEN v_correct = 3 THEN 4
        WHEN v_correct = 2 THEN 2
        ELSE 1 END;

    UPDATE user_progress
    SET next_review = CURRENT_DATE + v_interval,
        mastered = (v_correct >= 5)
    WHERE user_id = p_user_id AND sentence_id = p_sentence_id;
END;
$$ LANGUAGE plpgsql;
