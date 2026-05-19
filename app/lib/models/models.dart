class Verb {
  final int id;
  final String name, coreImage, tagline, color;
  Verb({required this.id, required this.name, required this.coreImage,
        required this.tagline, required this.color});
  factory Verb.fromJson(Map<String, dynamic> j) => Verb(
    id: j['id'], name: j['name'], coreImage: j['core_image'] ?? '',
    tagline: j['tagline'] ?? '', color: j['color'] ?? '#1A1A1A');
}

class VerbType {
  final int id, verbId;
  final String name, concept;
  final String? imageUrl;
  VerbType({required this.id, required this.verbId, required this.name,
            required this.concept, this.imageUrl});
  factory VerbType.fromJson(Map<String, dynamic> j) => VerbType(
    id: j['id'], verbId: j['verb_id'], name: j['name'],
    concept: j['concept'] ?? '', imageUrl: j['image_url']);
}

class Sentence {
  final int id, typeId, level;
  final String ko, en, frequency;
  final String? chunkHint, tense, audioUrl, audioSlowUrl;
  Sentence({required this.id, required this.typeId, required this.ko,
            required this.en, required this.level, required this.frequency,
            this.chunkHint, this.tense, this.audioUrl, this.audioSlowUrl});
  factory Sentence.fromJson(Map<String, dynamic> j) => Sentence(
    id: j['id'], typeId: j['type_id'], ko: j['ko'], en: j['en'],
    level: j['level'] ?? 1, frequency: j['frequency'] ?? '중',
    chunkHint: j['chunk_hint'], tense: j['tense'],
    audioUrl: j['audio_url'], audioSlowUrl: j['audio_slow_url']);
}

class Trap {
  final String wrong, right, why;
  Trap({required this.wrong, required this.right, required this.why});
  factory Trap.fromJson(Map<String, dynamic> j) =>
    Trap(wrong: j['wrong_ex'], right: j['right_ex'], why: j['why']);
}

class Stage0Item {
  final String name, concept;
  final List<dynamic> examples;
  Stage0Item({required this.name, required this.concept, required this.examples});
  factory Stage0Item.fromJson(Map<String, dynamic> j) => Stage0Item(
    name: j['name'], concept: j['concept'], examples: j['examples'] ?? []);
}
