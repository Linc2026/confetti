import 'dart:convert';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../utils/index.dart';
import 'db_confetti_entity.dart';
class ConfettiDatabase extends GetxService {
  static const String _tablePreference = 'app_preference';
  static const int _quoteCount = 30;
  late Database _db;
  Future<ConfettiDatabase> init() async {
    final dbPath = join(await getDatabasesPath(), 'confetti.db');
    _db = await openDatabase(
      dbPath,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return this;
  }
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tablePreference (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        shred_mode TEXT NOT NULL,
        quote_order TEXT NOT NULL,
        quote_index INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        last_countdown_minutes INTEGER NOT NULL DEFAULT 3,
        countdown_completions INTEGER NOT NULL DEFAULT 0,
        last_theme_id TEXT NOT NULL DEFAULT '',
        last_release_date TEXT NOT NULL DEFAULT '',
        last_tool_id TEXT NOT NULL DEFAULT '',
        last_open_date TEXT NOT NULL DEFAULT ''
      )
    ''');
    final createdAt = getDateString(DateTime.now());
    final order = List<int>.generate(_quoteCount, (i) => i)..shuffle();
    await db.insert(_tablePreference, {
      'shred_mode': ConfettiShredMode.physicalDegradation,
      'quote_order': jsonEncode(order),
      'quote_index': 0,
      'created_at': createdAt,
      'last_countdown_minutes': 3,
      'countdown_completions': 0,
      'last_theme_id': '',
      'last_release_date': '',
      'last_tool_id': '',
      'last_open_date': '',
    });
  }
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS theme_status');
    }
    if (oldVersion < 3) {
      await db.execute(
        'ALTER TABLE $_tablePreference ADD COLUMN last_countdown_minutes INTEGER NOT NULL DEFAULT 3',
      );
      await db.execute(
        'ALTER TABLE $_tablePreference ADD COLUMN countdown_completions INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (oldVersion < 4) {
      await db.execute(
        "ALTER TABLE $_tablePreference ADD COLUMN last_theme_id TEXT NOT NULL DEFAULT 'crispyBlank'",
      );
      await db.execute(
        "ALTER TABLE $_tablePreference ADD COLUMN last_release_date TEXT NOT NULL DEFAULT ''",
      );
      await db.execute(
        "ALTER TABLE $_tablePreference ADD COLUMN last_tool_id TEXT NOT NULL DEFAULT ''",
      );
      await db.execute(
        "ALTER TABLE $_tablePreference ADD COLUMN last_open_date TEXT NOT NULL DEFAULT ''",
      );
    }
  }
  Future<void> markRelease(String toolId) async {
    try {
      final pref = await getPreference();
      if (pref == null) return;
      await updatePreference(
        pref.copyWith(
          lastReleaseDate: getDateString(DateTime.now()),
          lastToolId: toolId,
        ),
      );
    } catch (_) {
      errorToast('Could not save release record.');
    }
  }
  Future<ConfettiPreference?> getPreference() async {
    try {
      final maps = await _db.query(
        _tablePreference,
        orderBy: 'created_at DESC, id DESC',
        limit: 1,
      );
      if (maps.isEmpty) return null;
      return ConfettiPreference.fromMap(maps.first);
    } catch (e) {
      return null;
    }
  }
  Future<int> updatePreference(ConfettiPreference data) async {
    try {
      return await _db.update(
        _tablePreference,
        data.toMap(),
        where: 'id = ?',
        whereArgs: [data.id],
      );
    } catch (e) {
      return 0;
    }
  }
}
