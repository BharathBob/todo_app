import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  final String taskid;
  final String title;
  final String description;
  bool isCompleted;
  final DateTime createdAt;
  final List<String> sharedWith; 
  final String creatorId;

  Todo({
    required this.taskid,
    required this.title,
    required this.description,
    this.isCompleted = false,
    required this.createdAt,
    this.sharedWith = const [],
    required this.creatorId,
  });

  factory Todo.fromFirestore(Map<String, dynamic> data, String id) {
    return Todo(
      taskid: id,
      title: data['title'],
      description: data['description'],
      isCompleted: data['isCompleted'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      sharedWith: List<String>.from(data['sharedWith'] ?? []),
      creatorId: data['creatorId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'taskid': taskid,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': Timestamp.fromDate(createdAt),
      'sharedWith': sharedWith,
      'creatorId': creatorId,
    };
  }
}