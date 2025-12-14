import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/todo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  final firestore = FirebaseFirestore.instance;

  try {
    firestore.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } on FirebaseException catch (e) {
     if (e.code == 'failed-precondition' || e.code == 'unimplemented') {
     } else {
      rethrow;
    }
  } catch (_) {
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
  print("addOrUpdateTodo called");

  await firestore
      .collection('todos')
      .doc(todo.taskid)
      .set(
        todo.toFirestore(),
        SetOptions(merge: true),
      );
}

Stream<List<Todo>> todosForUser(String userId) {
  return firestore
      .collection('todos')
      .where('sharedWithUids', arrayContains: userId)
      .snapshots()
      .map((snapshot) {
        final list = snapshot.docs
            .map((doc) => Todo.fromFirestore(doc.data(), doc.id))
            .toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      });
}
}

final todoStreamProvider = StreamProvider<List<Todo>>((ref) {
  final repository = ref.watch(todoRepositoryProvider);
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) return const Stream.empty();

  print('UID: ${user.uid}');
  return repository.todosForUser(user.uid);
});
