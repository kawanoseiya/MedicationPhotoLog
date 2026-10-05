import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/med_record.dart';
import 'photo_store.dart';

/// 記録と家族の保存先（端末内の SQLite）。写真の実体は [PhotoStore]。
class RecordRepository {
  RecordRepository._();

  static final RecordRepository instance = RecordRepository._();

  Database? _db;

  Future<Database> get db async => _db ??= await _open();

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    return openDatabase(
      p.join(dir, 'snapmed.db'),
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE persons(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            sort INTEGER NOT NULL DEFAULT 0
          )''');
        await db.execute('''
          CREATE TABLE records(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            person_id INTEGER NOT NULL,
            prescribed_on TEXT,
            medicines TEXT NOT NULL DEFAULT '',
            hospital TEXT NOT NULL DEFAULT '',
            pharmacy TEXT NOT NULL DEFAULT '',
            memo TEXT NOT NULL DEFAULT '',
            ocr_text TEXT NOT NULL DEFAULT '',
            photos TEXT NOT NULL DEFAULT '',
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )''');
        await db.execute(
          'CREATE INDEX records_person ON records(person_id, prescribed_on)',
        );
      },
    );
  }

  // ---------------------------------------------------------------- 家族

  Future<List<Person>> persons() async {
    final rows = await (await db).query('persons', orderBy: 'sort, id');
    return rows.map(Person.fromMap).toList();
  }

  Future<Person> addPerson(String name) async {
    final d = await db;
    final maxSort =
        Sqflite.firstIntValue(
          await d.rawQuery('SELECT MAX(sort) FROM persons'),
        ) ??
        -1;
    final person = Person(name: name, sort: maxSort + 1);
    final id = await d.insert('persons', person.toMap()..remove('id'));
    return Person(id: id, name: name, sort: person.sort);
  }

  Future<void> renamePerson(int id, String name) async {
    await (await db).update(
      'persons',
      {'name': name},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 家族と、その人の記録・写真をすべて消す。
  Future<void> deletePerson(int id) async {
    final d = await db;
    final records = await recordsFor(id);
    await d.transaction((txn) async {
      await txn.delete('records', where: 'person_id = ?', whereArgs: [id]);
      await txn.delete('persons', where: 'id = ?', whereArgs: [id]);
    });
    for (final r in records) {
      await PhotoStore.deleteAll(r.photos);
    }
  }

  Future<int> countFor(int personId) async =>
      Sqflite.firstIntValue(
        await (await db).rawQuery(
          'SELECT COUNT(*) FROM records WHERE person_id = ?',
          [personId],
        ),
      ) ??
      0;

  // ---------------------------------------------------------------- 記録

  /// 新しい順（処方日、無ければ登録日）。[query] があれば薬名・医療機関・薬局・
  /// メモ・読み取った文字のどれかに含むものだけ。
  Future<List<MedRecord>> recordsFor(
    int personId, {
    String query = '',
    int? limit,
  }) async {
    final where = StringBuffer('person_id = ?');
    final args = <Object?>[personId];
    for (final word in query.trim().split(RegExp(r'\s+'))) {
      if (word.isEmpty) continue;
      final like = '%${_escapeLike(word)}%';
      where.write(
        " AND (medicines LIKE ? ESCAPE '\\' OR hospital LIKE ? ESCAPE '\\'"
        " OR pharmacy LIKE ? ESCAPE '\\' OR memo LIKE ? ESCAPE '\\'"
        " OR ocr_text LIKE ? ESCAPE '\\')",
      );
      args.addAll([like, like, like, like, like]);
    }
    final rows = await (await db).query(
      'records',
      where: where.toString(),
      whereArgs: args,
      orderBy:
          "COALESCE(prescribed_on, substr(created_at, 1, 10)) DESC, id DESC",
      limit: limit,
    );
    return rows.map(MedRecord.fromMap).toList();
  }

  static String _escapeLike(String s) =>
      s.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_');

  Future<MedRecord?> find(int id) async {
    final rows = await (await db).query(
      'records',
      where: 'id = ?',
      whereArgs: [id],
    );
    return rows.isEmpty ? null : MedRecord.fromMap(rows.first);
  }

  Future<int> insert(MedRecord r) async =>
      (await db).insert('records', r.toMap()..remove('id'));

  Future<void> update(MedRecord r) async {
    await (await db).update(
      'records',
      r.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [r.id],
    );
  }

  Future<void> delete(MedRecord r) async {
    await (await db).delete('records', where: 'id = ?', whereArgs: [r.id]);
    await PhotoStore.deleteAll(r.photos);
  }

  // ---------------------------------------------------------------- バックアップ

  Future<List<MedRecord>> allRecords() async {
    final rows = await (await db).query('records', orderBy: 'id');
    return rows.map(MedRecord.fromMap).toList();
  }

  /// すべてを置き換える（復元用）。写真ファイルは呼び出し側で用意しておく。
  Future<void> replaceAll(List<Person> persons, List<MedRecord> records) async {
    final d = await db;
    await d.transaction((txn) async {
      await txn.delete('records');
      await txn.delete('persons');
      for (final person in persons) {
        await txn.insert('persons', person.toMap());
      }
      for (final r in records) {
        await txn.insert('records', r.toMap());
      }
    });
  }
}
