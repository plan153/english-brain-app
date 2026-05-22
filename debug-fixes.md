# English Brain App - Debug Fixes

## 이슈 1: 정답 트래킹 버그 수정

### 파일: `app/lib/screens/study_screen.dart`

**변경사항:**
1. State 클래스에 `_correctCount` 변수 추가
2. `_markCorrect()` 메서드 수정
3. `_correct` getter 제거 또는 수정

```dart
class _StudyScreenState extends State<StudyScreen> {
  final _player = AudioPlayer();
  int _idx = 0;
  bool _showAnswer = false;
  bool _answerEnabled = false;
  bool? _lastCorrect;
  Timer? _answerTimer;
  bool _micListening = false;
  String _micStatus = '';
  
  // ✅ 추가: 정답 개수 추적
  int _correctCount = 0;

  Sentence get _cur => widget.sentences[_idx];
  
  // ✅ 제거 또는 수정 필요한 줄
  // int get _correct => widget.sentences
  //   .take(_idx).where((_) => true).length;
```

**_markCorrect() 메서드 수정:**
```dart
void _markCorrect(bool ok) {
  // ✅ 정답일 때만 카운트
  if (ok) _correctCount++;
  
  setState(() { _lastCorrect = ok; _showAnswer = true; });
  ContentService.recordAnswer(widget.userId, _cur.id, ok);
}
```

**_startCard() 메서드에 초기화 추가:**
```dart
void _startCard() {
  setState(() {
    _showAnswer = false;
    _lastCorrect = null;
    _answerEnabled = false;
    _micListening = false;
    _micStatus = '';
  });
  _answerTimer?.cancel();
  _answerTimer = Timer(const Duration(seconds: 5),
    () => mounted ? setState(() => _answerEnabled = true) : null);
}
```

---

## 이슈 2: 완료 화면 데이터 하드코딩 수정

### 파일: `app/lib/screens/study_screen.dart` - _next() 메서드

**변경 전 (라인 75-92):**
```dart
void _next() {
  _answerTimer?.cancel();
  if (_idx + 1 >= widget.sentences.length) {
    final correctCount = widget.sentences.length; // ❌ 잘못됨
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (_) => DoneScreen(
        correct: correctCount,
        total: widget.sentences.length,
        verbName: 'HAVE',        // ❌ 하드코딩
        typeName: '오늘의 5문장', // ❌ 하드코딩
      ),
    ));
  } else {
    setState(() => _idx++);
    _startCard();
  }
}
```

**변경 후 (수정된 버전):**
```dart
void _next() {
  _answerTimer?.cancel();
  if (_idx + 1 >= widget.sentences.length) {
    // ✅ 첫 번째 문장에서 동사 정보 가져오기
    final firstSentence = widget.sentences.isNotEmpty 
      ? widget.sentences.first 
      : null;
    
    // ✅ 동사 이름 추출 (영문장의 첫 단어 또는 "English")
    String verbName = 'English';
    if (firstSentence?.en.isNotEmpty ?? false) {
      final words = firstSentence!.en.split(' ');
      if (words.isNotEmpty) {
        verbName = words[0].replaceAll(RegExp(r'[^a-zA-Z]'), '').toUpperCase();
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
```

---

## 이슈 3: 연속 학습일 수(Streak) 미구현

### 파일: `app/lib/screens/mission_screen.dart` - _loadStats() 메서드

**변경 전 (라인 27-40):**
```dart
Future<void> _loadStats() async {
  try {
    final progress = await Supabase.instance.client
      .from('user_progress').select('correct_count, wrong_count')
      .eq('user_id', _uid);
    final totalC = progress.fold(0, (s, r) => s + (r['correct_count'] as int? ?? 0));
    final totalW = progress.fold(0, (s, r) => s + (r['wrong_count'] as int? ?? 0));
    final totalA = totalC + totalW;
    setState(() {
      _totalDone = totalA;
      _acc = totalA > 0 ? (totalC / totalA * 100).round() : 0;
      // ❌ _streak은 계산 안 됨
    });
  } catch (_) {}
}
```

**변경 후 (수정된 버전):**
```dart
Future<void> _loadStats() async {
  try {
    // 1단계: 사용자 프로필에서 streak 가져오기
    final userProfile = await Supabase.instance.client
      .from('users')
      .select('streak_days')
      .eq('id', _uid)
      .maybeSingle(); // 없으면 null, 있으면 데이터
    
    // 2단계: 학습 진행도 가져오기
    final progress = await Supabase.instance.client
      .from('user_progress')
      .select('correct_count, wrong_count')
      .eq('user_id', _uid);
    
    final totalC = progress.fold(0, (s, r) => s + (r['correct_count'] as int? ?? 0));
    final totalW = progress.fold(0, (s, r) => s + (r['wrong_count'] as int? ?? 0));
    final totalA = totalC + totalW;
    
    setState(() {
      _streak = userProfile?['streak_days'] ?? 0;  // ✅ streak 설정
      _totalDone = totalA;
      _acc = totalA > 0 ? (totalC / totalA * 100).round() : 0;
    });
  } catch (e) {
    debugPrint('Stats loading error: $e');
  }
}
```

---

## 추가 개선사항 (권장)

### 1. null 안전성 개선
```dart
// content_service.dart - getTodayMission()
static Future<List<Sentence>> getTodayMission(String userId) async {
  try {
    final raw = await _db.rpc('generate_daily_mission',
        params: {'p_user_id': userId});
    
    if (raw == null) return [];
    
    final ids = (raw as List)
      .whereType<num>()  // null 필터링
      .map((e) => e.toInt())
      .toList();
    
    if (ids.isEmpty) return [];
    
    return (await _db.from('sentences')
      .select()
      .inFilter('id', ids) as List)
      .map((e) => Sentence.fromJson(e))
      .toList();
  } catch (e) {
    debugPrint('Error getting daily mission: $e');
    return [];
  }
}
```

### 2. 웹 플랫폼에서 STT 대체 기능
```dart
// study_screen.dart - _onMic() 메서드 개선
void _onMic() {
  setState(() {
    _micListening = true;
    _micStatus = '🎙️ 말하거나 아래 "답 보기"로 확인하세요\n(웹 브라우저는 텍스트 입력 모드)';
  });
  Future.delayed(const Duration(seconds: 3), () {
    if (mounted) setState(() { 
      _micListening = false; 
      _micStatus = ''; 
    });
  });
}
```

### 3. 에러 핸들링 개선
모든 비동기 함수에 try-catch 추가
```dart
try {
  // ... 비동기 작업
} catch (e) {
  debugPrint('Error: $e');
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('오류 발생: $e')));
  }
}
```

---

## 테스트 체크리스트

- [ ] 5문장 완료 후 정답 개수가 정확히 표시되는가?
- [ ] "완료!" 화면에서 동사 이름이 하드코딩되지 않는가?
- [ ] 홈 화면에서 "연속 학습일" 숫자가 변하는가?
- [ ] 정답/오답 기록이 데이터베이스에 저장되는가?
- [ ] 웹에서 STT 메시지가 명확하게 표시되는가?
