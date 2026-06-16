import 'package:flutter/material.dart';
import 'dart:async';
import '../models/check_result_model.dart';
import '../services/check_result_service.dart';

enum CrudStatus { idle, loading, success, error }

class CheckResultViewModel extends ChangeNotifier {
  final CheckResultService _service = CheckResultService();

  List<CheckResult> _results = [];
  CrudStatus _status = CrudStatus.idle;
  String _errorMessage = '';

  List<CheckResult> get results => _results;
  CrudStatus get status => _status;
  String get errorMessage => _errorMessage;

  CheckResult? get latestResult => _results.isNotEmpty ? _results.first : null;

  // Load hasil milik user (realtime stream)
  StreamSubscription? _subscription;

  void listenResults(String userId) {
    _subscription?.cancel(); // cancel stream lama dulu
    _subscription = _service.getResultsStream(userId).listen((data) {
      _results = data;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  // CREATE
  Future<bool> addResult({
    required String userId,
    required int skor,
  }) async {
    _status = CrudStatus.loading;
    notifyListeners();
    try {
      final status = _getStatus(skor);
      final analisis = _getAnalisis(skor);
      final result = CheckResult(
        userId: userId,
        skor: skor,
        status: status,
        analisis: analisis,
        tanggal: DateTime.now(),
      );
      await _service.addResult(result);
      _status = CrudStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _status = CrudStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // UPDATE
  Future<bool> updateResult(CheckResult result) async {
    _status = CrudStatus.loading;
    notifyListeners();
    try {
      await _service.updateResult(result);
      _status = CrudStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _status = CrudStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // DELETE
  Future<bool> deleteResult(String id) async {
    _status = CrudStatus.loading;
    notifyListeners();
    try {
      await _service.deleteResult(id);
      _status = CrudStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _status = CrudStatus.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  String _getStatus(int skor) {
    if (skor < 30) return 'Normal';
    if (skor < 60) return 'Anomali Ringan';
    return 'Risiko Tinggi';
  }

  String _getAnalisis(int skor) {
    if (skor < 30) {
      return 'Pola suara respirasi dalam batas normal. Tidak ditemukan anomali signifikan.';
    } else if (skor < 60) {
      return 'Ditemukan pola suara yang tidak konsisten pada beberapa segmen rekaman.';
    }
    return 'Terdapat frekuensi abnormal yang signifikan. Disarankan konsultasi ke dokter.';
  }
}
