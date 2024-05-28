import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:film_management/model/movie.dart';

class MovieDatabase{
  static final MovieDatabase instance = MovieDatabase._init();

  static Database? _database;

  MovieDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('notes.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const boolType = 'BOOLEAN NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
    CREATE TABLE $tableMovie ( 
      ${MovieFields.id} $idType, 
      ${MovieFields.isImportant} $boolType,
      ${MovieFields.title} $textType,
      ${MovieFields.description} $textType,
      ${MovieFields.image} $textType,
      ${MovieFields.time} $textType
      )
    ''');
  }

  Future<Movie> create(Movie movie) async {
    final db = await instance.database;

    // final json = note.toJson();
    // final columns = '${NoteFields.title}, ${NoteFields.description}, ${NoteFields.time}';
    // final values = '${json[NoteFields.title]}, ${json[NoteFields.description]}, ${json[NoteFields.time]}';
    // final id = await db.rawInsert('INSERT INTO ($tableNotes) ($columns) VALUES ($values)');

    final id = await db.insert(tableMovie, movie.toJson());
    return movie.copy(id: id);
  }

  Future<Movie> readMovie(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableMovie,
      columns: MovieFields.values,
      where: '${MovieFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Movie.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Movie>> readAllMovie() async {
    final db = await instance.database;

    const orderBy = '${MovieFields.time} ASC';

    final result = await db.query(tableMovie, orderBy: orderBy);

    return result.map((json) => Movie.fromJson(json)).toList();
  }

  Future<int> update(Movie movie) async {
    final db = await instance.database;

    return db.update(
      tableMovie,
      movie.toJson(),
      where: '${MovieFields.id} = ?',
      whereArgs: [movie.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableMovie,
      where: '${MovieFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}