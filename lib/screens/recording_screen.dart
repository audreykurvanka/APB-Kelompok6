import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'analyzing_screen.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen>
    with TickerProviderStateMixin {
  bool _isRecording = false;
  double _progress = 0.0;
  Timer? _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late List<double> _waveHeights;
  Timer? _waveTimer;

  @override
  void initState() {
    super.initState();
    _waveHeights = List.generate(30, (i) => 0.15 + Random().nextDouble() * 0.3);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _waveTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleRecording() {
    if (_isRecording) {
      _timer?.cancel();
      _waveTimer?.cancel();
      setState(() => _isRecording = false);
    } else {
      setState(() {
        _isRecording = true;
        _progress = 0.0;
      });

      // Animasi gelombang berubah acak saat recording
      _waveTimer = Timer.periodic(const Duration(milliseconds: 150), (_) {
        if (!mounted) return;
        setState(() {
          _waveHeights = List.generate(
              30, (i) => 0.1 + Random().nextDouble() * 0.9);
        });
      });

      // Progress bar ~8 detik penuh
      _timer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
        setState(() {
          _progress += 0.01;
          if (_progress >= 1.0) {
            _progress = 1.0;
            _isRecording = false;
            timer.cancel();
            _waveTimer?.cancel();
            Future.delayed(const Duration(milliseconds: 300), () {
              if (mounted) {
                // Generate skor random di sini, kirim ke analyzing screen
                final skor = Random().nextInt(91) + 10;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AnalyzingScreen(skor: skor),
                  ),
                );
              }
            });
          }
        });
      });
    }
  }

  void _resetRecording() {
    _timer?.cancel();
    _waveTimer?.cancel();
    setState(() {
      _isRecording = false;
      _progress = 0.0;
      _waveHeights = List.generate(30, (i) => 0.15 + Random().nextDouble() * 0.3);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header biru
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF5BB8FF), Color(0xFF3B9EFF)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.chevron_left, color: Colors.white, size: 32),
                        ),
                        // Progress bar
                        Container(
                          width: 120,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _progress < 0.01 ? 0.05 : _progress,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const Icon(Icons.volume_up_outlined, color: Colors.white, size: 26),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Perekaman Fonetik',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Ucapkan huruf vokal sesuai panduan',
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Terus ucapkan huruf "A" hingga\nindikator yang mengelilingi tombol\nmikrofon terisi penuh.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white, fontSize: 15,
                        fontWeight: FontWeight.bold, height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),

          // Body
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isRecording
                        ? const Text(
                            'Mendengarkan...',
                            key: ValueKey('listening'),
                            style: TextStyle(
                              color: Color(0xFF3B9EFF),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : _progress >= 1.0
                            ? const Text(
                                'Rekaman selesai!',
                                key: ValueKey('done'),
                                style: TextStyle(
                                  color: Color(0xFF3B9EFF),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : const SizedBox(key: ValueKey('empty'), height: 28),
                  ),
                  _buildWaveform(),
                  _buildMicButton(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildBottomButton('Ulangi', onTap: _resetRecording),
                        _buildBottomButton(
                          'Lanjut',
                          onTap: _progress >= 1.0
                              ? () {
                                  final skor = Random().nextInt(91) + 10;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AnalyzingScreen(skor: skor),
                                    ),
                                  );
                                }
                              : null,
                          enabled: _progress >= 1.0,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveform() {
    return SizedBox(
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(_waveHeights.length, (index) {
          final isPlayed = _isRecording && (index / _waveHeights.length) < _progress;
          final isCursor = _isRecording &&
              ((index / _waveHeights.length) - _progress).abs() < 0.04;

          Color barColor;
          if (isCursor) {
            barColor = const Color(0xFFE53935);
          } else if (isPlayed) {
            barColor = const Color(0xFF3B9EFF).withOpacity(0.8);
          } else {
            barColor = const Color(0xFF3B9EFF).withOpacity(0.3);
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: isCursor ? 2.5 : 3,
              height: _waveHeights[index] * 70,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMicButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final scale = _isRecording ? _pulseAnimation.value : 1.0;
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: _toggleRecording,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CustomPaint(
                    painter: _ProgressRingPainter(progress: _progress, isRecording: _isRecording),
                  ),
                ),
                Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF3B9EFF).withOpacity(0.15),
                  ),
                ),
                Container(
                  width: 88, height: 88,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Color(0x333B9EFF), blurRadius: 16, spreadRadius: 4)],
                  ),
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    color: _isRecording ? const Color(0xFFE53935) : const Color(0xFF3B9EFF),
                    size: 40,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomButton(String label, {VoidCallback? onTap, bool enabled = true}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFF3B9EFF) : const Color(0xFF3B9EFF).withOpacity(0.35),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final bool isRecording;
  _ProgressRingPainter({required this.progress, required this.isRecording});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    final bgPaint = Paint()
      ..color = const Color(0xFF3B9EFF).withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, bgPaint);

    if (progress > 0) {
      final progPaint = Paint()
        ..shader = const SweepGradient(
          startAngle: -pi / 2,
          endAngle: 3 * pi / 2,
          colors: [Color(0xFF3B9EFF), Color(0xFF5BB8FF)],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress,
        false,
        progPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressRingPainter old) =>
      old.progress != progress || old.isRecording != isRecording;
}
