class AppUser {
  final String uid;
  final String email;

  AppUser({
    required this.uid,
    required this.email,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      email: data['email'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
    };
  }
}