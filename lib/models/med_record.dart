/// 記録の対象者（家族の1人）。
class Person {
  const Person({this.id, required this.name, this.sort = 0});

  final int? id;
  final String name;
  final int sort;

  Map<String, Object?> toMap() => {'id': id, 'name': name, 'sort': sort};

  factory Person.fromMap(Map<String, Object?> m) => Person(
    id: m['id'] as int?,
    name: (m['name'] as String?) ?? '',
    sort: (m['sort'] as int?) ?? 0,
  );

  Person copyWith({String? name, int? sort}) =>
      Person(id: id, name: name ?? this.name, sort: sort ?? this.sort);
}

/// 1回分の処方（薬の説明書・薬袋・ラベルなど1組の写真）の記録。
///
/// 処方日・薬名を含め、どの項目も空のまま保存できる。
class MedRecord {
  const MedRecord({
    this.id,
    required this.personId,
    this.prescribedOn,
    this.medicines = const [],
    this.hospital = '',
    this.pharmacy = '',
    this.memo = '',
    this.ocrText = '',
    this.photos = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final int personId;

  /// 処方日（日付のみ）。読み取れず入力もされなければ null。
  final DateTime? prescribedOn;
  final List<String> medicines;
  final String hospital;
  final String pharmacy;
  final String memo;

  /// 読み取った文字の全文。ページごとに [pageBreak] で区切り、[photos] と同じ順に並ぶ。
  /// 検索に使う。
  final String ocrText;

  /// 写真のファイル名（アプリの書類フォルダの photos/ からの相対）。ページ順。
  final List<String> photos;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// 一覧の並びと見出しに使う日付。処方日が無ければ登録日。
  DateTime get sortDate => prescribedOn ?? createdAt;

  static const pageBreak = '\f';

  /// ページごとの読み取り文字（[photos] と同じ数・順。読み取りが無いページは空）。
  List<String> get ocrPages {
    final pages = ocrText.isEmpty ? <String>[] : ocrText.split(pageBreak);
    return [
      for (var i = 0; i < photos.length; i++) i < pages.length ? pages[i] : '',
    ];
  }

  static String joinOcrPages(List<String> pages) =>
      pages.every((p) => p.trim().isEmpty) ? '' : pages.join(pageBreak);

  Map<String, Object?> toMap() => {
    'id': id,
    'person_id': personId,
    'prescribed_on': prescribedOn == null ? null : dateKey(prescribedOn!),
    'medicines': medicines.join('\n'),
    'hospital': hospital,
    'pharmacy': pharmacy,
    'memo': memo,
    'ocr_text': ocrText,
    'photos': photos.join('\n'),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory MedRecord.fromMap(Map<String, Object?> m) => MedRecord(
    id: m['id'] as int?,
    personId: (m['person_id'] as int?) ?? 0,
    prescribedOn: parseDateKey(m['prescribed_on'] as String?),
    medicines: _lines(m['medicines']),
    hospital: (m['hospital'] as String?) ?? '',
    pharmacy: (m['pharmacy'] as String?) ?? '',
    memo: (m['memo'] as String?) ?? '',
    ocrText: (m['ocr_text'] as String?) ?? '',
    photos: _lines(m['photos']),
    createdAt:
        DateTime.tryParse((m['created_at'] as String?) ?? '') ?? DateTime.now(),
    updatedAt:
        DateTime.tryParse((m['updated_at'] as String?) ?? '') ?? DateTime.now(),
  );

  MedRecord copyWith({
    int? id,
    int? personId,
    DateTime? prescribedOn,
    bool clearPrescribedOn = false,
    List<String>? medicines,
    String? hospital,
    String? pharmacy,
    String? memo,
    String? ocrText,
    List<String>? photos,
    DateTime? updatedAt,
  }) => MedRecord(
    id: id ?? this.id,
    personId: personId ?? this.personId,
    prescribedOn: clearPrescribedOn
        ? null
        : (prescribedOn ?? this.prescribedOn),
    medicines: medicines ?? this.medicines,
    hospital: hospital ?? this.hospital,
    pharmacy: pharmacy ?? this.pharmacy,
    memo: memo ?? this.memo,
    ocrText: ocrText ?? this.ocrText,
    photos: photos ?? this.photos,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  static List<String> _lines(Object? v) => ((v as String?) ?? '')
      .split('\n')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
}

/// 日付を `yyyy-MM-dd` にする（時差の影響を受けない保存形式）。
String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

DateTime? parseDateKey(String? s) {
  if (s == null || s.isEmpty) return null;
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(s);
  if (m == null) return null;
  return DateTime(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
}
