import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../id_date.dart';
import '../models/check_record.dart';
import '../services/history_store.dart';
import '../theme.dart';
import '../widgets/risk_badge.dart';
import 'history_detail_screen.dart';

enum _Filter { all, high, low }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({
    super.key,
    required this.store,
    required this.onNewCheck,
  });

  final HistoryStore store;
  final Future<void> Function(ImageSource source) onNewCheck;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<CheckRecord> _records = const [];
  _Filter _filter = _Filter.all;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final records = await widget.store.all();
    if (mounted) {
      setState(() {
        _records = records;
        _loading = false;
      });
    }
  }

  List<CheckRecord> get _visible => switch (_filter) {
        _Filter.all => _records,
        _Filter.high => _records.where((r) => r.isHighRisk).toList(),
        _Filter.low => _records.where((r) => !r.isHighRisk).toList(),
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _backCircle(context),
        leadingWidth: 64,
        title: const Text('Riwayat'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
              ? _empty(context)
              : _list(context),
    );
  }

  Widget _backCircle(BuildContext context) {
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

  Widget _empty(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Tokens.card,
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Icon(Icons.add, color: Tokens.primary, size: 30),
            ),
            const SizedBox(height: 24),
            Text('Belum ada pemeriksaan',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            Text(
              'Setiap hasil pemeriksaan otomatis tersimpan di sini, jadi kamu '
              'bisa memantau perubahan lesi dari waktu ke waktu.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: () async {
                Navigator.of(context).pop();
                await widget.onNewCheck(ImageSource.camera);
              },
              icon: const Icon(Icons.photo_camera_outlined, size: 19),
              label: const Text('Mulai pemeriksaan pertama'),
            ),
            const SizedBox(height: 14),
            const _StoredLocallyNote(),
          ],
        ),
      ),
    );
  }

  Widget _list(BuildContext context) {
    final high = _records.where((r) => r.isHighRisk).length;
    final groups = _groupByMonth(_visible);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        _summary(high),
        const SizedBox(height: Tokens.gap),
        _filters(),
        const SizedBox(height: 20),
        for (final entry in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(entry.key,
                style: Theme.of(context).textTheme.labelLarge),
          ),
          for (final record in entry.value) ...[
            _tile(record),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 10),
        ],
        if (_visible.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Text(
              'Tidak ada pemeriksaan pada filter ini.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        const SizedBox(height: 20),
        const _StoredLocallyNote(),
      ],
    );
  }

  Map<String, List<CheckRecord>> _groupByMonth(List<CheckRecord> records) {
    final groups = <String, List<CheckRecord>>{};
    for (final record in records) {
      groups.putIfAbsent(IdDate.monthYear(record.takenAt), () => []).add(record);
    }
    return groups;
  }

  Widget _summary(int high) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Tokens.ink,
        borderRadius: BorderRadius.circular(Tokens.radiusLarge),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${_records.length}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        height: 1.1)),
                const SizedBox(height: 4),
                const Text('pemeriksaan tersimpan',
                    style: TextStyle(color: Tokens.muted, fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _legend(Tokens.dangerTrack, '$high risiko tinggi'),
              const SizedBox(height: 8),
              _legend(Tokens.mint, '${_records.length - high} risiko rendah'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(
                color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _filters() {
    return Row(
      children: [
        _chip('Semua', _Filter.all),
        const SizedBox(width: 10),
        _chip('Risiko tinggi', _Filter.high),
        const SizedBox(width: 10),
        _chip('Risiko rendah', _Filter.low),
      ],
    );
  }

  Widget _chip(String label, _Filter value) {
    final selected = _filter == value;
    return Expanded(
      child: Material(
        color: selected ? Tokens.ink : Tokens.card,
        shape: StadiumBorder(
          side: BorderSide(color: selected ? Tokens.ink : Tokens.hairline),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: () => setState(() => _filter = value),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 13),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? Colors.white : Tokens.ink,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _tile(CheckRecord record) {
    return Material(
      color: Tokens.card,
      borderRadius: BorderRadius.circular(Tokens.radiusCard),
      child: InkWell(
        borderRadius: BorderRadius.circular(Tokens.radiusCard),
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => HistoryDetailScreen(
                record: record,
                store: widget.store,
                onNewCheck: widget.onNewCheck,
              ),
            ),
          );
          await _load();
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
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
                    Text(IdDate.dayDate(record.takenAt),
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 3),
                    Text(
                      '${IdDate.time(record.takenAt)} · skor ${record.percent}%',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              RiskBadge(high: record.isHighRisk, compact: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoredLocallyNote extends StatelessWidget {
  const _StoredLocallyNote();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.phone_android, size: 15, color: Tokens.muted),
        SizedBox(width: 8),
        Text('Tersimpan hanya di HP ini',
            style: TextStyle(color: Tokens.muted, fontSize: 13)),
      ],
    );
  }
}
