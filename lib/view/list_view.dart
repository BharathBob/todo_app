import 'package:flutter/material.dart';
import '../model/todo.dart';
import '../view/add_todo_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/todo_provider.dart';

class TodosListView extends ConsumerWidget {
  final List<Todo> todos;
  final String Function(DateTime) formatTime;
  final void Function(int index, Todo updated) onUpdate;

  const TodosListView({
    Key? key,
    required this.todos,
    required this.formatTime,
    required this.onUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(todoProvider);
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return Card(
          margin: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          child: ListTile(
            title: Text(todo.title),
            subtitle: Text(todo.description),
            trailing: Text(
              formatTime(todo.createdAt),
              style: const TextStyle(fontSize: 12),
            ),
            onTap: () async {
              final updated = await showModalBottomSheet<Todo>(
                context: context,
                isScrollControlled: true,
                builder: (context) => Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.85,
                    child: AddTodoScreen(initialTodo: todo),
                  ),
                ),
              );
              if (updated != null) {
                onUpdate(index, updated);
              }
            },
          ),
        );
      },
    );
  }
}