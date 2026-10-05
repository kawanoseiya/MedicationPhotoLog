import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/photo_store.dart';
import '../data/record_repository.dart';
import '../models/med_record.dart';

/// 記録と写真をまとめた1つの zip ファイル。
///
/// 中身は `backup.json`（家族と記録）と `photos/`（写真）。
/// 書き出しと復元は端末内だけで行い、保存先・送り先は利用者が共有シートで選ぶ。
class BackupService {
  BackupService._();

  static const format = 'snapmed-backup';
  static const version = 1;
  static const _json = 'backup.json';
  static const _photoDir = 'photos/';

  /// zip を一時フォルダに作り、そのパスを返す。
  static Future<String> export() async {
    final repo = RecordRepository.instance;
    final persons = await repo.persons();
    final records = await repo.allRecords();

    final now = DateTime.now();
    final stamp =
        '${dateKey(now).replaceAll('-', '')}_'
        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    final tmp = await getTemporaryDirectory();
    final path = p.join(tmp.path, 'SnapMed_backup_$stamp.zip');
    final old = File(path);
    if (await old.exists()) await old.delete();

    final encoder = ZipFileEncoder()..create(path);
    try {
      encoder.addArchiveFile(
        ArchiveFile.string(
          _json,
          jsonEncode({
            'format': format,
            'version': version,
            'exportedAt': now.toIso8601String(),
            'persons': [for (final x in persons) x.toMap()],
            'records': [for (final r in records) r.toMap()],
          }),
        ),
      );
      for (final r in records) {
        for (final name in r.photos) {
          final file = await PhotoStore.file(name);
          if (await file.exists()) {
            // 写真はすでに JPEG なので圧縮し直さない。
            await encoder.addFile(file, '$_photoDir$name', 0);
          }
        }
      }
    } finally {
      await encoder.close();
    }
    return path;
  }

  /// zip を読み、復元できる内容か確かめる。読めなければ [FormatException]。
  static Future<BackupContents> read(String path) async {
    final input = InputFileStream(path);
    try {
      final archive = ZipDecoder().decodeStream(input);
      final json = archive.findFile(_json)?.readBytes();
      if (json == null) throw const FormatException('backup.json not found');
      final data = jsonDecode(utf8.decode(json));
      if (data is! Map || data['format'] != format) {
        throw const FormatException('not a SnapMed backup');
      }
      if ((data['version'] as int? ?? 0) > version) {
        throw const FormatException('newer backup version');
      }
      final persons = [
        for (final m in (data['persons'] as List? ?? const []))
          Person.fromMap(Map<String, Object?>.from(m as Map)),
      ];
      final records = [
        for (final m in (data['records'] as List? ?? const []))
          MedRecord.fromMap(Map<String, Object?>.from(m as Map)),
      ];
      if (persons.isEmpty || persons.any((x) => x.id == null)) {
        throw const FormatException('no persons');
      }
      return BackupContents(path: path, persons: persons, records: records);
    } on FormatException {
      rethrow;
    } on Object catch (e) {
      debugPrint('バックアップを読めませんでした: $e');
      throw const FormatException('unreadable');
    } finally {
      await input.close();
    }
  }

  /// 今の記録と写真をすべて消して、バックアップの内容に置き換える。
  static Future<void> restore(BackupContents contents) async {
    final repo = RecordRepository.instance;
    final oldPhotos = [for (final r in await repo.allRecords()) ...r.photos];

    // 先に写真を書き出す。途中で失敗しても今の記録は残る。
    final wanted = {for (final r in contents.records) ...r.photos};
    final written = <String>{};
    final input = InputFileStream(contents.path);
    try {
      final archive = ZipDecoder().decodeStream(input);
      for (final file in archive.files) {
        if (!file.isFile || !file.name.startsWith(_photoDir)) continue;
        final name = file.name.substring(_photoDir.length);
        // ファイル名だけを受け付ける（フォルダをまたぐ名前は無視する）。
        if (name.isEmpty ||
            name != p.basename(name) ||
            !wanted.contains(name)) {
          continue;
        }
        final bytes = file.readBytes();
        if (bytes == null) continue;
        await (await PhotoStore.file(name)).writeAsBytes(bytes, flush: true);
        written.add(name);
      }
    } finally {
      await input.close();
    }

    // 写真が入っていなかったページは記録から外す（読み取った文字も合わせて外す）。
    final records = [
      for (final r in contents.records)
        if (r.photos.every(written.contains))
          r
        else
          r.copyWith(
            photos: [
              for (final x in r.photos)
                if (written.contains(x)) x,
            ],
            ocrText: MedRecord.joinOcrPages([
              for (final (i, x) in r.photos.indexed)
                if (written.contains(x)) r.ocrPages[i],
            ]),
          ),
    ];
    final personIds = {for (final x in contents.persons) x.id};
    await repo.replaceAll(contents.persons, [
      for (final r in records)
        if (personIds.contains(r.personId)) r,
    ]);
    await PhotoStore.deleteAll(oldPhotos.where((x) => !written.contains(x)));
  }
}

class BackupContents {
  const BackupContents({
    required this.path,
    required this.persons,
    required this.records,
  });

  final String path;
  final List<Person> persons;
  final List<MedRecord> records;
}
