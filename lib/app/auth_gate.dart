import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart';
import '../view/auth_screen.dart';
import '../view/list_view.dart';
import '../provider/todo_provider.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return const AuthScreen();
        }

        final todosAsync = ref.watch(todoStreamProvider);

        return todosAsync.when(
          data: (todos) => TodosListView(
            todos: todos,
            formatTime: _formatTime,
            onUpdate: (index, updatedTodo) async {
              await ref
                  .read(todoRepositoryProvider)
                  .addOrUpdateTodo(updatedTodo);
            },
          ),
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Scaffold(
            body: Center(child: Text(e.toString())),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text(e.toString())),
      ),
    );
  }
}
