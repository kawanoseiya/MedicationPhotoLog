/// 読み取った文字から、処方日・薬名・医療機関・薬局の候補を拾う。
///
/// 日本の薬剤情報提供書・薬袋と、海外の薬のラベル・箱・処方書類を対象にする。
/// ここで拾うのは入力欄の下書きだけで、保存前に必ず利用者が確認・修正する。
/// 拾えなかった項目は空のまま返す（推測で埋めない）。
class ParsedMedInfo {
  const ParsedMedInfo({
    this.prescribedOn,
    this.medicines = const [],
    this.hospital = '',
    this.pharmacy = '',
  });

  final DateTime? prescribedOn;
  final List<String> medicines;
  final String hospital;
  final String pharmacy;

  @override
  String toString() =>
      'date=$prescribedOn\nhospital=$hospital\npharmacy=$pharmacy\n'
      'medicines=\n${medicines.join('\n')}';
}

class MedParser {
  MedParser._();

  static const int maxMedicines = 30;

  /// [lines] は読み取った文字のまとまり（Vision の1行）を上から順に並べたもの。
  static ParsedMedInfo parse(List<String> lines, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final normalized = [
      for (final l in lines)
        if (normalize(l).isNotEmpty) normalize(l),
    ];
    return ParsedMedInfo(
      prescribedOn: findPrescribedDate(normalized, today),
      medicines: findMedicines(normalized),
      hospital: findHospital(normalized),
      pharmacy: findPharmacy(normalized),
    );
  }

  /// 全角の英数字・記号・空白を半角にし、連続する空白を1つにまとめる。
  static String normalize(String s) {
    final buf = StringBuffer();
    for (final r in s.runes) {
      if (r >= 0xFF01 && r <= 0xFF5E) {
        buf.writeCharCode(r - 0xFEE0);
      } else if (r == 0x3000) {
        buf.write(' ');
      } else {
        buf.writeCharCode(r);
      }
    }
    return buf.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  // ---------------------------------------------------------------- 日付

  static final _positiveDateKey = RegExp(
    r'処方日|処方年月日|調剤日|調剤年月日|交付日|交付年月日|発行日|お渡し日|受付日|'
    r'date filled|fill date|filled|rx date|dispensed|date of issue|issued|'
    r'prescription date|date',
    caseSensitive: false,
  );

  static final _negativeDateKey = RegExp(
    r'生年月日|誕生|使用期限|有効期限|期限|次回|予約|'
    r'birth|dob|discard|expir|exp\b|use by|use before|best before|next|refill by',
    caseSensitive: false,
  );

  static const _months = {
    'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4, 'may': 5, 'jun': 6, //
    'jul': 7, 'aug': 8, 'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12,
  };

  /// 1行に含まれる日付をすべて返す（ありえない日付は除く）。
  static List<DateTime> datesIn(String line) {
    final found = <DateTime>[];
    void add(int y, int m, int d) {
      if (m < 1 || m > 12 || d < 1 || d > 31) return;
      final date = DateTime(y, m, d);
      if (date.month != m) return; // 2月30日など
      found.add(date);
    }

    // 和暦（令和・平成）。「令和6年10月5日」「R6.10.5」「R 6/10/05」
    for (final m in RegExp(
      r'(令和|平成|R|H)\s*(\d{1,2}|元)\s*[年./\-]\s*(\d{1,2})\s*[月./\-]\s*(\d{1,2})',
    ).allMatches(line)) {
      final n = m[2] == '元' ? 1 : int.parse(m[2]!);
      final base = (m[1] == '令和' || m[1] == 'R') ? 2018 : 1988;
      add(base + n, int.parse(m[3]!), int.parse(m[4]!));
    }
    // 西暦（年が先）。「2024年10月5日」「2024/10/05」「2024-10-05」
    for (final m in RegExp(
      r'(?<!\d)((?:19|20)\d{2})\s*[年./\-]\s*(\d{1,2})\s*[月./\-]\s*(\d{1,2})',
    ).allMatches(line)) {
      add(int.parse(m[1]!), int.parse(m[2]!), int.parse(m[3]!));
    }
    // 月名。「Oct 5, 2024」「October 05 2024」
    for (final m in RegExp(
      r'\b(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*\.?\s+(\d{1,2}),?\s+((?:19|20)\d{2})\b',
      caseSensitive: false,
    ).allMatches(line)) {
      add(int.parse(m[3]!), _months[m[1]!.toLowerCase()]!, int.parse(m[2]!));
    }
    // 月名。「5 Oct 2024」「05-Oct-2024」
    for (final m in RegExp(
      r'\b(\d{1,2})[\s\-]+(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]*\.?[\s\-]+((?:19|20)\d{2})\b',
      caseSensitive: false,
    ).allMatches(line)) {
      add(int.parse(m[3]!), _months[m[2]!.toLowerCase()]!, int.parse(m[1]!));
    }
    // 年が後ろ。「10/05/2024」「10/05/24」。月が先と見なし、13以上なら日が先。
    for (final m in RegExp(
      r'(?<![\d/.\-])(\d{1,2})[/.\-](\d{1,2})[/.\-]((?:19|20)?\d{2})(?![\d/.\-])',
    ).allMatches(line)) {
      final a = int.parse(m[1]!);
      final b = int.parse(m[2]!);
      var y = int.parse(m[3]!);
      if (y < 100) y += 2000;
      if (a > 12 && b <= 12) {
        add(y, b, a);
      } else {
        add(y, a, b);
      }
    }
    return found;
  }

  /// 処方日を探す。処方日・調剤日などの見出しのある日付を優先し、
  /// 無ければ期限・生年月日以外の日付のうち今日までで最も新しいもの。
  static DateTime? findPrescribedDate(List<String> lines, DateTime today) {
    final limit = DateTime(today.year, today.month, today.day + 1);
    final earliest = DateTime(2000);
    bool plausible(DateTime d) => !d.isBefore(earliest) && d.isBefore(limit);

    // 見出しの次の行に日付があるレイアウトも拾う。
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (!_positiveDateKey.hasMatch(line) || _negativeDateKey.hasMatch(line)) {
        continue;
      }
      final here = datesIn(line).where(plausible).toList();
      if (here.isNotEmpty) return here.first;
      if (i + 1 < lines.length && !_negativeDateKey.hasMatch(lines[i + 1])) {
        final next = datesIn(lines[i + 1]).where(plausible).toList();
        if (next.isNotEmpty) return next.first;
      }
    }

    DateTime? best;
    for (final line in lines) {
      if (_negativeDateKey.hasMatch(line)) continue;
      for (final d in datesIn(line)) {
        if (!plausible(d)) continue;
        if (best == null || d.isAfter(best)) best = d;
      }
    }
    return best;
  }

  // ---------------------------------------------------------------- 文の判定

  /// 説明文（用法・効能・注意書き）らしい行。施設名や薬名ではない。
  static final _sentence = RegExp(
    r'ください|ます|です|ません|でしょう|こと|ように|場合|には|ので|ため|'
    r'\b(take|use|apply|ask|call|may|do not|don.t|if|should|before|after|'
    r'with|until|every|times|daily|warning|caution|keep|store|avoid)\b',
    caseSensitive: false,
  );

  static final _phoneTail = RegExp(
    r'\s*(TEL|Tel|tel|電話|☎|℡|FAX|Fax|Phone|PH)[\s.:：]*[\d(（].*$',
  );

  static String _stripLabel(String s, RegExp label) =>
      s.replaceFirst(label, '').replaceFirst(_phoneTail, '').trim();

  // ---------------------------------------------------------------- 医療機関

  static final _hospitalWord = RegExp(
    r'病院|医院|クリニック|診療所|医療センター|メディカルセンター|歯科|'
    r'hospital|clinic|medical cent(er|re)|health cent(er|re)|medical group|surgery\b|'
    r'practice\b',
    caseSensitive: false,
  );

  static final _hospitalLabel = RegExp(
    r'^(処方)?(医療機関|病院|医院)(名|の名称)?\s*[:：]?\s*|'
    r'^(hospital|clinic|prescriber|prescribed by|doctor|dr\.?)\s*[:：]\s*',
    caseSensitive: false,
  );

  static final _prescriber = RegExp(
    r'^(prescriber|prescribed by|doctor|physician)\s*[:：]?\s*(.+)$|^(dr\.?\s+[A-Za-z].+)$',
    caseSensitive: false,
  );

  static String findHospital(List<String> lines) {
    for (final line in lines) {
      if (!_hospitalWord.hasMatch(line)) continue;
      if (_pharmacyWord.hasMatch(line)) continue;
      if (_sentence.hasMatch(line)) continue;
      final name = _stripLabel(line, _hospitalLabel);
      // 見出しだけの行（「医療機関」）は次の行を名前とみなさず飛ばす。
      if (name.length < 2 || name.length > 40) continue;
      if (RegExp(r'^(医療機関|病院|医院)$').hasMatch(name)) continue;
      return name;
    }
    // 海外のラベルは医療機関名が無く、処方医の名前だけのことが多い。
    for (final line in lines) {
      final m = _prescriber.firstMatch(line);
      if (m == null) continue;
      final name = (m[2] ?? m[3] ?? '').replaceFirst(_phoneTail, '').trim();
      if (name.length >= 3 && name.length <= 40) return name;
    }
    return '';
  }

  // ---------------------------------------------------------------- 薬局

  static final _pharmacyWord = RegExp(
    r'薬局|調剤|ファーマシー|ドラッグ|薬店|'
    r'pharmacy|pharmacie|apotheke|farmacia|chemist|drug ?store|'
    r'\bcvs\b|walgreens|rite aid|boots|walmart|costco|kroger',
    caseSensitive: false,
  );

  static final _pharmacyLabel = RegExp(
    r'^(保険)?(調剤)?(薬局|pharmacy)(名|の名称)?\s*[:：]\s*|'
    r'^調剤(した)?薬局(名)?\s*[:：]?\s*(?=\S)|^保険薬局(名)?\s*[:：]?\s*(?=\S)',
    caseSensitive: false,
  );

  static String findPharmacy(List<String> lines) {
    for (final line in lines) {
      if (!_pharmacyWord.hasMatch(line)) continue;
      if (_sentence.hasMatch(line)) continue;
      // 「調剤日」「調剤料」など、施設名ではない見出し。
      if (RegExp(r'調剤(日|年月日|料|量|技術|報酬|基本)').hasMatch(line)) continue;
      if (datesIn(line).isNotEmpty) continue;
      final name = _stripLabel(line, _pharmacyLabel);
      if (name.length < 2 || name.length > 40) continue;
      if (RegExp(
        r'^(保険)?(調剤)?薬局(名)?$|^pharmacy$',
        caseSensitive: false,
      ).hasMatch(name)) {
        continue;
      }
      return name;
    }
    return '';
  }

  // ---------------------------------------------------------------- 薬名

  /// 剤形（日本語）。
  static final _jpForm = RegExp(
    r'(OD)?錠|カプセル|ドライシロップ|シロップ|細粒|顆粒|散|軟膏|クリーム|点眼|点鼻|'
    r'点耳|貼付|テープ|パップ|吸入|エアゾール|スプレー|内用液|液|ゲル|ゼリー|'
    r'ローション|坐剤|坐薬|トローチ|注',
  );

  /// 含量・濃度。
  static final _strength = RegExp(
    r'\d+(\.\d+)?\s*(mg|mcg|μg|µg|ug|g|mL|ml|L|%|％|IU|単位|units?)(?![A-Za-z])',
    caseSensitive: false,
  );

  static final _katakana = RegExp(r'[ァ-ヶー]{2,}');

  /// 薬名の後ろに続く用法・数量。ここから後ろは切り捨てる。
  static final _usageTail = RegExp(
    r'\s*(1回|1日|\d+日分|\d+回分|毎食|食後|食前|食間|就寝前|起床時|頓服|分[1-4]|'
    r'朝|昼|夕|寝る前|\d+錠$|\d+個$|\d+枚$|×|x\s*\d|'
    r'#\s*\d|qty|quantity|refills?|take\b|sig\b|ndc\b|rx\s*#?\s*\d).*$',
    caseSensitive: false,
  );

  static final _leadingMark = RegExp(
    r'^(\(?\d{1,2}[.)）．]\s*|Rp\.?\s*\d+\s*|[・●○◆◇■□▪▶︎★☆【\[\-]\s*)',
  );

  /// 見出しや説明であり、薬名ではない行。
  static final _notMedicine = RegExp(
    r'薬剤情報|お薬の|おくすり|お薬手帳|説明書|薬の名前|薬品名|写真|効能|効果|'
    r'副作用|飲み方|使い方|用法|用量|注意|保管|処方箋|処方せん|領収|明細|'
    r'患者|様$|さま$|殿$|'
    r'\b(name|patient|doctor|pharmacist|address|warning|directions|'
    r'ingredients?|active|inactive|purpose|uses|store|expires?)\b',
    caseSensitive: false,
  );

  static final _enName = RegExp(r'[A-Za-z][A-Za-z\-]{3,}');

  static List<String> findMedicines(List<String> lines) {
    final result = <String>[];
    final seen = <String>{};
    for (final raw in lines) {
      final name = medicineNameIn(raw);
      if (name == null) continue;
      final key = name.toLowerCase().replaceAll(RegExp(r'\s'), '');
      if (!seen.add(key)) continue;
      result.add(name);
      if (result.length >= maxMedicines) break;
    }
    return result;
  }

  /// 1行が薬名なら、用法などを除いた薬名を返す。
  static String? medicineNameIn(String line) {
    var s = line.replaceFirst(_leadingMark, '').trim();
    if (_notMedicine.hasMatch(s)) return null;

    final hasJapanese = RegExp(r'[ぁ-んァ-ヶ一-龠]').hasMatch(s);
    if (hasJapanese) {
      // 先頭の薬名部分だけを見る（「…錠60mg 1回1錠 1日3回 毎食後」）。
      s = s.replaceFirst(_usageTail, '').trim();
      if (s.isEmpty || _sentence.hasMatch(s)) return null;
      final kana = _katakana.firstMatch(s);
      if (kana == null) return null;
      final rest = s.substring(kana.start);
      if (!_jpForm.hasMatch(rest) && !_strength.hasMatch(rest)) return null;
      // 剤形の語がカタカナ名の直後にない一般の言葉（「血液」など）は除く。
      if (!_strength.hasMatch(s) &&
          !RegExp(
            r'[ァ-ヶー]{2,}[A-Za-z0-9・\s]*((OD)?錠|カプセル|ドライシロップ|シロップ|細粒|顆粒|散|'
            r'軟膏|クリーム|点眼|点鼻|点耳|テープ|パップ|吸入|エアゾール|スプレー|'
            r'内用液|液|ゲル|ゼリー|ローション|坐剤|トローチ)',
          ).hasMatch(s)) {
        return null;
      }
    } else {
      s = s.replaceFirst(_usageTail, '').trim();
      if (s.isEmpty || _sentence.hasMatch(s)) return null;
      if (!_strength.hasMatch(s)) return null;
      final word = _enName.firstMatch(s);
      if (word == null) return null;
      // 含量より前に名前があること（「500 mg of ...」のような説明は除く）。
      if (word.start > _strength.firstMatch(s)!.start) return null;
    }
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (s.length < 3 || s.length > 60) return null;
    return s;
  }
}
