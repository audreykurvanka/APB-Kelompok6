import 'package:firebase_database/firebase_database.dart';
import '../models/check_result_model.dart';

class CheckResultService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final String _node = 'check_results';

  // CREATE
  Future<String> addResult(CheckResult result) async {
    final ref = _db.ref(_node).push();
    await ref.set(result.toMap());
    return ref.key!;
  }

  // READ - stream realtime
  Stream<List<CheckResult>> getResultsStream(String userId) {
    return _db
        .ref(_node)
        .orderByChild('userId')
        .equalTo(userId)
        .onValue
        .map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) return [];
      final map = Map<String, dynamic>.from(event.snapshot.value as Map);
      final list = map.entries
          .map((e) => CheckResult.fromMap(
                Map<String, dynamic>.from(e.value as Map),
                e.key,
              ))
          .toList();
      // Sort by tanggal descending
      list.sort((a, b) => b.tanggal.compareTo(a.tanggal));
      return list;
    });
  }

  // UPDATE
  Future<void> updateResult(CheckResult result) async {
    await _db.ref('$_node/${result.id}').update(result.toMap());
  }

  // DELETE
  Future<void> deleteResult(String id) async {
    await _db.ref('$_node/$id').remove();
  }
}
