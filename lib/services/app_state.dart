import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/record_repository.dart';
import '../models/med_record.dart';

/// 文字表示の大きさ（システムの文字サイズに上乗せする倍率）。
enum TextSizeOption {
  standard(1.0),
  large(1.15),
  extraLarge(1.3);

  const TextSizeOption(this.scale);
  final double scale;
}

/// 表示言語。system は端末の言語に合わせる。
enum LanguageOption {
  system(null),
  ja(Locale('ja')),
  en(Locale('en'));

  const LanguageOption(this.locale);
  final Locale? locale;
}

/// アプリ全体の状態（家族・設定・購入状態）。
///
/// 記録の追加・編集・削除があったら [notifyDataChanged] を呼び、
/// ホーム・履歴に再読み込みさせる。
class AppState extends ChangeNotifier {
  AppState._();

  static final AppState instance = AppState._();

  static const _kCurrentPerson = 'current_person';
  static const _kTextSize = 'text_size';
  static const _kLanguage = 'language';
  static const _kProCached = 'pro_cached';

  late SharedPreferences _prefs;

  List<Person> persons = [];
  int currentPersonId = 0;
  TextSizeOption textSize = TextSizeOption.standard;
  LanguageOption language = LanguageOption.system;

  /// 広告非表示を購入済みか。通信できないときは最後に確認できた状態を使う。
  bool isPro = false;

  /// 記録が変わるたびに増える番号。
  int dataRevision = 0;

  Person get currentPerson => persons.firstWhere(
    (p) => p.id == currentPersonId,
    orElse: () => persons.first,
  );

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    textSize = TextSizeOption.values.firstWhere(
      (o) => o.name == _prefs.getString(_kTextSize),
      orElse: () => TextSizeOption.standard,
    );
    language = LanguageOption.values.firstWhere(
      (o) => o.name == _prefs.getString(_kLanguage),
      orElse: () => LanguageOption.system,
    );
    isPro = _prefs.getBool(_kProCached) ?? false;
    await _loadPersons();
  }

  /// 家族を読み直す。誰もいなければ「自分」を作る（初回起動・全員削除後）。
  Future<void> _loadPersons() async {
    final repo = RecordRepository.instance;
    persons = await repo.persons();
    if (persons.isEmpty) {
      final ja =
          (language.locale ?? PlatformDispatcher.instance.locale)
              .languageCode ==
          'ja';
      persons = [await repo.addPerson(ja ? '自分' : 'Me')];
    }
    final saved = _prefs.getInt(_kCurrentPerson);
    currentPersonId = persons.any((p) => p.id == saved)
        ? saved!
        : persons.first.id!;
    notifyListeners();
  }

  Future<void> selectPerson(int id) async {
    currentPersonId = id;
    await _prefs.setInt(_kCurrentPerson, id);
    notifyListeners();
  }

  Future<Person> addPerson(String name) async {
    final person = await RecordRepository.instance.addPerson(name);
    persons = [...persons, person];
    notifyListeners();
    return person;
  }

  Future<void> renamePerson(int id, String name) async {
    await RecordRepository.instance.renamePerson(id, name);
    persons = [
      for (final p in persons) p.id == id ? p.copyWith(name: name) : p,
    ];
    notifyListeners();
  }

  Future<void> deletePerson(int id) async {
    await RecordRepository.instance.deletePerson(id);
    await _loadPersons();
    await notifyDataChanged();
  }

  Future<void> setTextSize(TextSizeOption option) async {
    textSize = option;
    await _prefs.setString(_kTextSize, option.name);
    notifyListeners();
  }

  Future<void> setLanguage(LanguageOption option) async {
    language = option;
    await _prefs.setString(_kLanguage, option.name);
    notifyListeners();
  }

  Future<void> setPro(bool value) async {
    if (isPro == value) return;
    isPro = value;
    await _prefs.setBool(_kProCached, value);
    notifyListeners();
  }

  /// 復元のあとなど、家族ごと入れ替わったときに呼ぶ。
  Future<void> reloadAll() async {
    await _loadPersons();
    await notifyDataChanged();
  }

  Future<void> notifyDataChanged() async {
    dataRevision++;
    notifyListeners();
  }
}
