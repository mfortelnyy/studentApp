import 'dart:math';
import 'package:flutter/material.dart';
import 'package:studentapp/models/student.dart';
import 'package:studentapp/models/task.dart';
import 'package:studentapp/utils/DBHelper.dart';

class TaskGridWidget extends StatefulWidget {
  final List<String> daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<String> timeSlots = [
    '8:00 AM', '9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM', '1:00 PM',
    '2:00 PM', '3:00 PM', '4:00 PM', '5:00 PM', '6:00 PM', '7:00 PM', '8:00 PM'
  ];
 
  final Student student;
  

  

  TaskGridWidget(this.student);

  @override
  _TaskGridWidgetState createState() => _TaskGridWidgetState();
}

class _TaskGridWidgetState extends State<TaskGridWidget> {
  String selectedDay = '';
  String selectedTime = '';
  String taskDescription = '';
  List<Task> tasks = [];
  final DBHelper dbHelper = DBHelper(); 

   @override
  void initState() {
    super.initState();
    // Fetch tasks from the database
    fetchTasks();
  }

  // Function to fetch tasks from the database
  void fetchTasks() async {
    List<Task> fetchedTasks = await dbHelper.queryTasks(widget.student.id);
    setState(() {
      tasks = fetchedTasks;
    });
  }

  // Callback function to update tasks list
  void updateTasksList() async {
    var updTasks = await dbHelper.queryTasks(widget.student.id);;
    setState(()  {
      tasks = updTasks;
    });
  }

  void _showEditTaskDialog(BuildContext context, Task task) {
  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Edit Task'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  value: task.day, 
                  onChanged: (String? newValue) {
                    setState(() {
                      task.day = newValue ?? task.day;
                    });
                  },
                  items: widget.daysOfWeek.map((String day) {
                    return DropdownMenuItem<String>(
                      value: day,
                      child: Text(day),
                    );
                  }).toList(),
                ),
                DropdownButton<String>(
                  value: task.timeSlot,
                  onChanged: (String? newValue) {
                    setState(() {
                      task.timeSlot = newValue ?? task.timeSlot;
                    });
                  },
                  items: widget.timeSlots.map((String time) {
                    return DropdownMenuItem<String>(
                      value: time,
                      child: Text(time),
                    );
                  }).toList(),
                ),
                TextField(
                  onChanged: (value) {
                    task.description = value; 
                  },
                  decoration: InputDecoration(
                    labelText: 'Task Description',
                  ),
                  controller: TextEditingController(text: task.description),
                ),
                DropdownButton<bool>(
                  value: task.isCompleted, 
                  onChanged: (bool? newValue) {
                    setState(() {
                      task.isCompleted = newValue ?? task.isCompleted;
                    });
                  },
                  items: [true, false].map((bool value) {
                    return DropdownMenuItem<bool>(
                      value: value,
                      child: Text(value ? 'Completed' : 'Not Completed'),
                    );
                  }).toList(),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Update'),
                onPressed: () {
                  // Update the task in the database
                  DBHelper().updateTask(task);

                  updateTasksList();
                  Navigator.of(context).pop();
                  setState(() {});
                },
              ),
            ],
          );
        },
      );
    },
  );
}

  

  void _showAddTaskDialog(context) {
    selectedDay = widget.daysOfWeek[0];
    selectedTime = widget.timeSlots[0];
    taskDescription = '';

    

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add New Task'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: selectedDay,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedDay = newValue ?? selectedDay;
                      });
                    },
                    items: widget.daysOfWeek.map((String day) {
                      return DropdownMenuItem<String>(
                        value: day,
                        child: Text(day),
                      );
                    }).toList(),
                  ),
                  DropdownButton<String>(
                    value: selectedTime,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedTime = newValue ?? selectedTime;
                      });
                    },
                    items: widget.timeSlots.map((String time) {
                      return DropdownMenuItem<String>(
                        value: time,
                        child: Text(time),
                      );
                    }).toList(),
                  ),
                  TextField(
                    onChanged: (value) {
                      taskDescription = value;
                    },
                    decoration: InputDecoration(
                      labelText: 'Task Description',
                    ),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Add'),
                  onPressed: () {
                    if (taskDescription.isNotEmpty) {
                      final newTask = Task(
                        day: selectedDay,
                        timeSlot: selectedTime,
                        description: taskDescription,
                        isCompleted: false,
                        studentId: widget.student.id,
                      );
                      DBHelper().insertTask(newTask);
                      updateTasksList(); // Update tasks list 
                      

                      Navigator.of(context).pop();
                      setState(() {
                        
                      }); 
                      
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTaskCell(context, Task task) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Task Details'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Description: ${task.description}'),
                  task.isCompleted ? Text('Status: done') : Text("Status: in progress"),
                  ElevatedButton(
                    onPressed: () {
                      _showEditTaskDialog(context, task);
                      setState(() {
                        
                      });

                    },
                    child: Text('Edit'),
                  ),
                  SizedBox(height: 25,),
     
                  ElevatedButton(
                    onPressed: () {
                      DBHelper().deleteTask(widget.student.id, task.id!);
                      updateTasksList();
                      setState(() {}); 

                      Navigator.of(context).pop();
                    },
                    child: Text('Delete'),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          color: Colors.primaries[Random().nextInt(Colors.primaries.length)][100],
        ),
        child: Text(task.description),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    int totalTasks = tasks.length;
    int completedTasks = tasks.where((task) => task.isCompleted).length;
    double progress = totalTasks != 0 ? completedTasks / totalTasks : 0.0;

  
    
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            _showAddTaskDialog(context);
          },
          child: const Text('Add Task'),
        ),
        Text("Progress"),
        SizedBox(
          height: 20, 
          child: Stack(
            children: <Widget>[
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text('${(progress * 100).toInt()}%'),
                ),
              ),
            ],
          ),
        ),
       
        Expanded(
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.daysOfWeek.length + 1, 
              childAspectRatio: 1.2,
            ),
            itemCount: (widget.timeSlots.length + 1) * (widget.daysOfWeek.length + 1),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Container();
              } else if (index % (widget.daysOfWeek.length + 1) == 0) {
                final timeIndex = (index ~/ (widget.daysOfWeek.length + 1)) - 1;
                return Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  child: Text(widget.timeSlots[timeIndex]),
                );
              } else if (index < widget.daysOfWeek.length + 1) {
                return Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  child: Text(widget.daysOfWeek[index - 1]),
                );
              } else {
                final dayIndex = (index - 1) % widget.daysOfWeek.length;
                final timeIndex = (index - 1) % widget.timeSlots.length;
                final day = widget.daysOfWeek[dayIndex];
                final timeSlot = widget.timeSlots[timeIndex];

                final tasksAtTime = tasks.where((task) =>
                    task.day == day && task.timeSlot == timeSlot);

                return GestureDetector(
                  onTap: () {
                    
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    child: tasksAtTime.isNotEmpty
                        ? _buildTaskCell(context, tasksAtTime.first)
                        : SizedBox(),
                  ),
                );
              }
            },
          ),
          
          
        ),
        Text(
          progress == 0 && tasks.length == 0
            ? "Add a task first to receive feedback"
            : progress >= 0.45&& tasks.length > 0
              ?"You are on the right track! Keep going!"
              : "You have a lot of homework to do! Start early!",
        ), 
        SizedBox(height: 25,)
       ],
    );
  }
}
