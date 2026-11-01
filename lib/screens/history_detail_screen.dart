import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../classifier.dart';
import '../id_date.dart';
import '../models/check_record.dart';
import '../services/history_store.dart';
import '../theme.dart';
import '../widgets/crop_overlay.dart';
import '../widgets/risk_badge.dart';
import '../widgets/score_ring.dart';

class HistoryDetailScreen extends StatelessWidget {
  const HistoryDetailScreen({
    super.key,
    required this.record,
    required this.store,
    required this.onNewCheck,
  });

  final CheckRecord record;
  final HistoryStore store;
  final Future<void> Function(ImageSource source) onNewCheck;

  @override
  Widget build(BuildContext context) {
    final threshold = (Classifier.highRiskThreshold * 100).round();

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Material(
            color: Tokens.card,
            shape: const CircleBorder(),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, size: 20, color: Tokens.ink),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        leadingWidth: 64,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(IdDate.dayDateYear(record.takenAt)),
            Text(
              'Pukul ${IdDate.time(record.takenAt)}',
              style: const TextStyle(
                  fontSize: 13, color: Tokens.muted, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          AnalyzedPhoto(
            image: File(record.imagePath),
            height: 300,
            showLabel: false,
          ),
          const SizedBox(height: Tokens.gap),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  ScoreRing(score: record.score, showCaption: false),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RiskBadge(high: record.isHighRisk),
                        const SizedBox(height: 12),
                        Text(
                          record.isHighRisk
                              ? 'Disarankan periksa ke dokter kulit. '
                                  'Ambang risiko tinggi $threshold%.'
                              : 'Tetap pantau lesi ini. '
                                  'Ambang risiko tinggi $threshold%.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Tokens.gap),
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _row(context, 'Skor indikasi keganasan',
                      record.score.toStringAsFixed(2).replaceAll('.', ',')),
                  const Divider(height: 1, color: Tokens.hairline),
                  _row(context, 'Model', Classifier.modelName),
                  const Divider(height: 1, color: Tokens.hairline),
                  _row(context, 'Waktu analisis', '${record.inferenceMs} ms'),
                ],
              ),
            ),
          ),
          const SizedBox(height: Tokens.gap),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Tokens.mintSoft,
              borderRadius: BorderRadius.circular(Tokens.radiusCard),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.refresh_rounded,
                    color: Tokens.primary, size: 20),
                const SizedBox(width: 14),
                Expanded(
                  child: Text.rich(
                    const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Foto ulang lesi yang sama beberapa minggu '
                              'lagi, lalu bandingkan. Perubahan bentuk atau '
                              'warna adalah tanda ',
                        ),
                        TextSpan(
                          text: 'E (Evolving)',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(text: '.'),
                      ],
                    ),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Tokens.ink),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: () async {
              Navigator.of(context).pop();
              await onNewCheck(ImageSource.camera);
            },
            icon: const Icon(Icons.photo_camera_outlined, size: 19),
            label: const Text('Foto ulang lesi ini'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Tokens.danger,
              side: const BorderSide(color: Tokens.dangerTrack),
            ),
            onPressed: () => _confirmDelete(context),
            icon: const Icon(Icons.delete_outline, size: 19),
            label: const Text('Hapus pemeriksaan ini'),
          ),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: 15)),
          ),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Tokens.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Tokens.hairline,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(record.imagePath),
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      cacheWidth: 170,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hapus pemeriksaan ini?',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text(
                          '${IdDate.shortDate(record.takenAt)} · '
                          '${IdDate.time(record.takenAt)} · '
                          'skor ${record.percent}%',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Foto dan hasilnya akan dihapus permanen dari HP ini dan '
                'tidak bisa dikembalikan.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(sheetContext).pop(false),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Tokens.danger,
                        minimumSize: const Size.fromHeight(56),
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () => Navigator.of(sheetContext).pop(true),
                      child: const Text('Hapus'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true) return;
    await store.remove(record);
    if (context.mounted) Navigator.of(context).pop();
  }
}
