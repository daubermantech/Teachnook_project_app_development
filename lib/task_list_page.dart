import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

enum TaskPriority { High, Medium, Low }

void main() {
  tzdata.initializeTimeZones();
  runApp(const LoginApp());
}

class LoginApp extends StatelessWidget {
  const LoginApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late SharedPreferences _prefs;

  Future<void> _login(BuildContext context) async {
    String username = _usernameController.text;
    String password = _passwordController.text;

    // Perform login authentication logic here (e.g., check username and password).
    // For simplicity, let's assume a successful login for now.
    bool isAuthenticated = true;

    if (isAuthenticated) {
      // Store the login details securely.
      await _prefs.setString('username', username);

      // Navigate to the CRUD operations page.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TaskListPage(
            username: username,
          ),
        ),
      );
    } else {
      // Handle authentication failure (e.g., show an error message).
    }
  }

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _prefs = prefs;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Page"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: "Username"),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Password"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await _login(context);
                },
                child: const Text("Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskListPage extends StatefulWidget {
  final String username;

  const TaskListPage({Key? key, required this.username}) : super(key: key);

  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  List<Task> tasks = [];
  TextEditingController _taskTitleController = TextEditingController();
  TextEditingController _taskDescriptionController = TextEditingController();
  TextEditingController _labelController = TextEditingController();
  TextEditingController _dueDateController = TextEditingController();
  TextEditingController _reminderTimeController = TextEditingController();
  late SharedPreferences _prefs;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  TaskPriority _selectedPriority = TaskPriority.Medium; // Default priority

  void _showPriorityPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Priority"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("High"),
                onTap: () {
                  setState(() {
                    _selectedPriority = TaskPriority.High;
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text("Medium"),
                onTap: () {
                  setState(() {
                    _selectedPriority = TaskPriority.Medium;
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                title: const Text("Low"),
                onTap: () {
                  setState(() {
                    _selectedPriority = TaskPriority.Low;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _prefs = prefs;
      });
      _loadTasks();
    });

    var initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _loadTasks() async {
    List<String>? taskList = _prefs.getStringList(widget.username);
    if (taskList != null) {
      setState(() {
        tasks = taskList.map((taskString) {
          List<String> taskParts = taskString.split('|');
          DateTime? dueDate = DateTime.tryParse(taskParts[4]);
          TimeOfDay? reminderTime = _parseTimeOfDay(taskParts[5]);

          // Parse the priority from the stored data
          TaskPriority priority = _parsePriority(taskParts[6]);

          return Task(
            id: int.parse(taskParts[0]),
            title: taskParts[1],
            description: taskParts[2],
            isCompleted: taskParts[3] == 'true',
            dueDate: dueDate,
            reminderTime: reminderTime,
            labels: taskParts[7].split(','), // Update the index to match your data
            priority: priority, // Assign the parsed priority
          );
        }).toList();
      });
    }
  }

  Future<void> _saveTasks() async {
    List<String> taskList = tasks.map((task) {
      String dueDateStr = task.dueDate != null
          ? DateFormat('yyyy-MM-dd').format(task.dueDate!)
          : '';
      String reminderTimeStr = task.reminderTime != null
          ? '${task.reminderTime!.hour}:${task.reminderTime!.minute}'
          : '';
      String priorityStr = task.priority.toString(); // Store priority as a string

      return '${task.id}|${task.title}|${task.description}|${task.isCompleted}|$dueDateStr|$reminderTimeStr|$priorityStr|${task.labels.join(",")}';
    }).toList();

    await _prefs.setStringList(widget.username, taskList);
  }

  void _createTask() {
    String title = _taskTitleController.text;
    String description = _taskDescriptionController.text;
    String labelsText = _labelController.text;
    List<String> labels = labelsText.split(',').map((e) => e.trim()).toList();

    TimeOfDay? selectedTime = _parseTimeOfDay(_reminderTimeController.text);

    setState(() {
      tasks.add(Task(
        id: tasks.length + 1,
        title: title,
        description: description,
        labels: labels,
        dueDate: _selectedDate, // Assign the selected date here
        reminderTime: selectedTime,
        priority: _selectedPriority, // Assign the selected priority
        isCompleted: false, // Set isCompleted to false by default
      ));
    });

    // Clear other text controllers
    _taskTitleController.clear();
    _taskDescriptionController.clear();
    _labelController.clear();
    _dueDateController.clear();
    _reminderTimeController.clear();

    _saveTasks();

    // Schedule the task's reminder if dueDate and reminderTime are provided
    if (_selectedDate != null && selectedTime != null) {
      _scheduleTaskReminder(
        id: tasks.length,
        title: title,
        dueDate: _selectedDate!,
        reminderTime: selectedTime,
      );
    }
  }

  TaskPriority _parsePriority(String priorityStr) {
    // Parse the priority from a string to an enum
    if (priorityStr == 'TaskPriority.High') {
      return TaskPriority.High;
    } else if (priorityStr == 'TaskPriority.Low') {
      return TaskPriority.Low;
    } else {
      return TaskPriority.Medium; // Default to Medium if not recognized
    }
  }

  TimeOfDay? _parseTimeOfDay(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) {
      return null;
    }

    final parts = timeStr.split(':');
    if (parts.length == 2) {
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);
      if (hour != null && minute != null) {
        return TimeOfDay(hour: hour, minute: minute);
      }
    }
    return null;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = (await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    ))!;

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dueDateController.text =
            DateFormat('yyyy-MM-dd').format(_selectedDate!);
      });
    }
  }

  Future<void> _scheduleTaskReminder({
    required int id,
    required String title,
    required DateTime dueDate,
    required TimeOfDay reminderTime,
  }) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      channelShowBadge: true,
    );
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    final now = DateTime.now();
    final scheduledDate = tz.TZDateTime(
      tz.local,
      dueDate.year,
      dueDate.month,
      dueDate.day,
      reminderTime.hour,
      reminderTime.minute,
    );

    if (scheduledDate.isAfter(now)) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        'Task due soon',
        scheduledDate,
        platformChannelSpecifics,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true,
      );
    }
  }

  DateTime? _selectedDate; // Variable to store the selected due date
  TimeOfDay? _selectedTime; // Variable to store the selected reminder time

  void _showReminderTimePicker(BuildContext context) {
    showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    ).then((pickedTime) {
      if (pickedTime != null) {
        setState(() {
          _selectedTime = pickedTime;
          _reminderTimeController.text = _formatTimeOfDay(_selectedTime!);
        });
      }
    });
  }

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    return DateFormat.Hm().format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Add a theme based on a condition, for example, a dark theme
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Task List"),
          actions: [
            // Add a toggle button to switch between light and dark themes
            IconButton(
              icon: Icon(_isDarkMode ? Icons.brightness_7 : Icons.brightness_3),
              onPressed: () {
                setState(() {
                  _isDarkMode = !_isDarkMode;
                });
              },
            ),
          ],
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: _filterTasks,
                decoration: InputDecoration(
                  labelText: "Search by Title",
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  TextEditingController _editingTitleController =
                  TextEditingController(text: task.title);
                  TextEditingController _editingDescriptionController =
                  TextEditingController(text: task.description);
                  TextEditingController _editingLabelController =
                  TextEditingController(text: task.labels.join(', '));
                  TextEditingController _editingDueDateController =
                  TextEditingController(
                      text: task.dueDate != null
                          ? DateFormat('yyyy-MM-dd').format(task.dueDate!)
                          : '');
                  TextEditingController _editingReminderTimeController =
                  TextEditingController(
                      text: task.reminderTime != null
                          ? _formatTimeOfDay(task.reminderTime!)
                          : '');
                  TextEditingController _editingPriorityController =
                  TextEditingController(text: task.priority.toString());

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    elevation: 2.0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Wrap(
                                spacing: 8,
                                children: task.labels.asMap().entries.map((entry) {
                                  int labelIndex = entry.key + 1;
                                  String label = entry.value;
                                  return Chip(
                                    label: Text("($labelIndex. $label)"),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextFormField(
                                      controller: _editingTitleController,
                                      decoration:
                                      const InputDecoration(labelText: "Title"),
                                    ),
                                    TextFormField(
                                      controller: _editingDescriptionController,
                                      decoration: const InputDecoration(
                                          labelText: "Description"),
                                    ),
                                    TextFormField(
                                      controller: _editingLabelController,
                                      decoration: const InputDecoration(
                                          labelText: "Labels (comma-separated)"),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller:
                                            _editingDueDateController,
                                            decoration: const InputDecoration(
                                                labelText: "Due Date (yyyy-MM-dd)"),
                                            onTap: () {
                                              _selectDate(
                                                  context); // Trigger date picker
                                            },
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.calendar_today),
                                          onPressed: () {
                                            _selectDate(context);
                                          },
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller:
                                            _editingReminderTimeController,
                                            decoration: const InputDecoration(
                                                labelText: "Reminder Time (HH:mm)"),
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.access_time),
                                          onPressed: () {
                                            _showReminderTimePicker(context);
                                          },
                                        ),
                                      ],
                                    ),
                                    TextFormField(
                                      controller: _editingPriorityController,
                                      decoration:
                                      const InputDecoration(labelText: "Priority"),
                                      onTap: () {
                                        _showPriorityPicker(context);
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Checkbox(
                                value: task.isCompleted,
                                onChanged: (newValue) {
                                  setState(() {
                                    task.isCompleted = newValue!;
                                  });
                                  _saveTasks();
                                },
                              ),
                              Text("Completed"),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: const Icon(Icons.check),
                                onPressed: () {
                                  task.title = _editingTitleController.text;
                                  task.description =
                                      _editingDescriptionController.text;
                                  task.labels = _editingLabelController.text
                                      .split(',')
                                      .map((e) => e.trim())
                                      .toList();

                                  // Update the priority based on the selected value
                                  task.priority = _selectedPriority;

                                  _saveTasks();
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () {
                                  setState(() {
                                    tasks.remove(task);
                                  });
                                  _saveTasks();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Add a Task"),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _taskTitleController,
                          decoration: const InputDecoration(labelText: "Title"),
                        ),
                        TextFormField(
                          controller: _taskDescriptionController,
                          decoration: const InputDecoration(
                              labelText: "Description"),
                        ),
                        TextFormField(
                          controller: _labelController,
                          decoration: const InputDecoration(
                              labelText: "Labels (comma-separated)"),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _dueDateController,
                                decoration: const InputDecoration(
                                    labelText: "Due Date (yyyy-MM-dd)"),
                                onTap: () {
                                  _selectDate(context); // Trigger date picker
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () {
                                _selectDate(context);
                              },
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _reminderTimeController,
                                decoration: const InputDecoration(
                                    labelText: "Reminder Time (HH:mm)"),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.access_time),
                              onPressed: () {
                                _showReminderTimePicker(context);
                              },
                            ),
                          ],
                        ),
                        DropdownButtonFormField<TaskPriority>(
                          value: _selectedPriority,
                          items: TaskPriority.values
                              .map((priority) =>
                              DropdownMenuItem<TaskPriority>(
                                value: priority,
                                child: Text(priority.toString().split('.').last),
                              ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPriority = value!;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: "Priority",
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () {
                        _createTask();
                        Navigator.of(context).pop();
                      },
                      child: const Text("Add"),
                    ),
                  ],
                );
              },
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  bool _isDarkMode = false;

  void _filterTasks(String query) {
    setState(() {
      if (query.isEmpty) {
        _loadTasks();
      } else {
        tasks = tasks
            .where((task) => task.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }
}

class Task {
  int id;
  String title;
  String description;
  bool isCompleted;
  DateTime? dueDate;
  TimeOfDay? reminderTime;
  List<String> labels;
  TaskPriority priority;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.dueDate,
    required this.reminderTime,
    required this.labels,
    required this.priority,
  });
}


