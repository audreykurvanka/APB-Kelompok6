import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/check_result_viewmodel.dart';
import 'home_screen.dart';

class ResultScreen extends StatelessWidget {
  final int skor;
  const ResultScreen({super.key, required this.skor});

  String get _status {
    if (skor < 30) return 'Normal';
    if (skor < 60) return 'Anomali Ringan';
    return 'Risiko Tinggi';
  }

  Color get _statusColor {
    if (skor < 30) return const Color(0xFF3B9EFF);
    if (skor < 60) return const Color(0xFFFFB300);
    return const Color(0xFFE53935);
  }

  String get _analisis {
    if (skor < 30) return 'Pola suara respirasi dalam batas normal. Tidak ditemukan anomali signifikan pada rekaman fonetik Anda.';
    if (skor < 60) return 'Ditemukan pola suara yang kurang konsisten pada beberapa bagian rekaman. Pengguna disarankan melakukan pemeriksaan ulang.';
    return 'Terdapat indikasi perubahan suara yang cukup signifikan pada rekaman. Pengguna disarankan melakukan pemeriksaan lanjutan ke tenaga kesehatan.';
  }

  String get _saran1 {
    if (skor < 30) return 'Pertahankan gaya hidup sehat dan lakukan pemeriksaan rutin setiap 2 minggu.';
    if (skor < 60) return 'Disarankan untuk memantau ulang dalam 2 hari ke depan.';
    return 'Segera hubungi fasilitas kesehatan terdekat untuk pemeriksaan lanjut.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.chevron_left, size: 32, color: Color(0xFF1A1A2E)),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Hasil Pemeriksaan Hari Ini',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
              const SizedBox(height: 20),

              const Text('Skor Risiko Respirasi',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
              const SizedBox(height: 12),

              // Score card
              Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: skor < 30
                        ? [const Color(0xFF5BB8FF), const Color(0xFF2176D9)]
                        : skor < 60
                            ? [const Color(0xFFFFD54F), const Color(0xFFFF8F00)]
                            : [const Color(0xFFEF5350), const Color(0xFFB71C1C)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20, bottom: -20,
                      child: Container(
                        width: 120, height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nilai Anda',
                              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text('$skor',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 64,
                                      fontWeight: FontWeight.bold, height: 1)),
                              const SizedBox(width: 4),
                              Text('/100',
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.85),
                                      fontSize: 22, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          const Spacer(),
                          Text('Status: $_status',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Keterangan
              const Text('Keterangan',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF3B9EFF))),
              const SizedBox(height: 10),
              _legendRow(const Color(0xFF3B9EFF), '0 – 29', 'Normal', const Color(0xFF3B9EFF)),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              _legendRow(const Color(0xFFFFB300), '30 – 59', 'Anomali Ringan', const Color(0xFFFFB300)),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              _legendRow(const Color(0xFFE53935), '60 – 100', 'Risiko Tinggi', const Color(0xFFE53935)),
              const SizedBox(height: 24),

              // Analisis
              const Text('Analisis Rekaman Suara',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
              const SizedBox(height: 8),
              Text(_analisis,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF555555), height: 1.6)),
              const SizedBox(height: 24),

              // Saran
              const Text('Saran Tindak Lanjut',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
              const SizedBox(height: 10),
              _adviceCard(Icons.replay_outlined, _saran1),
              const SizedBox(height: 10),
              _adviceCard(Icons.local_hospital_outlined,
                  'Jika gejala memburuk, hubungi fasilitas kesehatan terdekat'),
              const SizedBox(height: 28),

              // Tombol aksi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _actionBtn('Periksa ulang', onTap: () => Navigator.pop(context)),
                  _actionBtn('Simpan hasil', onTap: () async {
                    final uid = context.read<AuthViewModel>().user?.uid;
                    if (uid != null) {
                      await context.read<CheckResultViewModel>().addResult(
                            userId: uid, skor: skor);
                      // Refresh stream setelah simpan
                      context.read<CheckResultViewModel>().listenResults(uid);
                    }
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Hasil berhasil disimpan!'),
                          backgroundColor: Color(0xFF3B9EFF)),
                    );
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (r) => false,
                    );
                  }),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legendRow(Color dot, String range, String label, Color labelColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(width: 14, height: 14,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle)),
          const SizedBox(width: 12),
          Expanded(child: Text(range,
              style: const TextStyle(fontSize: 14, color: Color(0xFF333333)))),
          Text(label,
              style: TextStyle(fontSize: 14, color: labelColor, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _adviceCard(IconData icon, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFDDDDDD)),
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
                color: const Color(0xFF3B9EFF).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: const Color(0xFF3B9EFF), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text,
              style: const TextStyle(fontSize: 13, color: Color(0xFF444444), height: 1.5))),
        ],
      ),
    );
  }

  Widget _actionBtn(String label, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        decoration: BoxDecoration(
            color: const Color(0xFF3B9EFF), borderRadius: BorderRadius.circular(30)),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
      ),
    );
  }
}
