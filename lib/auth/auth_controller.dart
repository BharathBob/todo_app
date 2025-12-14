import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_repository.dart';
import 'auth_providers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<User?>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthController(repo);
});

class AuthController extends StateNotifier<AsyncValue<User?>> {
  final AuthRepository _repo;

  AuthController(this._repo) : super(const AsyncLoading()) {
    _repo.authStateChanges().listen((user) {
      // 1ï¸âƒ£ Update UI immediately
      state = AsyncData(user);

      // 2ï¸âƒ£ Save user in background
      if (user != null) {
        _saveUser(user);
      }
    });
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    try {
      await _repo.signIn(email, password);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> register(String email, String password) async {
    state = const AsyncLoading();
    try {
      await _repo.signUp(email, password);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> logout() async {
    await _repo.signOut();
  }

  Future<void> _saveUser(User user) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set(
      {
        'email': user.email,
      },
      SetOptions(merge: true),
    );
  }
}