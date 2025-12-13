import 'package:flutter/material.dart';
import 'package:todo_app/view/dashboard_view.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TODO App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TodoListScreen(),
    );
  }
}