import 'package:flutter/material.dart';
import '../model/todo.dart';
import 'add_todo_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/todo_provider.dart';


class TodoListScreen extends ConsumerWidget {
  const TodoListScreen({super.key});

  String _formatTime(DateTime dt) {
    final hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$hour12:$minute $period';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todoStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Shared TODOs')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        child: const Icon(Icons.add),
        onPressed: () async {
          final newTodo = await showModalBottomSheet<Todo>(
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
            if (newTodo != null) {
    // Trigger a refresh of the stream by invalidating the provider
    ref.refresh(todoStreamProvider);
  }

        },
      ),
      body: todosAsync.when(
        data: (todos) {
          if (todos.isEmpty) {
            return const Center(child: Text('No tasks created yet'));
          }
          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];
              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(todo.title),
                  subtitle: Text(todo.description),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_formatTime(todo.createdAt),
                          style: const TextStyle(fontSize: 12)),
                      Checkbox(
                        value: todo.isCompleted,
                        onChanged: (value) async {
                          final updated = Todo(
                            taskid: todo.taskid,
                            title: todo.title,
                            description: todo.description,
                            isCompleted: value!,
                            createdAt: todo.createdAt,
                            sharedWith: todo.sharedWith,
                          );
                          await ref
                              .read(todoRepositoryProvider)
                              .addOrUpdateTodo(updated);
                        },
                      ),
                    ],
                  ),
                  onTap: () async {
                    final updated = await showModalBottomSheet<Todo>(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => Padding(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.85,
                          child: AddTodoScreen(initialTodo: todo),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
