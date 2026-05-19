// 0단계 — 영어 문장의 뼈대 (신규 사용자 필수 선행 학습)
// 완료해야 본 학습 잠금 해제

import 'package:flutter/material.dart';
import '../services/content_service.dart';
import '../models/models.dart';
import 'mission_screen.dart';

class Stage0Screen extends StatefulWidget {
  const Stage0Screen({super.key});
  @override
  State<Stage0Screen> createState() => _Stage0ScreenState();
}

class _Stage0ScreenState extends State<Stage0Screen> {
  List<Stage0Item> _items = [];
  int _current = 0;
  int _exIdx = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await ContentService.getStage0();
    setState(() { _items = items; _loading = false; });
  }

  void _next() {
    final item = _items[_current];
    if (_exIdx < item.examples.length - 1) {
      setState(() => _exIdx++);
    } else if (_current < _items.length - 1) {
      setState(() { _current++; _exIdx = 0; });
    } else {
      // 0단계 완료 → 본 학습으로
      Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const MissionScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(
      body: Center(child: CircularProgressIndicator()));

    if (_items.isEmpty) return const Scaffold(
      body: Center(child: Text('데이터를 불러올 수 없어요')));

    final item = _items[_current];
    final ex = item.examples[_exIdx] as Map<String, dynamic>;
    final totalSteps = _items.fold(0, (s, i) => s + (i.examples as List).length);
    final doneSteps = _items.take(_current).fold(0, (s, i) => s + (i.examples as List).length) + _exIdx;
    final progress = doneSteps / totalSteps;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(child: Column(children: [
        // 상단 진행바
        Padding(padding: const EdgeInsets.all(20), child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('0단계 — 영어 문장의 뼈대',
                style: const TextStyle(fontSize: 12, color: Colors.black45)),
              Text('${_current + 1} / ${_items.length}',
                style: const TextStyle(fontSize: 12, color: Colors.black45)),
            ]),
            const SizedBox(height: 8),
            ClipRRect(borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: progress,
                backgroundColor: const Color(0xFFF0F0F0),
                color: const Color(0xFFD85A30), minHeight: 4)),
          ],
        )),

        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // 뼈대 제목
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFAECE7),
                borderRadius: BorderRadius.circular(16)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.name,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800,
                    color: Color(0xFFD85A30))),
                const SizedBox(height: 8),
                Text(item.concept,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF993C1D),
                    height: 1.6)),
              ]),
            ),
            const SizedBox(height: 20),

            // ❌ → ✅ 예시
            const Text('이렇게 바꿔요',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                color: Colors.black45)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFF0F0F0)),
                borderRadius: BorderRadius.circular(14)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // 틀린 것
                Row(children: [
                  const Text('❌ ', style: TextStyle(fontSize: 16)),
                  Text(ex['wrong'] ?? '',
                    style: const TextStyle(fontSize: 15, color: Color(0xFF993C1D),
                      decoration: TextDecoration.lineThrough,
                      decorationColor: Color(0xFF993C1D))),
                ]),
                const SizedBox(height: 12),
                // 맞는 것
                Row(children: [
                  const Text('✅ ', style: TextStyle(fontSize: 16)),
                  Expanded(child: Text(ex['right'] ?? '',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700,
                      color: Color(0xFF085041)))),
                ]),
                const SizedBox(height: 12),
                // 이유
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(8)),
                  child: Text(ex['why'] ?? '',
                    style: const TextStyle(fontSize: 12, color: Colors.black54,
                      height: 1.5)),
                ),
              ]),
            ),
            const SizedBox(height: 12),

            // 진행 점
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              ...List.generate(item.examples.length, (i) => Container(
                width: 7, height: 7, margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i <= _exIdx
                    ? const Color(0xFFD85A30)
                    : const Color(0xFFF0F0F0)),
              )),
            ]),
            const SizedBox(height: 32),
          ]),
        )),

        // 하단 버튼
        Padding(padding: const EdgeInsets.all(20), child: FilledButton(
          onPressed: _next,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF1A1A1A),
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(
            _current == _items.length - 1 && _exIdx == item.examples.length - 1
              ? '완료 — 학습 시작하기 🚀'
              : '다음 →',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        )),
      ])),
    );
  }
}
