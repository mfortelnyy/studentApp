import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:studentapp/models/student.dart';
import 'package:studentapp/models/task.dart';

class DBHelper {
  static const String _databaseName = 'studentApp.db';
  static const int _databaseVersion = 1;

  DBHelper._();
  static final DBHelper _singleton = DBHelper._();

  factory DBHelper() => _singleton;

  Database? _database;

  get db async {
    _database ??= await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    var dbDir = await getApplicationDocumentsDirectory();
    var dbPath = path.join(dbDir.path, _databaseName);

    var db = await openDatabase(
      dbPath,
      version: _databaseVersion,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE students(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT,
            password TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE tasks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            studentId INTEGER,
            description TEXT,
            day TEXT,
            timeSlot TEXT,
            isCompleted INTEGER,
            FOREIGN KEY (studentId) REFERENCES students(id)
          )
        ''');
      },
    );

    return db;
  }

  Future<int> insertStudent(Student student) async {
    final db = await this.db;
    return db.insert('students', student.toMap());
  }

  Future<int> insertTask(Task task) async {
    final db = await this.db;
    return db.insert('tasks', task.toMap());
  }

  Future<List<Student>> queryStudents() async {
    final db = await this.db;
    final List<Map<String, dynamic>> maps = await db.query('students');
    return List.generate(maps.length, (i) {
      return Student(
        id: maps[i]['id'],
        name: maps[i]['name'],
        email: maps[i]['email'],
        password: maps[i]['password'],
      );
    });
  }

  Future<List<Task>> queryTasks(int? studentId) async {
    final db = await this.db;
    final List<Map<String, dynamic>> maps = await db.query('tasks', where: 'studentId = ?', whereArgs: [studentId]);
    return List.generate(maps.length, (i) {
      return Task(
        id: maps[i]['id'],
        studentId: maps[i]['studentId'],
        description: maps[i]['description'],
        day: maps[i]['day'],
        timeSlot: maps[i]['timeSlot'],
        isCompleted: maps[i]["isCompleted"] == 1
      );
    });
  }

  Future<Student?> getUserByEmail(String email) async {
    final db = await this.db;
    final List<Map<String, dynamic>> maps = await db.query(
      'students',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isEmpty) {
      return null; // No user with the specified email found
    }

    return Student.fromMap(maps.first);
  }

  Future<int> insertTaskForStudent(Task task, int studentId) async {
  final db = await this.db;
  final taskWithStudentId = {...task.toMap(), 'studentId': studentId};
  return db.insert('tasks', taskWithStudentId);
}

Future<void> deleteTask(int? studentid, int taskid) async {
  final db = await this.db;
  await db.delete(
    'tasks',
    where: 'id = ? AND studentid = ?',
    whereArgs: [taskid, studentid],
  );
  
}

 Future<void> updateTask(Task task) async {
    final db = await this.db;
    await db.update(
      'tasks',
      task.toMap(), 
      where: 'id = ?', 
      whereArgs: [task.id], 
    );
  }

  
}
