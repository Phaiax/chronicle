import 'package:chronicle/main.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class DatabaseHelper {
  static Database? _database;
  static Future<Database>? _databaseInitialization;
  static final DatabaseHelper _instance = DatabaseHelper._privateConstructor();

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _databaseInitialization ??= _initDatabase();
    _database = await _databaseInitialization;
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = p.join((await getApplicationDocumentsDirectory()).path,
        'chronicle', 'chronicle.sqlite');
    logger.i('Database path: $path');
    var databaseFactory = databaseFactoryFfi;
    Database db = await databaseFactory.openDatabase(path);

    final List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT name FROM sqlite_master WHERE type="table" AND name="Meta"',
    );
    if (result.isEmpty) {
      logger.i("Create Database from scratch");
      await _onCreate(db, 0);
    } else {
      final result = await db
          .query('Meta', where: 'key = ?', whereArgs: ['schema_version']);
      final String schemaVersion = result[0]["value"] as String;
      logger.i("Migrate Database version $schemaVersion to $targetVersion");
      _onUpgrade(db, int.parse(schemaVersion), targetVersion);
    }
    return db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Meta (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
    await db.insert('Meta', {'key': 'schema_version', 'value': '1'});
    await db.execute('''
      CREATE TABLE Screenshots (
        id INTEGER PRIMARY KEY,
        time INTEGER,
        mousex REAL,
        mousey REAL,
        screenshotSnippetPath TEXT,
        screenshotFullPath TEXT,
        windowiconPath TEXT,
        activewindow TEXT,
        activewindowId TEXT,
        marked INTEGER
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // This is where you can handle database migrations when schema changes
    int version = oldVersion;
    while (version < newVersion) {
      version++;
      _migrate(db, version);
    }
  }

  static const int targetVersion = 1;

  Future<void> _migrate(Database db, int version) async {
    switch (version) {
      case 2:
        // Example migration for version 2:
        // await db.execute('ALTER TABLE Meta ADD COLUMN new_column TEXT');
        break;
      // Add more cases for future schema versions as needed.
    }
  }

  Future<void> insertScreenshot({
    int? time,
    required num mousex,
    required num mousey,
    required String screenshotSnippetPath,
    required String screenshotFullPath,
    String? windowiconPath,
    String? activewindow,
    String? activewindowId,
    bool marked = false,
  }) async {
    time ??= DateTime.now().millisecondsSinceEpoch;
    // Uint8List screenshotSnippetCompessed = img.encodePng(screenshotSnippet);
    // Uint8List screenshotFullCompessed = img.encodePng(screenshotFull);
    // Uint8List? windowiconCompessed =
    //     (windowicon != null) ? img.encodePng(windowicon) : null;
    final Map<String, dynamic> row = {
      'time': time,
      'mousex': mousex,
      'mousey': mousey,
      'screenshotSnippetPath': screenshotSnippetPath,
      'screenshotFullPath': screenshotFullPath,
      'windowiconPath': windowiconPath,
      'activewindow': activewindow,
      'activewindowId': activewindowId,
      'marked': marked ? 1 : 0,
    };
    final db = await database;
    await db.insert('Screenshots', row);
  }

  Future<List<Map<String, dynamic>>> getScreenshotsByTimeRange(
      int timeStart, int timeEnd) async {
    return await _getScreenshotsBy(
        where: 'time >= ? AND time <= ?', whereArgs: [timeStart, timeEnd]);
  }

  Future<List<Map<String, dynamic>>> getAllScreenshots() async {
    return await _getScreenshotsBy(where: '1', whereArgs: []);
  }

  Future<List<Map<String, dynamic>>> _getScreenshotsBy(
      {required String where, required List<dynamic> whereArgs}) async {
    final db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      'Screenshots',
      where: where,
      whereArgs: whereArgs,
      columns: [
        'id',
        'time',
        'mousex',
        'mousey',
        'activewindow',
        'screenshotSnippetPath',
        'screenshotFullPath',
        'windowiconPath',
        'activewindowId',
        'marked'
      ], // Specify only the columns you want to retrieve
    );

    if (maps.isNotEmpty) {
      // for (Map<String, dynamic> map in maps) {
      // map["screenshotSnippet"] = img.decodePng(map["screenshotSnippet"]);
      // if (map["windowicon"] != null) {
      //   map["windowicon"] = img.decodePng(map["windowicon"]);
      // }
      // map["marked"] = map["marked"] > 0;
      // }
      return maps;
    }

    return [];
  }

  void debugPrintDatabaseScreenshots() async {
    logger.d("Screenshots in database:");
    for (Map<String, dynamic> screenshot in await getAllScreenshots()) {
      logger.d(
          " - x=${screenshot["mousex"]} y=${screenshot["mousey"]} marked=${screenshot["marked"]} full=${screenshot["screenshotFullPath"]}");
    }
  }

  // Future<img.Image?> getScreenshotFull(int id) async {
  //   final db = await database;
  //   List<Map<String, dynamic>> maps = await db.query(
  //     'Screenshots',
  //     where: 'id = ?',
  //     whereArgs: [id],
  //     columns: [
  //       'screenshotFull',
  //     ],
  //   );

  //   if (maps.isNotEmpty) {
  //     return img.decodePng(maps.first['screenshotFull']);
  //   }

  //   return null;
  // }
}
