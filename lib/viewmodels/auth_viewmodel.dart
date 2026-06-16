import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { idle, loading, success, error }

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  AuthStatus _status = AuthStatus.idle;
  String _errorMessage = '';

  UserModel? get user => _user;
  AuthStatus get status => _status;
  String get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;

  AuthViewModel() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser != null && _user == null) {
        // Hanya fetch dari DB kalau _user belum diset (misal app restart)
        _user = await _authService.getUserData(firebaseUser.uid);
      } else if (firebaseUser == null) {
        _user = null;
      }
      notifyListeners();
    });
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String nama,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();
    try {
      _user = await _authService.signUp(
          email: email, password: password, nama: nama);
      _status = AuthStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _parseError(e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();
    try {
      _user = await _authService.signIn(email: email, password: password);
      _status = AuthStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = _parseError(e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _status = AuthStatus.idle;
    notifyListeners();
  }

  Future<void> updateProfile(UserModel model) async {
    await _authService.updateProfile(model);
    _user = model;
    notifyListeners();
  }

  void resetStatus() {
    _status = AuthStatus.idle;
    _errorMessage = '';
    notifyListeners();
  }

  String _parseError(String raw) {
    if (raw.contains('email-already-in-use')) return 'Email sudah terdaftar.';
    if (raw.contains('wrong-password')) return 'Password salah.';
    if (raw.contains('user-not-found')) return 'Akun tidak ditemukan.';
    if (raw.contains('weak-password')) return 'Password minimal 6 karakter.';
    if (raw.contains('invalid-email')) return 'Format email tidak valid.';
    return 'Terjadi kesalahan. Coba lagi.';
  }
}
