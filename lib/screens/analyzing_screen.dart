import 'dart:io';

import 'package:flutter/material.dart';

import '../classifier.dart';
import '../services/history_store.dart';
import '../theme.dart';
import 'result_screen.dart';

/// Layar gelap selama inferensi berjalan, menampilkan tahap yang sedang
/// dikerjakan supaya tunggu terasa jelas, bukan sekadar spinner.
class AnalyzingScreen extends StatefulWidget {
  const AnalyzingScreen({
    super.key,
    required this.image,
    required this.classifier,
    required this.store,
  });

  final File image;
  final Classifier classifier;
  final HistoryStore store;

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  int _stage = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _run();
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    try {
      final bytes = await widget.image.readAsBytes();
      final input = await Classifier.preprocess(bytes);
      if (!mounted) return;
      setState(() => _stage = 1);

      // Beri satu frame supaya tahap pertama sempat terlihat tercentang.
      await Future<void>.delayed(const Duration(milliseconds: 220));
      final diagnosis = widget.classifier.infer(input);
      if (!mounted) return;
      setState(() => _stage = 2);

      final record = await widget.store.add(
        image: widget.image,
        score: diagnosis.score,
        inferenceMs: diagnosis.inferenceMs,
      );
      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ResultScreen(record: record)),
      );
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Tokens.ink,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _dial(),
              const SizedBox(height: 36),
              const Text(
                'Menganalisis foto',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              const Text(
                'Biasanya kurang dari 2 detik. Semua diproses di HP ini.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Tokens.muted, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 32),
              _step(0, 'Menyiapkan gambar', 'Crop & resize 224 px'),
              const SizedBox(height: 10),
              _step(1, 'Menjalankan model', Classifier.modelName),
              const SizedBox(height: 10),
              _step(2, 'Menyusun hasil', ''),
              if (_error != null) ...[
                const SizedBox(height: 24),
                Text(
                  'Gagal menganalisis: $_error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Tokens.dangerTrack, fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Kembali',
                      style: TextStyle(color: Tokens.mint)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _dial() {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipOval(
            child: SizedBox(
              width: 184,
              height: 184,
              child: Image.file(widget.image, fit: BoxFit.cover),
            ),
          ),
          RotationTransition(
            turns: _spin,
            child: SizedBox(
              width: 212,
              height: 212,
              child: CircularProgressIndicator(
                strokeWidth: 5,
                value: 0.26,
                color: Tokens.mint,
                backgroundColor: Tokens.inkSoft,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _step(int index, String title, String note) {
    final done = _stage > index;
    final active = _stage == index;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: active || done ? Tokens.inkSoft : Tokens.ink,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: active || done ? Tokens.inkSoft : Tokens.inkLine,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: done
                ? Container(
                    decoration: const BoxDecoration(
                        color: Tokens.mint, shape: BoxShape.circle),
                    child: const Icon(Icons.check, size: 15, color: Tokens.ink),
                  )
                : active
                    ? const CircularProgressIndicator(
                        strokeWidth: 2.5, color: Tokens.mint)
                    : Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Tokens.inkLine, width: 2),
                        ),
                      ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: done || active ? Colors.white : Tokens.muted,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          if (note.isNotEmpty)
            Text(
              note,
              style: TextStyle(
                color: active ? Tokens.mint : Tokens.muted,
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }
}
