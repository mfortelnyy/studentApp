
class Task {
  int? id;
  int? studentId; // Foreign key to associate with a student
  String description;
  String day;
  String timeSlot;
  bool isCompleted=false;

  Task({this.id, required this.studentId,required this.description,required this.day,required this.timeSlot, required this.isCompleted});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'description': description,
      'day': day,
      'timeSlot': timeSlot,
      'isCompleted': isCompleted ? 1 : 0
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      studentId: map['studentId'],
      description: map['description'],
      day: map['day'],
      timeSlot: map['timeSlot'],
      isCompleted: map['isCompleted'] == 1,
    );
  }
}
