import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/check_result_viewmodel.dart';
import '../models/user_model.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'tips_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _editMode = false;
  late TextEditingController _namaCtrl;
  late TextEditingController _tglCtrl;
  late TextEditingController _tinggiCtrl;
  late TextEditingController _beratCtrl;
  late TextEditingController _goldarCtrl;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthViewModel>().user;
    _namaCtrl = TextEditingController(text: user?.nama ?? '');
    _tglCtrl = TextEditingController(text: user?.tanggalLahir ?? '');
    _tinggiCtrl = TextEditingController(text: user?.tinggiBadan ?? '');
    _beratCtrl = TextEditingController(text: user?.beratBadan ?? '');
    _goldarCtrl = TextEditingController(text: user?.golonganDarah ?? '');
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _tglCtrl.dispose();
    _tinggiCtrl.dispose();
    _beratCtrl.dispose();
    _goldarCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final vm = context.read<AuthViewModel>();
    final user = vm.user!;
    final updated = UserModel(
      uid: user.uid,
      nama: _namaCtrl.text.trim(),
      email: user.email,
      tanggalLahir: _tglCtrl.text.trim(),
      tinggiBadan: _tinggiCtrl.text.trim(),
      beratBadan: _beratCtrl.text.trim(),
      golonganDarah: _goldarCtrl.text.trim(),
    );
    await vm.updateProfile(updated);
    if (!mounted) return;
    setState(() => _editMode = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil berhasil diperbarui'), backgroundColor: Color(0xFF3B9EFF)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final resultVm = context.watch<CheckResultViewModel>();
    final user = authVm.user;
    final results = resultVm.results;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.chevron_left, color: Color(0xFF1A1A2E), size: 32),
        ),
        title: const Text('Profil Saya',
            style: TextStyle(color: Color(0xFF1A1A2E), fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              if (_editMode) {
                _saveProfile();
              } else {
                setState(() => _editMode = true);
              }
            },
            child: Text(
              _editMode ? 'Simpan' : 'Edit',
              style: const TextStyle(color: Color(0xFF3B9EFF), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF5BB8FF), Color(0xFF2176D9)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.25),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.person, color: Colors.white, size: 44),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.nama ?? '-',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Edit/view data kesehatan
            _sectionTitle('Data Profil dan Kesehatan'),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFEEEEEE)),
              ),
              child: Column(
                children: [
                  _editMode
                      ? _editRow('Nama', _namaCtrl, Icons.person_outline)
                      : _infoRow(Icons.person_outline, 'Nama', user?.nama ?? '-'),
                  _editMode
                      ? _editRow('Tanggal Lahir', _tglCtrl, Icons.cake_outlined)
                      : _infoRow(Icons.cake_outlined, 'Tanggal Lahir', user?.tanggalLahir.isNotEmpty == true ? user!.tanggalLahir : '-'),
                  _editMode
                      ? _editRow('Tinggi Badan (cm)', _tinggiCtrl, Icons.height)
                      : _infoRow(Icons.height, 'Tinggi Badan', user?.tinggiBadan.isNotEmpty == true ? '${user!.tinggiBadan} cm' : '-'),
                  _editMode
                      ? _editRow('Berat Badan (kg)', _beratCtrl, Icons.monitor_weight_outlined)
                      : _infoRow(Icons.monitor_weight_outlined, 'Berat Badan', user?.beratBadan.isNotEmpty == true ? '${user!.beratBadan} kg' : '-'),
                  _editMode
                      ? _editRow('Golongan Darah', _goldarCtrl, Icons.bloodtype_outlined)
                      : _infoRow(Icons.bloodtype_outlined, 'Golongan Darah', user?.golonganDarah.isNotEmpty == true ? user!.golonganDarah : '-'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Stats dari Firestore
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F9FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFDDEEFF)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statItem('Total Tes', '${results.length}'),
                  Container(width: 1, height: 40, color: const Color(0xFFDDDDDD)),
                  _statItem('Rata-rata Skor',
                      results.isEmpty ? '-' : (results.map((r) => r.skor).reduce((a, b) => a + b) ~/ results.length).toString()),
                  Container(width: 1, height: 40, color: const Color(0xFFDDDDDD)),
                  _statItem('Status Terkini', results.isNotEmpty ? results.first.status : '-'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await context.read<AuthViewModel>().signOut();
                  if (!mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (r) => false,
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Keluar Akun', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: _buildNav(context),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF3B9EFF), size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF555555))),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
        ],
      ),
    );
  }

  Widget _editRow(String label, TextEditingController ctrl, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF3B9EFF), size: 20),
          isDense: true,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF3B9EFF), width: 2),
          ),
        ),
        style: const TextStyle(fontSize: 13),
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3B9EFF))),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF888888))),
      ],
    );
  }

  Widget _buildNav(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -3))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(context, Icons.home_rounded, 0, 3),
          _navItem(context, Icons.calendar_month_outlined, 1, 3),
          _navItem(context, Icons.lightbulb_outline, 2, 3),
          _navItem(context, Icons.person_outline, 3, 3),
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
        } else if (index == 2) {
          Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const TipsScreen()));
        }
      },
      child: Container(
        width: 56, height: 56,
        decoration: isActive ? const BoxDecoration(color: Color(0xFF3B9EFF), shape: BoxShape.circle) : null,
        child: Icon(icon, color: isActive ? Colors.white : const Color(0xFF9E9E9E), size: 26),
      ),
    );
  }
}
