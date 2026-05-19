import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class ContentService {
  static final _db = Supabase.instance.client;

  static Future<List<Verb>> getVerbs() async =>
    (await _db.from('verbs').select().eq('is_active', true).order('order_no') as List)
      .map((e) => Verb.fromJson(e)).toList();

  static Future<List<VerbType>> getTypes(int verbId) async =>
    (await _db.from('verb_types').select()
      .eq('verb_id', verbId).eq('is_active', true).order('order_no') as List)
      .map((e) => VerbType.fromJson(e)).toList();

  static Future<List<Sentence>> getSentences(int typeId) async =>
    (await _db.from('sentences').select()
      .eq('type_id', typeId).eq('is_active', true).order('level') as List)
      .map((e) => Sentence.fromJson(e)).toList();

  static Future<List<Trap>> getTraps(int verbId) async =>
    (await _db.from('traps').select()
      .eq('verb_id', verbId).eq('is_active', true) as List)
      .map((e) => Trap.fromJson(e)).toList();

  static Future<List<Stage0Item>> getStage0() async =>
    (await _db.from('stage0_items').select().order('order_no') as List)
      .map((e) => Stage0Item.fromJson(e)).toList();

  // 오늘의 미션 5문장 (새 3 + 복습 2) — 서버 함수가 자동 선정
  static Future<List<Sentence>> getTodayMission(String userId) async {
    final raw = await _db.rpc('generate_daily_mission',
        params: {'p_user_id': userId});
    final ids = (raw as List).map((e) => (e as num).toInt()).toList();
    if (ids.isEmpty) return [];
    return (await _db.from('sentences').select().inFilter('id', ids) as List)
      .map((e) => Sentence.fromJson(e)).toList();
  }

  // 결과 기록 → 서버가 간격 반복 복습일 자동 계산
  static Future<void> recordAnswer(String userId, int sentenceId, bool correct) =>
    _db.rpc('record_answer', params: {
      'p_user_id': userId, 'p_sentence_id': sentenceId, 'p_correct': correct});
}

// 채점: 핵심 단어 70% 이상 일치 시 정답 (초보자 좌절 방지)
class AnswerChecker {
  static String _norm(String s) => s
    .toLowerCase().replaceAll(RegExp(r"[.,!?'']"), '').replaceAll(RegExp(r'\s+'), ' ').trim();

  static bool isCorrect(String spoken, String answer) {
    final a = _norm(spoken).split(' ').toSet();
    final b = _norm(answer).split(' ');
    return b.isNotEmpty && b.where(a.contains).length / b.length >= 0.7;
  }
}
