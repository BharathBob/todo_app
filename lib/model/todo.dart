import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  final String taskid;
  final String title;
  final String description;
  bool isCompleted;
  final DateTime createdAt;
    final List<String> sharedWith; // emails or user IDs


  Todo({
    required this.taskid,
    required this.title,
    required this.description,
    this.isCompleted = false,
    required this.createdAt,
        this.sharedWith = const [],

  });

factory Todo.fromFirestore(Map<String, dynamic> data, String id) {
  return Todo(
    taskid: id,
    title: data['title'],
    description: data['description'],
    isCompleted: data['isCompleted'] ?? false,
    createdAt: (data['createdAt'] as Timestamp).toDate(),
    sharedWith: List<String>.from(data['sharedWith'] ?? []),
  );
}

Map<String, dynamic> toFirestore() {
  return {
    'taskid': taskid,
    'title': title,
    'description': description,
    'isCompleted': isCompleted,
    'createdAt': Timestamp.fromDate(createdAt), // ✅ convert to Timestamp
    'sharedWith': sharedWith,
  };
}
}
