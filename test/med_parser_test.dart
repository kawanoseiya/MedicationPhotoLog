import 'package:flutter_test/flutter_test.dart';
import 'package:snapmed/logic/med_parser.dart';

void main() {
  final now = DateTime(2026, 10, 6);

  test('日本の薬剤情報提供書', () {
    final r = MedParser.parse([
      'お薬の説明書',
      '山田 太郎 様',
      '調剤日 令和8年9月30日',
      '処方医療機関 さくら内科クリニック',
      'ロキソプロフェンNa錠60mg「サワイ」',
      '痛みや炎症をおさえるお薬です。',
      '1回1錠 1日3回 毎食後 7日分',
      'レバミピド錠100mg「オーツカ」 1回1錠 1日3回',
      '胃の粘膜を保護します。',
      'モーラステープ20mg',
      '血液をサラサラにする',
      'つばめ薬局 駅前店 TEL 03-1234-5678',
      '次回予約 2026年10月14日',
    ], now: now);
    expect(r.prescribedOn, DateTime(2026, 9, 30));
    expect(r.hospital, 'さくら内科クリニック');
    expect(r.pharmacy, 'つばめ薬局 駅前店');
    expect(r.medicines, [
      'ロキソプロフェンNa錠60mg「サワイ」',
      'レバミピド錠100mg「オーツカ」',
      'モーラステープ20mg',
    ]);
  });

  test('全角数字・西暦・見出しの次の行の日付', () {
    final r = MedParser.parse([
      '交付年月日',
      '２０２６年８月１日',
      '生年月日 1950年1月2日',
      'アムロジピンOD錠５ｍｇ「トーワ」',
      '保険薬局名：みどり調剤薬局',
    ], now: now);
    expect(r.prescribedOn, DateTime(2026, 8, 1));
    expect(r.medicines, ['アムロジピンOD錠5mg「トーワ」']);
    expect(r.pharmacy, 'みどり調剤薬局');
  });

  test('米国の薬のラベル', () {
    final r = MedParser.parse([
      'CVS pharmacy',
      'Rx# 1234567 Date Filled: 09/28/2026',
      'JOHN SMITH',
      'TAKE 1 CAPSULE BY MOUTH THREE TIMES DAILY',
      'AMOXICILLIN 500MG CAPSULE',
      'Qty: 30 Refills: 0',
      'Prescriber: Dr. Jane Doe',
      'Discard after: 09/28/2027',
    ], now: now);
    expect(r.prescribedOn, DateTime(2026, 9, 28));
    expect(r.pharmacy, 'CVS pharmacy');
    expect(r.hospital, 'Dr. Jane Doe');
    expect(r.medicines, ['AMOXICILLIN 500MG CAPSULE']);
  });

  test('月名の日付・病院名', () {
    final r = MedParser.parse([
      'St. Mary Hospital',
      'Oct 2, 2026',
      'Lisinopril 10 mg tablet',
      'Lisinopril 10mg Tablet',
    ], now: now);
    expect(r.prescribedOn, DateTime(2026, 10, 2));
    expect(r.hospital, 'St. Mary Hospital');
    expect(r.medicines, ['Lisinopril 10 mg tablet']);
  });

  test('読み取れない項目は空のまま', () {
    final r = MedParser.parse(['こんにちは', 'ありがとう'], now: now);
    expect(r.prescribedOn, isNull);
    expect(r.medicines, isEmpty);
    expect(r.hospital, '');
    expect(r.pharmacy, '');
  });

  test('未来の日付・ありえない日付は処方日にしない', () {
    expect(
      MedParser.findPrescribedDate(['2027/01/01', '2026/02/30'], now),
      isNull,
    );
    expect(MedParser.datesIn('R6.10.5'), [DateTime(2024, 10, 5)]);
    expect(MedParser.datesIn('令和元年5月1日'), [DateTime(2019, 5, 1)]);
    expect(MedParser.datesIn('5 Oct 2024'), [DateTime(2024, 10, 5)]);
    expect(MedParser.datesIn('25/12/2024'), [DateTime(2024, 12, 25)]);
  });
}
