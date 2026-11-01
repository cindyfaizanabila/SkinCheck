import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../classifier.dart';
import '../id_date.dart';
import '../models/check_record.dart';
import '../services/history_store.dart';
import '../theme.dart';
import '../widgets/risk_badge.dart';
import 'abcde_screen.dart';
import 'analyzing_screen.dart';
import 'history_screen.dart';
import 'photo_tips_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _picker = ImagePicker();

  Classifier? _classifier;
  HistoryStore? _store;
  String? _loadError;
  CheckRecord? _latest;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  @override
  void dispose() {
    _classifier?.close();
    super.dispose();
  }

  Future<void> _boot() async {
    // Dipisah per tahap supaya pesan gagalnya menunjuk penyebab yang benar,
    // bukan menyalahkan model untuk kegagalan penyimpanan.
    final HistoryStore store;
    try {
      store = await HistoryStore.open();
    } catch (e, stack) {
      debugPrint('HistoryStore.open gagal: $e\n$stack');
      if (mounted) setState(() => _loadError = 'Penyimpanan riwayat gagal: $e');
      return;
    }

    // Pada peluncuran pertama setelah pemasangan, build debug masih
    // mengekstrak aset saat aplikasi start, sehingga model bisa belum terbaca.
    // Sekali coba ulang biasanya cukup.
    final Classifier classifier;
    try {
      classifier = await _loadClassifierWithRetry();
    } catch (e, stack) {
      debugPrint('Classifier.load gagal: $e\n$stack');
      if (mounted) setState(() => _loadError = 'Model gagal dimuat: $e');
      return;
    }

    final records = await store.all();
    if (!mounted) return;
    setState(() {
      _store = store;
      _classifier = classifier;
      _latest = records.isEmpty ? null : records.first;
    });
  }

  Future<Classifier> _loadClassifierWithRetry() async {
    try {
      return await Classifier.load();
    } catch (e) {
      debugPrint('Classifier.load gagal, mencoba sekali lagi: $e');
      await Future<void>.delayed(const Duration(milliseconds: 600));
      return Classifier.load();
    }
  }

  Future<void> _retry() {
    setState(() => _loadError = null);
    return _boot();
  }

  Future<void> _refreshLatest() async {
    final records = await _store?.all();
    if (mounted && records != null) {
      setState(() => _latest = records.isEmpty ? null : records.first);
    }
  }

  Future<void> _start(ImageSource source) async {
    final classifier = _classifier;
    final store = _store;
    if (classifier == null || store == null) return;

    final picked = await _picker.pickImage(source: source, imageQuality: 100);
    if (picked == null || !mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AnalyzingScreen(
          image: File(picked.path),
          classifier: classifier,
          store: store,
        ),
      ),
    );
    await _refreshLatest();
  }

  void _open(Widget screen) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => screen))
        .then((_) => _refreshLatest());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            _header(),
            const SizedBox(height: 22),
            Text.rich(
              const TextSpan(
                children: [
                  TextSpan(text: 'Skrining kulit,\n'),
                  TextSpan(
                    text: 'langsung di HP-mu.',
                    style: TextStyle(color: Tokens.primary),
                  ),
                ],
              ),
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 20),
            _heroCard(),
            const SizedBox(height: Tokens.gap),
            Row(
              children: [
                Expanded(
                  child: _shortcut(
                    icon: Icons.center_focus_weak_rounded,
                    title: 'Tips foto',
                    subtitle: 'Agar hasil lebih akurat',
                    onTap: () => _open(PhotoTipsScreen(onPick: _start)),
                  ),
                ),
                const SizedBox(width: Tokens.gap),
                Expanded(
                  child: _shortcut(
                    badges: true,
                    title: 'Aturan ABCDE',
                    subtitle: 'Kenali tanda bahaya',
                    onTap: () => _open(const AbcdeScreen()),
                  ),
                ),
              ],
            ),
            if (_latest != null) ...[
              const SizedBox(height: Tokens.gap),
              _latestCard(_latest!),
            ],
            const SizedBox(height: 28),
            const Text(
              'Bukan alat diagnosis. Hasil tidak menggantikan pemeriksaan '
              'dokter kulit.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Tokens.muted, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Tokens.ink,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.circle_outlined, color: Tokens.mint, size: 18),
        ),
        const SizedBox(width: 10),
        const Text(
          'SkinCheck',
          style: TextStyle(
              fontSize: 19, fontWeight: FontWeight.w800, color: Tokens.ink),
        ),
        const Spacer(),
        _circleButton(
          Icons.history_rounded,
          'Riwayat',
          () => _open(HistoryScreen(store: _store!, onNewCheck: _start)),
        ),
        const SizedBox(width: 8),
        _circleButton(
          Icons.info_outline_rounded,
          'Tentang',
          () => _open(const AbcdeScreen()),
        ),
      ],
    );
  }

  Widget _circleButton(IconData icon, String tooltip, VoidCallback onTap) {
    return Material(
      color: Tokens.card,
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon, size: 20, color: Tokens.ink),
        onPressed: _store == null ? null : onTap,
      ),
    );
  }

  Widget _heroCard() {
    final ready = _classifier != null && _loadError == null;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Tokens.ink,
        borderRadius: BorderRadius.circular(Tokens.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Tokens.inkSoft,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                      color: Tokens.mint, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(
                  ready ? 'AI berjalan offline' : 'Menyiapkan model...',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 56),
          const Text(
            'Periksa lesi kulit',
            style: TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Foto tahi lalat atau bercak, lalu lihat perkiraan tingkat '
            'risikonya dalam hitungan detik.',
            style: TextStyle(color: Tokens.muted, fontSize: 14, height: 1.5),
          ),
          if (_loadError != null) ...[
            const SizedBox(height: 12),
            SelectableText(
              _loadError!,
              style: const TextStyle(color: Tokens.dangerTrack, fontSize: 12),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Tokens.mint,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                onPressed: _retry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Coba lagi'),
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Tokens.ink,
                    minimumSize: const Size.fromHeight(52),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: ready ? () => _start(ImageSource.camera) : null,
                  icon: const Icon(Icons.photo_camera_outlined, size: 19),
                  label: const Text('Ambil foto'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.transparent,
                    side: const BorderSide(color: Tokens.inkLine),
                    minimumSize: const Size.fromHeight(52),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: ready ? () => _start(ImageSource.gallery) : null,
                  icon: const Icon(Icons.image_outlined, size: 19),
                  label: const Text('Galeri'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _shortcut({
    IconData? icon,
    bool badges = false,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Tokens.card,
      borderRadius: BorderRadius.circular(Tokens.radiusCard),
      child: InkWell(
        borderRadius: BorderRadius.circular(Tokens.radiusCard),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 36,
                child: badges
                    ? const Row(
                        children: [
                          _MiniBadge('A'),
                          SizedBox(width: 5),
                          _MiniBadge('B'),
                          SizedBox(width: 5),
                          _MiniBadge('+3', soft: true),
                        ],
                      )
                    : Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Tokens.mintSoft,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: Icon(icon, size: 19, color: Tokens.primary),
                      ),
              ),
              const SizedBox(height: 14),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 3),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }

  Widget _latestCard(CheckRecord record) {
    return Material(
      color: Tokens.card,
      borderRadius: BorderRadius.circular(Tokens.radiusCard),
      child: InkWell(
        borderRadius: BorderRadius.circular(Tokens.radiusCard),
        onTap: () => _open(HistoryScreen(store: _store!, onNewCheck: _start)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Text('Pemeriksaan terakhir',
                      style: Theme.of(context).textTheme.labelLarge),
                  const Spacer(),
                  const Text(
                    'Lihat riwayat',
                    style: TextStyle(
                        color: Tokens.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(
                      File(record.imagePath),
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      cacheWidth: 160,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(IdDate.dayDateYear(record.takenAt),
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 2),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge(this.text, {this.soft = false});

  final String text;
  final bool soft;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: soft ? Tokens.mintSoft : Tokens.ink,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        text,
        style: TextStyle(
            color: soft ? Tokens.primary : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700),
      ),
    );
  }
}
