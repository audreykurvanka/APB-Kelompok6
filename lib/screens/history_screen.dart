import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/check_result_viewmodel.dart';
import '../models/check_result_model.dart';
import 'home_screen.dart';
import 'tips_screen.dart';
import 'profile_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final resultVm = context.watch<CheckResultViewModel>();
    final history = resultVm.results;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Riwayat Pemeriksaan',
            style: TextStyle(color: Color(0xFF1A1A2E), fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_month_outlined,
                      size: 60, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('Belum ada riwayat pemeriksaan',
                      style: TextStyle(color: Color(0xFF888888), fontSize: 14)),
                  const SizedBox(height: 8),
                  const Text('Lakukan pemeriksaan pertama Anda',
                      style: TextStyle(color: Color(0xFFBBBBBB), fontSize: 12)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = history[index];
                final color = item.skor < 30
                    ? const Color(0xFF3B9EFF)
                    : item.skor < 60
                        ? const Color(0xFFFFB300)
                        : const Color(0xFFE53935);

                return Dismissible(
                  key: Key(item.id ?? index.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: const Text('Hapus Riwayat'),
                        content: const Text('Yakin ingin menghapus data ini?'),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Batal')),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Hapus',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (_) {
                    if (item.id != null) {
                      context.read<CheckResultViewModel>().deleteResult(item.id!);
                    }
                  },
                  child: _HistoryCard(item: item, color: color),
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
          _navItem(context, Icons.home_rounded, 0, 1),
          _navItem(context, Icons.calendar_month_outlined, 1, 1),
          _navItem(context, Icons.lightbulb_outline, 2, 1),
          _navItem(context, Icons.person_outline, 3, 1),
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
        } else if (index == 2) {
          Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const TipsScreen()));
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

class _HistoryCard extends StatelessWidget {
  final CheckResult item;
  final Color color;
  const _HistoryCard({required this.item, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [BoxShadow(
            color: Colors.black.withOpacity(0.04), blurRadius: 6,
            offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
            child: Center(
              child: Text('${item.skor}',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.tanggalFormatted,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                const SizedBox(height: 4),
                Text(item.status,
                    style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFFCCCCCC), size: 22),
        ],
      ),
    );
  }
}
