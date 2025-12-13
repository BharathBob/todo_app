import 'package:flutter/material.dart';
import '../model/todo.dart';
import 'add_todo_view.dart';
import '../view/listview.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final List<Todo> _todos = [];

  void _addTodo(Todo todo) {
    setState(() {
      _todos.insert(0, todo);
    });
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$hour12:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Whats Next?')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
        onPressed: () async {
          final todo = await showModalBottomSheet<Todo>(
            context: context,
            isScrollControlled: true,
            builder: (context) => Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.85,
                child: AddTodoScreen(),
              ),
            ),
          );
          if (todo != null) _addTodo(todo);
        },
      ),
      body: _todos.isEmpty
          ? const Center(child: Text('No tasks created yet'))
          : TodosListView(
              todos: _todos,
              formatTime: _formatTime,
              onUpdate: (index, updated) {
                setState(() {
                  _todos[index] = updated as Todo;
                });
              },
            ),
    );
  }
}
