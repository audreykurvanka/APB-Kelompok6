import 'dart:math';
import 'package:flutter/material.dart';
import 'result_screen.dart';

class AnalyzingScreen extends StatefulWidget {
  final int skor;
  const AnalyzingScreen({super.key, required this.skor});

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _rotate;
  int _step = 0;

  final List<String> _steps = [
    'Memproses rekaman suara...',
    'Menganalisis frekuensi fonetik...',
    'Menghitung skor risiko...',
    'Menyiapkan hasil...',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat();
    _rotate = Tween<double>(begin: 0, end: 2 * pi).animate(_ctrl);

    // Ganti step teks setiap 700ms
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return false;
      setState(() {
        if (_step < _steps.length - 1) _step++;
      });
      return _step < _steps.length - 1;
    });

    // Navigasi ke hasil setelah ~3 detik
    Future.delayed(const Duration(milliseconds: 3200), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(skor: widget.skor)),
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF5BB8FF), Color(0xFF2176D9)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Spinner animasi
            AnimatedBuilder(
              animation: _rotate,
              builder: (_, __) => Transform.rotate(
                angle: _rotate.value,
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 4),
                  ),
                  child: const Icon(Icons.graphic_eq, color: Colors.white, size: 50),
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Menganalisis Suara',
              style: TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Text(
                _steps[_step],
                key: ValueKey(_step),
                style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 15),
              ),
            ),
            const SizedBox(height: 40),
            // Progress dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _step == i ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _step >= i ? Colors.white : Colors.white.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(4),
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }
}
