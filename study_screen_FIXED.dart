// 학습 화면 — 듣기 → 이미지 연상 → 말하기 → 피드백
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/models.dart';
import '../services/content_service.dart';
import 'done_screen.dart';

class StudyScreen extends StatefulWidget {
  final List<Sentence> sentences;
  final String userId;
  const StudyScreen({super.key, required this.sentences, required this.userId});
  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  final _player = AudioPlayer();
  int _idx = 0;
  bool _showAnswer = false;
  bool _answerEnabled = false;
  bool? _lastCorrect;
  Timer? _answerTimer;
  // 웹/마이크 상태
  bool _micListening = false;
  String _micStatus = '';
  
  // ✅ 수정됨: 정답 개수 추적
  int _correctCount = 0;

  Sentence get _cur => widget.sentences[_idx];

  @override
  void initState() {
    super.initState();
    _startCard();
  }

  void _startCard() {
    setState(() {
      _showAnswer = false;
      _lastCorrect = null;
      _answerEnabled = false;
      _micListening = false;
      _micStatus = '';
    });
    // 답 보기 5초 잠금 (능동 인출)
    _answerTimer?.cancel();
    _answerTimer = Timer(const Duration(seconds: 5),
      () => mounted ? setState(() => _answerEnabled = true) : null);
  }

  void _onMic() {
    // 웹에서는 STT 미지원 → 힌트 안내로 폴백
    setState(() {
      _micListening = true;
      _micStatus = '🎙️ 말하거나 "답 보기"로 확인하세요';
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() { _micListening = false; _micStatus = ''; });
    });
  }

  Future<void> _playModel() async {
    if (_cur.audioUrl != null) {
      try { await _player.play(UrlSource(_cur.audioUrl!)); }
      catch (e) { debugPrint('오류: $e'); }
    }
  }

  void _markCorrect(bool ok) {
    // ✅ 수정됨: 정답일 때만 카운트
    if (ok) _correctCount++;
    
    setState(() { _lastCorrect = ok; _showAnswer = true; });
    ContentService.recordAnswer(widget.userId, _cur.id, ok);
  }

  void _next() {
    _answerTimer?.cancel();
    if (_idx + 1 >= widget.sentences.length) {
      // ✅ 수정됨: 동사 정보 동적 추출
      final firstSentence = widget.sentences.isNotEmpty 
        ? widget.sentences.first 
        : null;
      
      String verbName = 'English';
      if (firstSentence?.en.isNotEmpty ?? false) {
        final words = firstSentence!.en.split(' ');
        if (words.isNotEmpty) {
          verbName = words[0]
            .replaceAll(RegExp(r'[^a-zA-Z]'), '')
            .toUpperCase();
        }
      }
      
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => DoneScreen(
          correct: _correctCount,  // ✅ 실제 정답 개수
          total: widget.sentences.length,
          verbName: verbName,
          typeName: '오늘의 ${widget.sentences.length}문장',
        ),
      ));
    } else {
      setState(() => _idx++);
      _startCard();
    }
  }

  @override
  void dispose() {
    _answerTimer?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context)),
        title: Text('${_idx + 1} / ${widget.sentences.length}',
          style: const TextStyle(fontSize: 14, color: Colors.black45)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // 진행 바
          ClipRRect(borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _idx / widget.sentences.length,
              backgroundColor: const Color(0xFFF0F0F0),
              color: const Color(0xFF1A1A1A),
              minHeight: 4)),
          const SizedBox(height: 20),

          // 이미지 + 한국어 카드
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE6F1FB),
                borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.all(28),
              child: Column(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🧠', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  Text(_cur.ko,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20,
                      fontWeight: FontWeight.w700)),
                  if (_cur.chunkHint != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(10)),
                      child: Text(_cur.chunkHint!,
                        style: const TextStyle(fontSize: 12,
                          color: Colors.black54))),
                  ],
                ]),
            ),
          ),
          const SizedBox(height: 20),

          if (_showAnswer) ...[
            // 피드백
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(_lastCorrect == true ? '✅ 정답!' : '📖 모범 답안',
                      style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700,
                        color: _lastCorrect == true
                          ? const Color(0xFF085041)
                          : const Color(0xFF1A1A1A))),
                  ]),
                  const SizedBox(height: 8),
                  Text(_cur.en,
                    style: const TextStyle(fontSize: 18,
                      fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Row(children: [
                    OutlinedButton.icon(
                      onPressed: _playModel,
                      icon: const Icon(Icons.volume_up, size: 16),
                      label: const Text('발음 듣기'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                        textStyle: const TextStyle(fontSize: 12))),
                  ]),
                ]),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _markCorrect(false);
                    setState(() { _showAnswer = false; _answerEnabled = true; });
                    _startCard();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text('다시 해볼게요'))),
              const SizedBox(width: 10),
              Expanded(flex: 2,
                child: FilledButton(
                  onPressed: _next,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A1A),
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: Text(
                    _idx + 1 >= widget.sentences.length
                      ? '완료! 🎉' : '다음 →',
                    style: const TextStyle(fontWeight: FontWeight.w700)))),
            ]),
          ] else ...[
            // 마이크 상태
            Container(
              height: 44,
              alignment: Alignment.center,
              child: Text(
                _micListening ? _micStatus : '영어로 말해보세요',
                style: const TextStyle(color: Colors.black38, fontSize: 13))),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              // 힌트
              _ActionBtn(
                icon: '💡', label: '힌트',
                onTap: () => _showHintSheet(context)),
              // 마이크
              GestureDetector(
                onTap: _onMic,
                child: Container(
                  width: 66, height: 66,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _micListening
                      ? const Color(0xFF1A1A1A)
                      : const Color(0xFFF2F2F2)),
                  child: Icon(Icons.mic,
                    color: _micListening ? Colors.white : Colors.black87,
                    size: 28))),
              // 답 보기 (5초 잠금)
              _ActionBtn(
                icon: '👁️',
                label: _answerEnabled ? '답 보기' : '5초 후',
                enabled: _answerEnabled,
                onTap: () => _markCorrect(false)),
            ]),
            const SizedBox(height: 12),
            // 정답 버튼 (웹 폴백)
            TextButton(
              onPressed: () => _markCorrect(true),
              child: const Text('✅ 맞게 말했어요',
                style: TextStyle(color: Colors.black45, fontSize: 12))),
          ],
        ]),
      ),
    );
  }

  void _showHintSheet(BuildContext ctx) {
    showModalBottomSheet(context: ctx,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('💡 힌트', style: TextStyle(
            fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 12),
          Text(_cur.chunkHint ?? '핵심 동사의 이미지를 떠올려보세요.',
            style: const TextStyle(fontSize: 14, color: Colors.black54,
              height: 1.6), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(_cur.en.split(' ').first + '...',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
              color: Color(0xFF0C447C))),
          const SizedBox(height: 20),
        ]),
      ));
  }
}

class _ActionBtn extends StatelessWidget {
  final String icon, label;
  final VoidCallback onTap;
  final bool enabled;
  const _ActionBtn({required this.icon, required this.label,
    required this.onTap, this.enabled = true});
  @override
  Widget build(BuildContext ctx) => GestureDetector(
    onTap: enabled ? onTap : null,
    child: Opacity(opacity: enabled ? 1.0 : 0.4,
      child: Column(children: [
        Container(width: 44, height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF5F5F5)),
          child: Center(child: Text(icon,
            style: const TextStyle(fontSize: 20)))),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(
          fontSize: 10, color: Colors.black45)),
      ])));
}
