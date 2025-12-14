import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../model/todo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/todo_provider.dart';
import '../auth/auth_controller.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (_, next) {
      next.whenOrNull(
        error: (e, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Login' : 'Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: authState.isLoading
                  ? null
                  : () {
                      final email = emailController.text.trim();
                      final password = passwordController.text.trim();

                      if (isLogin) {
                        ref
                            .read(authControllerProvider.notifier)
                            .login(email, password);
                      } else {
                        ref
                            .read(authControllerProvider.notifier)
                            .register(email, password);
                      }
                    },
              child: Text(isLogin ? 'Login' : 'Sign Up'),
            ),

            TextButton(
              onPressed: () {
                setState(() => isLogin = !isLogin);
              },
              child: Text(
                isLogin
                    ? 'Create new account'
                    : 'Already have an account? Login',
              ),
            ),

            if (authState.isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}