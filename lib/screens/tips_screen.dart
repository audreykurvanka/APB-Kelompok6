import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tips = [
      {
        'icon': Icons.air,
        'title': 'Latihan Pernapasan Diafragma',
        'desc': 'Tarik napas dalam melalui hidung selama 4 detik, tahan 2 detik, lalu hembuskan perlahan melalui mulut selama 6 detik.',
        'color': const Color(0xFF3B9EFF),
      },
      {
        'icon': Icons.water_drop_outlined,
        'title': 'Jaga Kelembapan Udara',
        'desc': 'Pastikan kelembapan ruangan antara 40–60%. Udara terlalu kering dapat mengiritasi saluran pernapasan.',
        'color': const Color(0xFF26C6DA),
      },
      {
        'icon': Icons.smoke_free,
        'title': 'Hindari Paparan Asap',
        'desc': 'Hindari rokok, asap kendaraan, dan polusi udara. Gunakan masker saat berada di lingkungan berpolusi tinggi.',
        'color': const Color(0xFF66BB6A),
      },
      {
        'icon': Icons.self_improvement,
        'title': 'Olahraga Ringan Rutin',
        'desc': 'Jalan kaki atau berenang 30 menit sehari dapat meningkatkan kapasitas paru-paru secara signifikan.',
        'color': const Color(0xFFFFB300),
      },
      {
        'icon': Icons.local_hospital_outlined,
        'title': 'Periksa Rutin ke Dokter',
        'desc': 'Lakukan pemeriksaan kesehatan respirasi setidaknya 6 bulan sekali, terutama jika memiliki riwayat asma atau ISPA.',
        'color': const Color(0xFFE53935),
      },
      {
        'icon': Icons.bedtime_outlined,
        'title': 'Tidur Cukup & Berkualitas',
        'desc': 'Tidur 7–8 jam setiap malam membantu sistem pernapasan beristirahat dan memulihkan diri dari paparan polutan harian.',
        'color': const Color(0xFF7E57C2),
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Tips Kesehatan',
          style: TextStyle(color: Color(0xFF1A1A2E), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: tips.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final tip = tips[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEEEEEE)),
              boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (tip['color'] as Color).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(tip['icon'] as IconData,
                      color: tip['color'] as Color, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tip['title'] as String,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14, color: Color(0xFF1A1A2E))),
                      const SizedBox(height: 6),
                      Text(tip['desc'] as String,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF666666), height: 1.5)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildNav(context),
    );
  }

  Widget _buildNav(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.08), blurRadius: 12,
            offset: const Offset(0, -3))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(context, Icons.home_rounded, 0, 2),
          _navItem(context, Icons.calendar_month_outlined, 1, 2),
          _navItem(context, Icons.lightbulb_outline, 2, 2),
          _navItem(context, Icons.person_outline, 3, 2),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, IconData icon, int index, int current) {
    final isActive = index == current;
    return GestureDetector(
      onTap: () {
        if (index == 0) {
          Navigator.pushAndRemoveUntil(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()), (r) => false);
        } else if (index == 1) {
          Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
        } else if (index == 3) {
          Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        }
      },
      child: Container(
        width: 56, height: 56,
        decoration: isActive
            ? const BoxDecoration(color: Color(0xFF3B9EFF), shape: BoxShape.circle)
            : null,
        child: Icon(icon,
            color: isActive ? Colors.white : const Color(0xFF9E9E9E), size: 26),
      ),
    );
  }
}
