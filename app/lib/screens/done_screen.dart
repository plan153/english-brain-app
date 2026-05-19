// 5문장 완료 화면 — 통계 + 확장 학습 4가지

import 'package:flutter/material.dart';

class DoneScreen extends StatelessWidget {
  final int correct;
  final int total;
  final String verbName;
  final String typeName;

  const DoneScreen({super.key,
    required this.correct, required this.total,
    required this.verbName, required this.typeName});

  @override
  Widget build(BuildContext context) {
    final pct = (correct / total * 100).round();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const SizedBox(height: 20),
          // 축하
          const Text('🎉', style: TextStyle(fontSize: 72)),
          const SizedBox(height: 16),
          const Text('오늘 미션 완료!',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('$verbName · $typeName',
            style: const TextStyle(fontSize: 14, color: Colors.black45)),
          const SizedBox(height: 28),

          // 통계
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Stat('$total', '완료 문장'),
                _Stat('$pct%', '정확도'),
                _Stat(correct >= total - 1 ? '🔥' : '💪', '오늘'),
              ]),
          ),
          const SizedBox(height: 24),

          // 확장 학습
          Align(alignment: Alignment.centerLeft,
            child: const Text('더 공부할까요?',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10, crossAxisSpacing: 10,
            childAspectRatio: 2.0,
            children: const [
              _ExtCard('⏳', '시제 변형', '현재→과거→미래'),
              _ExtCard('🔄', '긍정/부정', "don't / never"),
              _ExtCard('❓', '질문/맞장구', 'Really? / I know!'),
              _ExtCard('📍', '장소·시간', '블록 붙이기'),
            ],
          ),
          const SizedBox(height: 24),

          // 홈으로
          FilledButton(
            onPressed: () =>
              Navigator.of(context).popUntil((r) => r.isFirst),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A1A),
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14))),
            child: const Text('홈으로',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ]),
      )),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value, label;
  const _Stat(this.value, this.label);
  @override
  Widget build(BuildContext ctx) => Column(children: [
    Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
      color: Colors.white)),
    const SizedBox(height: 4),
    Text(label, style: const TextStyle(fontSize: 11, color: Colors.white54)),
  ]);
}

class _ExtCard extends StatelessWidget {
  final String icon, title, sub;
  const _ExtCard(this.icon, this.title, this.sub);
  @override
  Widget build(BuildContext ctx) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFFFAFAFA),
      border: Border.all(color: const Color(0xFFF0F0F0)),
      borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      Text(icon, style: const TextStyle(fontSize: 20)),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 12,
          fontWeight: FontWeight.w700)),
        Text(sub, style: const TextStyle(fontSize: 10,
          color: Colors.black38)),
      ]),
    ]),
  );
}
