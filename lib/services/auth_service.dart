import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserModel?> signUp({
  required String email,
  required String password,
  required String nama,
}) async {
  final cred = await _auth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );
  final user = cred.user!;
  print('AUTH OK, uid: ${user.uid}'); // ← tambah
  final model = UserModel(uid: user.uid, nama: nama, email: email);
  try {
    await _db.ref('users/${user.uid}').set(model.toMap());
    print('DB OK'); // ← tambah
  } catch (e) {
    print('DB ERROR: $e'); // ← tambah
  }
  return model;
}

  Future<UserModel?> signIn({
  required String email,
  required String password,
}) async {
  final cred = await _auth.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
  final uid = cred.user!.uid;
  print('SIGN IN AUTH OK, uid: $uid');
  try {
    final snap = await _db.ref('users/$uid').get();
    print('SNAP EXISTS: ${snap.exists}, VALUE: ${snap.value}');
    if (snap.exists && snap.value != null) {
      return UserModel.fromMap(
        Map<String, dynamic>.from(snap.value as Map),
        uid,
      );
    }
    // Kalau data user tidak ada di DB, tetap return model minimal
    return UserModel(uid: uid, nama: email.split('@')[0], email: email);
  } catch (e) {
    print('SIGN IN DB ERROR: $e');
    // Tetap return user walau DB gagal
    return UserModel(uid: uid, nama: email.split('@')[0], email: email);
  }
}

  Future<void> signOut() => _auth.signOut();

  Future<UserModel?> getUserData(String uid) async {
    final snap = await _db.ref('users/$uid').get();
    if (snap.exists) {
      return UserModel.fromMap(
        Map<String, dynamic>.from(snap.value as Map),
        uid,
      );
    }
    return null;
  }

  Future<void> updateProfile(UserModel model) async {
    await _db.ref('users/${model.uid}').update(model.toMap());
  }
}