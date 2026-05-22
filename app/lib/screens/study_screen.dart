// 학습 화면 — 듣기 → 이미지 연상 → 말하기 → 피드백
import 'dart:async';
import 'dart:js' as js;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/models.dart';
import '../services/content_service.dart';
import 'done_screen.dart';

class StudyScreen extends StatefulWidget {
  final List<Sentence> sentences;
  final String userId;
  const StudyScreen({
    super.key,
    required this.sentences,
    required this.userId,
  });

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
  bool _micListening = false;
  String _micStatus = '';
  List<bool> _answerRecord = [];

  Sentence get _cur => widget.sentences[_idx];
  int get _correct => _answerRecord.where((v) => v).length;

  @override
  void initState() {
    super.initState();
    _answerRecord = List.filled(widget.sentences.length, false);
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
    _answerTimer?.cancel();
    _answerTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _answerEnabled = true);
      }
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _playModel();
    });
  }

  Future<void> _playModel() async {
    debugPrint('🎤 _playModel 시작');
    debugPrint('kIsWeb: $kIsWeb');
    debugPrint('_cur.en: ${_cur.en}');

    final text = _cur.en.replaceAll("'", " ");

    if (kIsWeb) {
      debugPrint('🌐 웹 환경 - Web Speech API 사용 시도');
      try {
        final speechScript = """
        window.speechSynthesis.cancel();
        var utterance = new SpeechSynthesisUtterance('$text');
        utterance.lang = 'en-US';



