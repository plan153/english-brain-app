-- 수정: 복습 0개일 때 5개 채우기 + 완료된 미션 보호
CREATE OR REPLACE FUNCTION generate_daily_mission(p_user_id UUID)
RETURNS JSONB AS $$
DECLARE
    new_ids    INT[];
    review_ids INT[];
    new_limit  INT;
    result     JSONB;
BEGIN
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

    new_limit := 5 - COALESCE(array_length(review_ids, 1), 0);

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

    INSERT INTO daily_missions (user_id, mission_date, sentence_ids)
    VALUES (p_user_id, CURRENT_DATE, result)
    ON CONFLICT (user_id, mission_date) DO UPDATE
        SET sentence_ids = EXCLUDED.sentence_ids
        WHERE daily_missions.completed = FALSE;

    SELECT sentence_ids INTO result
    FROM daily_missions
    WHERE user_id = p_user_id AND mission_date = CURRENT_DATE;

    RETURN result;
END;
$$ LANGUAGE plpgsql;
