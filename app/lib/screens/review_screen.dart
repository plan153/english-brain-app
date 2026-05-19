// 복습 현황 화면 — 학습 기록 + 오늘 복습 예정

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});
  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _db = Supabase.instance.client;
  List<Map<String, dynamic>> _due = [];
  Map<String, int> _stats = {};
  bool _loading = true;

  String get _uid =>
    _db.auth.currentUser?.id ?? '00000000-0000-0000-0000-000000000001';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      // 오늘 복습 예정 문장
      final due = await _db.from('user_progress')
        .select('sentence_id, wrong_count, next_review, sentences(ko, en)')
        .eq('user_id', _uid)
        .eq('mastered', false)
        .lte('next_review', DateTime.now().toIso8601String().substring(0, 10))
        .order('wrong_count', ascending: false)
        .limit(20);

      // 통계
      final all = await _db.from('user_progress')
        .select('mastered, correct_count, wrong_count')
        .eq('user_id', _uid);

      final total = all.length;
      final mastered = all.where((r) => r['mastered'] == true).length;
      final totalCorrect = all.fold(0, (s, r) => s + (r['correct_count'] as int? ?? 0));
      final totalWrong = all.fold(0, (s, r) => s + (r['wrong_count'] as int? ?? 0));

      setState(() {
        _due = List<Map<String, dynamic>>.from(due);
        _stats = {
          'total': total, 'mastered': mastered,
          'correct': totalCorrect, 'wrong': totalWrong,
        };
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('복습 현황',
          style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white, elevation: 0),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 통계 카드
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(18)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _S('${_stats['total'] ?? 0}', '학습한 문장'),
                      _S('${_stats['mastered'] ?? 0}', '완전 습득'),
                      _S('${_due.length}', '오늘 복습'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 복습 리스트
                Text('오늘 복습할 문장 (${_due.length}개)',
                  style: const TextStyle(fontSize: 14,
                    fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),

                if (_due.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F8F8),
                      borderRadius: BorderRadius.circular(14)),
                    child: const Column(children: [
                      Text('🎉', style: TextStyle(fontSize: 40)),
                      SizedBox(height: 8),
                      Text('오늘 복습할 것이 없어요!\n새 문장 학습을 해보세요.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black45, height: 1.6)),
                    ]),
                  )
                else
                  ...(_due.map((r) {
                    final sent = r['sentences'] as Map<String, dynamic>? ?? {};
                    final wrong = r['wrong_count'] as int? ?? 0;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: wrong >= 3
                            ? const Color(0xFFFAECE7)
                            : const Color(0xFFF0F0F0)),
                        borderRadius: BorderRadius.circular(12)),
                      child: Row(children: [
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(sent['ko'] ?? '',
                              style: const TextStyle(fontSize: 12,
                                color: Colors.black45)),
                            const SizedBox(height: 4),
                            Text(sent['en'] ?? '',
                              style: const TextStyle(fontSize: 14,
                                fontWeight: FontWeight.w600)),
                          ],
                        )),
                        if (wrong > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: wrong >= 3
                                ? const Color(0xFFFAECE7)
                                : const Color(0xFFF0F0F0),
                              borderRadius: BorderRadius.circular(10)),
                            child: Text('틀림 $wrong회',
                              style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w600,
                                color: wrong >= 3
                                  ? const Color(0xFFD85A30)
                                  : Colors.black45)),
                          ),
                      ]),
                    );
                  })),
              ],
            ),
          ),
    );
  }
}

class _S extends StatelessWidget {
  final String v, l;
  const _S(this.v, this.l);
  @override
  Widget build(BuildContext ctx) => Column(children: [
    Text(v, style: const TextStyle(fontSize: 24,
      fontWeight: FontWeight.w800, color: Colors.white)),
    const SizedBox(height: 4),
    Text(l, style: const TextStyle(fontSize: 10, color: Colors.white54)),
  ]);
}
