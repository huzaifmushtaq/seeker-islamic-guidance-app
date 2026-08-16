import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/quran_ayah.dart';

class QpcQuranRepository {
  static final QpcQuranRepository _instance =
      QpcQuranRepository._internal();

  factory QpcQuranRepository() => _instance;

  QpcQuranRepository._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory =
        await getApplicationDocumentsDirectory();

    final dbPath =
        join(documentsDirectory.path, 'qpc-hafs.db');

    final exists = await File(dbPath).exists();

    if (!exists) {
      final data =
          await rootBundle.load('assets/quran/qpc-hafs.db');

      final bytes =
          data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );

      await File(dbPath).writeAsBytes(
        bytes,
        flush: true,
      );
    }

    return openDatabase(
      dbPath,
      readOnly: true,
    );
  }

  Future<List<QuranAyah>> loadSurah(
    int surah,
  ) async {
    final db = await database;

    final rows = await db.query(
      'verses',
      where: 'surah = ?',
      whereArgs: [surah],
      orderBy: 'ayah ASC',
    );

    return rows
        .map(QuranAyah.fromMap)
        .toList();
  }

  Future<QuranAyah?> getAyah(
    int surah,
    int ayah,
  ) async {
    final db = await database;

    final rows = await db.query(
      'verses',
      where: 'surah = ? AND ayah = ?',
      whereArgs: [surah, ayah],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return QuranAyah.fromMap(rows.first);
  }

  Future<List<QuranAyah>> search(
    String query,
  ) async {
    final db = await database;

    final rows = await db.query(
      'verses',
      where: 'text LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'id ASC',
    );

    return rows
        .map(QuranAyah.fromMap)
        .toList();
  }
}