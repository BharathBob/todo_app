import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/todo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  final firestore = FirebaseFirestore.instance;

  try {
    firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } on FirebaseException catch (e) {
    // 'failed-precondition' -> multiple tabs; 'unimplemented' -> browser doesn't support persistence
    if (e.code == 'failed-precondition' || e.code == 'unimplemented') {
      // fallback: continue without persistence (allowed)
    } else {
      rethrow;
    }
  } catch (_) {
    // ignore any other persistence errors and continue
  }

  return firestore;
});

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return TodoRepository(firestore);
});

class TodoRepository {
  final FirebaseFirestore firestore;
  TodoRepository(this.firestore);

  Future<void> addOrUpdateTodo(Todo todo) async {
    await firestore.collection('todos').doc(todo.taskid).set(todo.toFirestore());
  }

Stream<List<Todo>> todosForUser(String userEmail) {
  return firestore
      .collection('todos')
      .where('sharedWith', arrayContains: userEmail)
      .snapshots()
      .map((snapshot) {
        final list = snapshot.docs
            .map((doc) => Todo.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
            .toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      });
}}

final todoStreamProvider = StreamProvider<List<Todo>>((ref) {
  final repository = ref.watch(todoRepositoryProvider);
  final currentUserEmail = 'bharath.viswa1@gmail.com'; 
  return repository.todosForUser(currentUserEmail).handleError((e, st) {
    print('Firestore error: $e');
    return [];
  });
});