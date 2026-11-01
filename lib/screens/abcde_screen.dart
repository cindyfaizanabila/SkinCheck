import 'package:flutter/material.dart';

import '../classifier.dart';
import '../theme.dart';

class AbcdeScreen extends StatelessWidget {
  const AbcdeScreen({super.key});

  static const _rules = [
    ('A', 'Asymmetry · Asimetri', 'Dua sisi lesi tidak sama bentuknya'),
    ('B', 'Border · Tepi', 'Tepi bergerigi, tidak rata, atau kabur'),
    ('C', 'Color · Warna',
        'Warna tidak seragam: cokelat, hitam, merah, atau biru'),
    ('D', 'Diameter', 'Lebih besar dari 6 mm, kira-kira ujung pensil'),
    ('E', 'Evolving · Berubah',
        'Ukuran, bentuk, atau warna berubah dari waktu ke waktu'),
  ];

  @override
  Widget build(BuildContext context) {
    final threshold = (Classifier.highRiskThreshold * 100).round();

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 64,
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
        title: const Text('Kenali tanda bahaya'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Text.rich(
            const TextSpan(
              children: [
                TextSpan(text: 'Aturan '),
                TextSpan(
                  text: 'ABCDE',
                  style: TextStyle(fontWeight: FontWeight.w700, color: Tokens.ink),
                ),
                TextSpan(
                  text: ' dipakai dokter kulit untuk mengenali lesi yang perlu '
                      'diperiksa lebih lanjut.',
                ),
              ],
            ),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          for (final (letter, title, body) in _rules) ...[
            _ruleCard(context, letter, title, body),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 10),
          _urgentCard(context),
          const SizedBox(height: Tokens.gap),
          _aboutCard(context, threshold),
        ],
      ),
    );
  }

  Widget _ruleCard(
      BuildContext context, String letter, String title, String body) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Tokens.ink,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Text(letter,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 3),
                  Text(body, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _urgentCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Tokens.ink,
        borderRadius: BorderRadius.circular(Tokens.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Segera ke dokter jika',
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          for (final text in const [
            'Lesi berdarah, gatal, atau bernanah tanpa sebab',
            'Muncul lesi baru yang tampak berbeda dari lainnya',
            'Luka yang tidak kunjung sembuh',
          ])
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 7),
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                        color: Tokens.mint, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(text,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14, height: 1.45)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _aboutCard(BuildContext context, int threshold) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tentang aplikasi',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 14),
            _spec(context, 'Model', Classifier.modelName),
            _spec(context, 'Data latih', 'ISIC (dermoskopi)'),
            _spec(context, 'Recall lesi ganas (uji)', '94,3%'),
            _spec(context, 'Ambang risiko tinggi', '$threshold%'),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFDF1E3),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'Keterbatasan: model dilatih dengan foto dermoskopi, bukan '
                'kamera HP. Akurasi pada foto biasa bisa lebih rendah.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _spec(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}
