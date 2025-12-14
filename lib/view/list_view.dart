import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/todo.dart';
import '../view/add_todo_view.dart';
import '../provider/todo_provider.dart';
import '../auth/auth_controller.dart';

class TodosListView extends ConsumerWidget {
  final List<Todo> todos;
  final String Function(DateTime) formatTime;
  final void Function(int index, Todo updated) onUpdate;

  const TodosListView({
    super.key,
    required this.todos,
    required this.formatTime,
    required this.onUpdate,
  });

  /// Share dialog
  Future<void> _showShareDialog(
    BuildContext context,
    WidgetRef ref,
    Todo todo,
  ) async {
    final controller = TextEditingController();

    final email = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Share Task'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'user@email.com',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, controller.text.trim()),
            child: const Text('Share'),
          ),
        ],
      ),
    );

    if (email == null || email.isEmpty) return;
    if (todo.sharedWith.contains(email)) return;

    final updatedTodo = Todo(
      taskid: todo.taskid,
      title: todo.title,
      description: todo.description,
      createdAt: todo.createdAt,
      creatorId: todo.creatorId,
      sharedWith: [...todo.sharedWith, email],
    );

    await ref
        .read(todoRepositoryProvider)
        .addOrUpdateTodo(updatedTodo);
  }

  /// Add new task
  Future<void> _addTask(BuildContext context, WidgetRef ref) async {
    final todo = await showModalBottomSheet<Todo>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddTodoScreen(),
    );

    // if (todo != null) {
    //   await ref.read(todoRepositoryProvider).addOrUpdateTodo(todo);
    // }
  }

  /// Edit task
  Future<void> _editTask(
    BuildContext context,
    WidgetRef ref,
    Todo todo,
    int index,
  ) async {
    final updated = await showModalBottomSheet<Todo>(
      context: context,
      isScrollControlled: true,
      builder: (_) => AddTodoScreen(initialTodo: todo),
    );

    if (updated != null) {
      onUpdate(index, updated);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Whats Next?'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                ref.read(authControllerProvider.notifier).logout(),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () => _addTask(context, ref),
        child: const Icon(Icons.add),
      ),

      body: todos.isEmpty
          ? const Center(
              child: Text(
                'No tasks yet.\nTap + to add one',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(todo.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(todo.description),
                        const SizedBox(height: 4),
                        Text(
                          formatTime(todo.createdAt),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () =>
                          _showShareDialog(context, ref, todo),
                    ),
                    onTap: () =>
                        _editTask(context, ref, todo, index),
                  ),
                );
              },
            ),
    );
  }
}