import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/check_result_viewmodel.dart';
import 'preparation_screen.dart';
import 'history_screen.dart';
import 'tips_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthViewModel>().user?.uid;
      if (uid != null) {
        context.read<CheckResultViewModel>().listenResults(uid);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uid = context.read<AuthViewModel>().user?.uid;
    if (uid != null) {
      context.read<CheckResultViewModel>().listenResults(uid);
    }
  }

  void _navigate(int index) {
    switch (index) {
      case 1:
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
        break;
      case 2:
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const TipsScreen()));
        break;
      case 3:
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final resultVm = context.watch<CheckResultViewModel>();
    final nama = authVm.user?.nama ?? 'Pengguna';
    final latest = resultVm.latestResult;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.menu, size: 28, color: Color(0xFF1A1A2E)),
                    Row(
                      children: [
                        // Notif placeholder
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F5FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.notifications_outlined,
                              color: Color(0xFF3B9EFF), size: 20),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () async {
                            await context.read<AuthViewModel>().signOut();
                            if (!mounted) return;
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginScreen()),
                              (r) => false,
                            );
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF0F0),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.logout,
                                color: Colors.red, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Greeting
                Text(
                  'Halo, $nama 👋',
                  style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E)),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Bagaimana kondisi Anda hari ini?',
                  style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
                ),
                const SizedBox(height: 16),

                // Status card
                _StatusCard(latest: latest),
                const SizedBox(height: 16),

                // Quick access
                _QuickAccessRow(
                  onMicTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PreparationScreen()),
                  ),
                ),
                const SizedBox(height: 24),

                // Chart header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Grafik Skor Severity',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E)),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HistoryScreen()),
                      ),
                      child: const Text(
                        'Lihat semua',
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF3B9EFF),
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _SeverityChart(results: resultVm.results),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _BottomNavBar(currentIndex: 0, onTap: _navigate),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final dynamic latest;
  const _StatusCard({this.latest});

  @override
  Widget build(BuildContext context) {
    final statusText = latest?.status ?? 'Belum ada data';
    final tanggal = latest != null
        ? 'Terakhir cek ${latest.tanggalFormatted}'
        : 'Mulai pemeriksaan pertama Anda';

    Color startColor = const Color(0xFF5BB8FF);
    Color endColor = const Color(0xFF2176D9);
    if (latest != null) {
      if (latest.skor >= 60) {
        startColor = const Color(0xFFEF5350);
        endColor = const Color(0xFFB71C1C);
      } else if (latest.skor >= 30) {
        startColor = const Color(0xFFFFD54F);
        endColor = const Color(0xFFFF8F00);
      }
    }

    return Container(
      width: double.infinity,
      height: 110,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [startColor, endColor],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(statusText,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(tanggal,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.85), fontSize: 12)),
              ],
            ),
            const Spacer(),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                latest == null
                    ? Icons.sentiment_neutral_outlined
                    : latest.skor < 30
                        ? Icons.sentiment_satisfied_outlined
                        : latest.skor < 60
                            ? Icons.sentiment_dissatisfied_outlined
                            : Icons.sentiment_very_dissatisfied_outlined,
                color: Colors.white,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAccessRow extends StatelessWidget {
  final VoidCallback onMicTap;
  const _QuickAccessRow({required this.onMicTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onMicTap,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEEEEEE)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                          colors: [Color(0xFFB3D9FF), Color(0xFF3B9EFF)],
                          radius: 0.8),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xFF3B9EFF).withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 2)
                      ],
                    ),
                    child: const Icon(Icons.mic, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 10),
                  const Text('Klik untuk Tes Suara Anda',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Color(0xFF555555))),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            height: 120,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEEEEEE)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Layanan\nKesehatan\nRespirasi Terdekat',
                    style: TextStyle(
                        fontSize: 12, color: Color(0xFF333333), height: 1.4)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                      color: const Color(0xFF3B9EFF),
                      borderRadius: BorderRadius.circular(20)),
                  child: const Text('Cek Sekarang',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SeverityChart extends StatelessWidget {
  final List<dynamic> results;
  const _SeverityChart({required this.results});

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F9FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEEEEEE)),
        ),
        child: const Text('Belum ada data untuk ditampilkan',
            style: TextStyle(color: Color(0xFF888888))),
      );
    }

    final data = results.take(7).toList().reversed.toList();
    final spots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), (e.value.skor as int).toDouble()))
        .toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: LineChart(LineChartData(
        minY: 0,
        maxY: 100,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: Color(0xFFEEEEEE), strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 25,
              reservedSize: 30,
              getTitlesWidget: (v, _) => Text(v.toInt().toString(),
                  style:
                      const TextStyle(fontSize: 9, color: Color(0xFF888888))),
            ),
          ),
          bottomTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFF3B9EFF),
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: const Color(0xFF3B9EFF),
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF3B9EFF).withOpacity(0.2),
                  const Color(0xFF3B9EFF).withOpacity(0),
                ],
              ),
            ),
          ),
        ],
      )),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -3))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_rounded, 0, currentIndex, onTap),
          _navItem(Icons.calendar_month_outlined, 1, currentIndex, onTap),
          _navItem(Icons.lightbulb_outline, 2, currentIndex, onTap),
          _navItem(Icons.person_outline, 3, currentIndex, onTap),
        ],
      ),
    );
  }

  Widget _navItem(
      IconData icon, int index, int current, ValueChanged<int> onTap) {
    final isActive = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        width: 56,
        height: 56,
        decoration: isActive
            ? const BoxDecoration(
                color: Color(0xFF3B9EFF), shape: BoxShape.circle)
            : null,
        child: Icon(icon,
            color: isActive ? Colors.white : const Color(0xFF9E9E9E), size: 26),
      ),
    );
  }
}
