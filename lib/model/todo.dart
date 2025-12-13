
class Todo {
  
  final String taskid;
  final String title;
  final String description;
  bool isCompleted;
  final DateTime createdAt;

  Todo({
    required this.taskid,
    required this.title,
    required this.description,
    this.isCompleted = false,
    required this.createdAt,
  });
}