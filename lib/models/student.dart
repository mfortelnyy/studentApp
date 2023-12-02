import 'task.dart';
class Student {
  int? id;
  String name;
  String email;
  String password; // Password is hashed
  List<Task>? tasks; // List of tasks associated with the student
  //is null when the student is created

  Student({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.tasks,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    final tasksList = map['tasks'] as List<dynamic>?;
    final tasks = tasksList?.map((taskMap) => Task.fromMap(taskMap)).toList() ?? [];

    return Student(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      tasks: tasks
    );
  }

  void add(Task t){
    tasks?.add(t);
  }
}
