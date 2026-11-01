import 'dart:io';

import 'package:flutter/material.dart';

import '../classifier.dart';
import '../models/check_record.dart';
import '../theme.dart';
import '../widgets/crop_overlay.dart';
import '../widgets/risk_badge.dart';
import '../widgets/score_ring.dart';
import 'abcde_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.record});

  final CheckRecord record;

  @override
  Widget build(BuildContext context) {
    final high = record.isHighRisk;
    final threshold = (Classifier.highRiskThreshold * 100).round();

    return Scaffold(
      appBar: AppBar(
        leading: const _BackCircle(),
        title: const Text('Hasil analisis'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: _SavedChip(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          AnalyzedPhoto(image: File(record.imagePath)),
          const SizedBox(height: Tokens.gap),
          _scoreCard(context, high, threshold),
          const SizedBox(height: Tokens.gap),
          if (high) ..._highRiskSections(context) else ..._lowRiskSections(context),
          const SizedBox(height: Tokens.gap),
          _metaRow(context),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.photo_camera_outlined, size: 19),
            label: const Text('Periksa foto lain'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AbcdeScreen()),
            ),
            child: const Text('Pelajari tanda ABCDE'),
          ),
          const SizedBox(height: 20),
          Text(
            high
                ? 'Model AI dapat salah, terutama pada foto kamera HP biasa. '
                    'Pemeriksaan dokter tetap diperlukan.'
                : 'Bukan diagnosis medis. Jika ragu, konsultasikan ke dokter.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Tokens.muted, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _scoreCard(BuildContext context, bool high, int threshold) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ScoreRing(score: record.score, size: 112),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RiskBadge(high: high),
                      const SizedBox(height: 14),
                      Text(
                        high
                            ? 'Disarankan periksa ke dokter kulit'
                            : 'Tetap pantau lesi ini secara berkala',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Skor di ${high ? 'atas' : 'bawah'} ambang $threshold% '
                        '(garis hitam)',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Cara membaca skor',
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            _scale(threshold),
          ],
        ),
      ),
    );
  }

  /// Garis skala yang menunjukkan porsi rendah dan tinggi dari rentang skor.
  Widget _scale(int threshold) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Row(
            children: [
              Expanded(
                flex: threshold,
                child: Container(height: 7, color: Tokens.mintSoft),
              ),
              Expanded(
                flex: 100 - threshold,
                child: Container(height: 7, color: Tokens.dangerTrack),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Text('Rendah',
                style: TextStyle(
                    color: Tokens.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
            const SizedBox(width: 10),
            Text('Tinggi ($threshold–100%)',
                style: const TextStyle(
                    color: Tokens.danger,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  List<Widget> _highRiskSections(BuildContext context) => [
        _section(
          context,
          'Apa artinya?',
          child: Text.rich(
            const TextSpan(
              children: [
                TextSpan(
                  text: 'Ciri visual lesi ini mirip lesi ganas pada data latih '
                      'model. Ini ',
                ),
                TextSpan(
                  text: 'bukan diagnosis',
                  style: TextStyle(fontWeight: FontWeight.w700, color: Tokens.ink),
                ),
                TextSpan(
                  text: '. Hanya dokter yang dapat memastikan, biasanya lewat '
                      'dermoskopi atau biopsi.',
                ),
              ],
            ),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: Tokens.gap),
        _section(
          context,
          'Langkah berikutnya',
          child: Column(
            children: const [
              _NumberedStep(1, 'Buat janji dengan dokter spesialis kulit (Sp.DVE)'),
              _NumberedStep(2, 'Catat sejak kapan lesi muncul atau mulai berubah'),
              _NumberedStep(3, 'Jangan digaruk, dikorek, atau diobati sendiri'),
            ],
          ),
        ),
      ];

  List<Widget> _lowRiskSections(BuildContext context) => [
        _section(
          context,
          'Tetap waspada jika',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Bullet('Ukuran, bentuk, atau warnanya berubah'),
              const _Bullet('Terasa gatal, nyeri, atau berdarah'),
              const _Bullet('Tampak berbeda dari tahi lalat lainnya'),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Tokens.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  'Risiko rendah bukan berarti pasti jinak. Pada data uji, '
                  'model masih melewatkan 17 dari 300 lesi ganas.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ];

  Widget _section(BuildContext context, String title, {required Widget child}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _metaRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _metaBox(context, 'Waktu analisis', '${record.inferenceMs} ms'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _metaBox(context, 'Diproses di', 'HP ini (offline)'),
        ),
      ],
    );
  }

  Widget _metaBox(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Tokens.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Tokens.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _BackCircle extends StatelessWidget {
  const _BackCircle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12),
      child: Material(
        color: Tokens.card,
        shape: const CircleBorder(),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20, color: Tokens.ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}

class _SavedChip extends StatelessWidget {
  const _SavedChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Tokens.mintSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check, size: 15, color: Tokens.primary),
          SizedBox(width: 5),
          Text('Tersimpan',
              style: TextStyle(
                  color: Tokens.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _NumberedStep extends StatelessWidget {
  const _NumberedStep(this.number, this.text);

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Tokens.ink,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text('$number',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 7),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
                color: Tokens.primary, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
