import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// 記録の写真の置き場所（アプリの書類フォルダの photos/）。
///
/// 記録にはファイル名だけを持たせる。アプリの更新で書類フォルダの絶対パスが
/// 変わっても読めるようにするため。
class PhotoStore {
  PhotoStore._();

  static Directory? _dir;
  static final _random = Random();

  static Future<Directory> dir() async {
    if (_dir != null) return _dir!;
    final docs = await getApplicationDocumentsDirectory();
    final d = Directory(p.join(docs.path, 'photos'));
    if (!await d.exists()) await d.create(recursive: true);
    return _dir = d;
  }

  /// 起動時に一度呼び、以降は [fileSync] を使えるようにする。
  static Future<void> init() => dir();

  static File fileSync(String name) => File(p.join(_dir!.path, name));

  static Future<File> file(String name) async =>
      File(p.join((await dir()).path, name));

  static String newName([String ext = '.jpg']) =>
      '${DateTime.now().microsecondsSinceEpoch}_'
      '${_random.nextInt(1 << 32).toRadixString(36)}$ext';

  /// 一時ファイル（撮影・取り込み直後）を写真フォルダへ移し、ファイル名を返す。
  static Future<String> adopt(String path) async {
    final ext = p.extension(path).toLowerCase();
    final name = newName(ext.isEmpty ? '.jpg' : ext);
    final target = await file(name);
    final source = File(path);
    try {
      await source.rename(target.path);
    } on FileSystemException {
      await source.copy(target.path);
    }
    return name;
  }

  static Future<void> deleteAll(Iterable<String> names) async {
    for (final name in names) {
      try {
        final f = await file(name);
        if (await f.exists()) await f.delete();
      } on FileSystemException {
        // 消せなくても記録の削除は続ける。
      }
    }
  }
}
