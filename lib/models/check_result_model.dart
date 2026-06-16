class CheckResult {
  final String? id;
  final String userId;
  final int skor;
  final String status;
  final String analisis;
  final DateTime tanggal;

  CheckResult({
    this.id,
    required this.userId,
    required this.skor,
    required this.status,
    required this.analisis,
    required this.tanggal,
  });

  factory CheckResult.fromMap(Map<String, dynamic> map, String id) {
    return CheckResult(
      id: id,
      userId: map['userId'] ?? '',
      skor: map['skor'] ?? 0,
      status: map['status'] ?? '',
      analisis: map['analisis'] ?? '',
      tanggal: DateTime.fromMillisecondsSinceEpoch(map['tanggal'] ?? 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'skor': skor,
      'status': status,
      'analisis': analisis,
      'tanggal': tanggal.millisecondsSinceEpoch,
    };
  }

  String get tanggalFormatted {
    return '${tanggal.day} ${_bulan(tanggal.month)} ${tanggal.year}';
  }

  String _bulan(int m) {
    const list = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return list[m];
  }
}