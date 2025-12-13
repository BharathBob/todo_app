import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../model/todo.dart';

class AddTodoScreen extends StatefulWidget {
  final Todo? initialTodo;
  const AddTodoScreen({super.key, this.initialTodo});

  @override
  State<AddTodoScreen> createState() => _AddTodoScreenState();
}

class _AddTodoScreenState extends State<AddTodoScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialTodo != null) {
      _titleController.text = widget.initialTodo!.title;
      _descriptionController.text = widget.initialTodo!.description;
    }
  }

  void _saveTodo() {
    if (_titleController.text.isEmpty) return;

    final todo = Todo(
      taskid: widget.initialTodo?.taskid ?? const Uuid().v4(),
      title: _titleController.text,
      description: _descriptionController.text,
      isCompleted: widget.initialTodo?.isCompleted ?? false,
      createdAt: widget.initialTodo?.createdAt ?? DateTime.now(),
    );

    Navigator.pop(context, todo);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialTodo != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit TODO' : 'Add TODO')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'What you want to do?'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Add more details...'),
              maxLines: 3,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                onPressed: _saveTodo,
                child: Text(isEditing ? 'Save' : 'Create Todo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}