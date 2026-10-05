import 'package:flutter_test/flutter_test.dart';
import 'package:snapmed/models/med_record.dart';

void main() {
  final now = DateTime(2026, 10, 6, 9, 30);

  test('保存形式の往復（空欄のままでも保存できる）', () {
    final r = MedRecord(
      personId: 1,
      medicines: const ['ロキソプロフェン錠60mg', 'レバミピド錠100mg'],
      photos: const ['a.jpg', 'b.jpg'],
      ocrText: MedRecord.joinOcrPages(['1ページ目', '2ページ目\n続き']),
      createdAt: now,
      updatedAt: now,
    );
    final back = MedRecord.fromMap(r.toMap());
    expect(back.prescribedOn, isNull);
    expect(back.hospital, '');
    expect(back.medicines, r.medicines);
    expect(back.photos, r.photos);
    expect(back.ocrPages, ['1ページ目', '2ページ目\n続き']);
    expect(back.sortDate, now);
  });

  test('処方日は日付だけを保存する', () {
    final r = MedRecord(
      personId: 1,
      prescribedOn: DateTime(2026, 9, 30),
      createdAt: now,
      updatedAt: now,
    );
    expect(r.toMap()['prescribed_on'], '2026-09-30');
    expect(MedRecord.fromMap(r.toMap()).prescribedOn, DateTime(2026, 9, 30));
    expect(r.copyWith(clearPrescribedOn: true).prescribedOn, isNull);
  });

  test('読み取りの無いページは空として数をそろえる', () {
    final r = MedRecord(
      personId: 1,
      photos: const ['a.jpg', 'b.jpg', 'c.jpg'],
      ocrText: MedRecord.joinOcrPages(['x', '', 'z']),
      createdAt: now,
      updatedAt: now,
    );
    expect(r.ocrPages, ['x', '', 'z']);
    expect(MedRecord.joinOcrPages(['', '']), '');
  });
}
