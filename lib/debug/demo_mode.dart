import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/photo_store.dart';
import '../data/record_repository.dart';
import '../models/med_record.dart';
import '../services/app_state.dart';

/// 画面確認・ストア用スクリーンショットのための起動オプション（`--dart-define`）。
///
/// - `DEMO=true`: 記録が空なら見本の記録を入れ、購入済み（広告なし）扱いにする
/// - `DEMO_PHOTOS=a.jpg,b.jpg`: 見本の記録に付ける写真（Mac 上のパス）
/// - `DEMO_ENTRY=x.jpg`: 起動したらその画像で確認画面を開く（文字読み取りの確認）
/// - `START_TAB=1`: 履歴タブで起動
class DemoMode {
  DemoMode._();

  static const enabled = bool.fromEnvironment('DEMO');
  static const _photos = String.fromEnvironment('DEMO_PHOTOS');
  static const entryImage = String.fromEnvironment('DEMO_ENTRY');
  static const startTab = int.fromEnvironment('START_TAB');

  /// 確認画面に渡す一時ファイル（保存すると写真フォルダへ移るため複製する）。
  static Future<String> copyToTemp(String path) async {
    final tmp = await getTemporaryDirectory();
    final target = p.join(tmp.path, 'demo_${p.basename(path)}');
    await File(path).copy(target);
    return target;
  }

  /// `DEMO_ENTRY` のとき、読み取った行と候補を書類フォルダの demo_ocr.txt に書き出す
  /// （画面外の項目も確かめられるように）。
  static Future<void> dumpOcr(List<String> lines, Object parsed) async {
    if (entryImage.isEmpty) return;
    final docs = await getApplicationDocumentsDirectory();
    await File(p.join(docs.path, 'demo_ocr.txt')).writeAsString(
      '${lines.join('\n')}\n----\n$parsed\n',
    );
  }

  static Future<void> seedIfEmpty() async {
    final state = AppState.instance;
    final repo = RecordRepository.instance;
    if ((await repo.allRecords()).isNotEmpty) return;
    final ja = state.persons.first.name == '自分';
    if (state.persons.length == 1) {
      await state.addPerson(ja ? '母' : 'Mom');
    }
    final photos = <String>[];
    for (final path in _photos.split(',').where((s) => s.isNotEmpty)) {
      final tmp = await copyToTemp(path);
      photos.add(await PhotoStore.adopt(tmp));
    }
    final me = state.persons.first.id!;
    final today = DateTime.now();
    DateTime daysAgo(int d) => DateTime(today.year, today.month, today.day - d);
    final samples = ja
        ? [
            (
              6,
              [
                'ロキソプロフェンNa錠60mg「サワイ」',
                'レバミピド錠100mg「オーツカ」',
                'アムロジピンOD錠5mg「トーワ」',
                'モーラステープ20mg',
              ],
              'さくら内科クリニック',
              'つばめ薬局 駅前店',
              '腰の痛みで受診',
            ),
            (34, ['アムロジピンOD錠5mg「トーワ」'], 'さくら内科クリニック', 'つばめ薬局 駅前店', ''),
            (63, ['カロナール錠200', 'ムコダイン錠500mg'], 'みなと耳鼻科', 'あおば調剤薬局', 'かぜ。5日分'),
            (95, ['アムロジピンOD錠5mg「トーワ」'], 'さくら内科クリニック', 'つばめ薬局 駅前店', ''),
          ]
        : [
            (
              6,
              ['Amoxicillin 500 mg capsule', 'Ibuprofen 400 mg tablet'],
              'Riverside Family Clinic',
              'Maple Street Pharmacy',
              'Sinus infection',
            ),
            (
              34,
              ['Lisinopril 10 mg tablet'],
              'Riverside Family Clinic',
              'Maple Street Pharmacy',
              '',
            ),
            (
              63,
              ['Cetirizine 10 mg tablet'],
              'Lakeview Medical Center',
              'Oak Pharmacy',
              'Allergy season',
            ),
            (
              95,
              ['Lisinopril 10 mg tablet'],
              'Riverside Family Clinic',
              'Maple Street Pharmacy',
              '',
            ),
          ];
    for (final (i, (days, meds, hospital, pharmacy, memo)) in samples.indexed) {
      final date = daysAgo(days);
      await repo.insert(
        MedRecord(
          personId: me,
          prescribedOn: date,
          medicines: meds,
          hospital: hospital,
          pharmacy: pharmacy,
          memo: memo,
          photos: i == 0 ? photos : const [],
          createdAt: date,
          updatedAt: date,
        ),
      );
    }
    await state.setPro(true);
    await state.notifyDataChanged();
  }
}
