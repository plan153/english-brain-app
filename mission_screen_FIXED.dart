import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../services/content_service.dart';
import 'study_screen.dart';
import 'stage0_screen.dart';
import 'review_screen.dart';

class MissionScreen extends StatefulWidget {
  const MissionScreen({super.key});
  @override
  State<MissionScreen> createState() => _MissionScreenState();
}

class _MissionScreenState extends State<MissionScreen> {
  int _tab = 0;
  bool _loading = false;
  int _streak = 0, _totalDone = 0, _acc = 0;

  String get _uid =>
    Supabase.instance.client.auth.currentUser?.id ??
    '00000000-0000-0000-0000-000000000001';

  @override
  void initState() { super.initState(); _loadStats(); }

  // ✅ 수정됨: streak 포함하여 통계 로드
  Future<void> _loadStats() async {
    try {
      // 1단계: 사용자 프로필에서 streak 가져오기
      final userProfileList = await Supabase.instance.client
        .from('users')
        .select('streak_days')
        .eq('id', _uid);
      
      int streakValue = 0;
      if (userProfileList.isNotEmpty) {
        streakValue = userProfileList[0]['streak_days'] ?? 0;
      }
      
      // 2단계: 학습 진행도 가져오기
      final progress = await Supabase.instance.client
        .from('user_progress')
        .select('correct_count, wrong_count')
        .eq('user_id', _uid);
      
      final totalC = progress.fold(0, (s, r) => s + (r['correct_count'] as int? ?? 0));
      final totalW = progress.fold(0, (s, r) => s + (r['wrong_count'] as int? ?? 0));
      final totalA = totalC + totalW;
      
      setState(() {
        _streak = streakValue;  // ✅ streak 설정
        _totalDone = totalA;
        _acc = totalA > 0 ? (totalC / totalA * 100).round() : 0;
      });
    } catch (e) {
      debugPrint('Stats loading error: $e');
    }
  }

  Future<void> _startMission() async {
    setState(() => _loading = true);
    try {
      final sentences = await ContentService.getTodayMission(_uid);
      if (!mounted) return;
      if (sentences.isEmpty) {
        // 미션 함수 실패 시 직접 예문 가져오기 (폴백)
        final fallback = await Supabase.instance.client
          .from('sentences')
          .select()
          .eq('is_active', true)
          .order('level')
          .limit(5);
        final sents = (fallback as List).map((e) => Sentence.fromJson(Map<String, dynamic>.from(e))).toList();
        if (!mounted) return;
        if (sents.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('예문을 불러오지 못했어요. Supabase seed.sql을 확인해주세요.')));
          return;
        }
        await Navigator.push(context, MaterialPageRoute(
          builder: (_) => StudyScreen(sentences: sents, userId: _uid)));
      } else {
        await Navigator.push(context, MaterialPageRoute(
          builder: (_) => StudyScreen(sentences: sentences, userId: _uid)));
      }
      _loadStats();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: [_home(), const ReviewScreen()][_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        backgroundColor: Colors.white,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home), label: '홈'),
          NavigationDestination(icon: Icon(Icons.replay_outlined),
            selectedIcon: Icon(Icons.replay), label: '복습'),
        ],
      ),
    );
  }

  Widget _home() => SafeArea(child: SingleChildScrollView(
    padding: const EdgeInsets.all(20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      // 헤더
      Row(children: [
        CircleAvatar(backgroundColor: const Color(0xFF1A1A1A),
          child: const Text('🧠', style: TextStyle(fontSize: 18))),
        const SizedBox(width: 10),
        const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('English Brain', style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w700)),
          Text('영어뇌 훈련 앱', style: TextStyle(
            fontSize: 11, color: Colors.black38)),
        ]),
      ]),
      const SizedBox(height: 24),

      // 미션 카드
      Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(20)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('오늘의 미션',
            style: TextStyle(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 4),
          const Text('5문장 완성하기', style: TextStyle(
            color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('듣고 → 연상하고 → 바로 말하기',
            style: TextStyle(color: Colors.white38, fontSize: 12)),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _loading ? null : _startMission,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1A1A1A),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))),
            child: _loading
              ? const SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2,
                    color: Color(0xFF1A1A1A)))
              : const Text('시작하기 →',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
        ]),
      ),
      const SizedBox(height: 12),

      // 0단계 배너
      GestureDetector(
        onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const Stage0Screen())),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFAECE7),
            borderRadius: BorderRadius.circular(14)),
          child: const Row(children: [
            Text('🦴', style: TextStyle(fontSize: 20)),
            SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('0단계 — 영어 문장의 뼈대', style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700,
                  color: Color(0xFFD85A30))),
                Text('주어·be·관사·"있다" 3종 먼저 배우기', style: TextStyle(
                  fontSize: 11, color: Color(0xFF993C1D))),
              ])),
            Icon(Icons.chevron_right, color: Color(0xFFD85A30)),
          ]),
        ),
      ),
      const SizedBox(height: 12),

      // 확장 학습
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFF0F0F0)),
          borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('✦ 추가 확장 학습',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: const [
            _Chip('⏳ 시제 변형'), _Chip('🔄 긍정/부정'),
            _Chip('❓ 질문/맞장구'), _Chip('📍 장소·시간'),
          ]),
        ]),
      ),
      const SizedBox(height: 16),

      // 통계
      Row(children: [
        _Stat('${_streak}일', '연속'),
        const SizedBox(width: 8),
        _Stat('$_totalDone회', '완료'),
        const SizedBox(width: 8),
        _Stat('$_acc%', '정확도'),
      ]),
    ]),
  ));
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);
  @override
  Widget build(BuildContext c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(color: const Color(0xFFFAFAFA),
      borderRadius: BorderRadius.circular(10)),
    child: Text(label, style: const TextStyle(fontSize: 12)));
}

class _Stat extends StatelessWidget {
  final String v, l;
  const _Stat(this.v, this.l);
  @override
  Widget build(BuildContext c) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(color: const Color(0xFFFAFAFA),
      borderRadius: BorderRadius.circular(12)),
    child: Column(children: [
      Text(v, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      Text(l, style: const TextStyle(fontSize: 10, color: Colors.black38)),
    ])));
}
