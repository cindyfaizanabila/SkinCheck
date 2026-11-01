import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme.dart';

class PhotoTipsScreen extends StatelessWidget {
  const PhotoTipsScreen({super.key, required this.onPick});

  final Future<void> Function(ImageSource source) onPick;

  static const _tips = [
    ('01', 'Lesi di tengah foto', 'Aplikasi menganalisis area tengah saja'),
    ('02', 'Cahaya terang dan merata', 'Hindari bayangan dan pantulan flash'),
    ('03', 'Dekat dan fokus tajam', 'Jarak sekitar 10 cm dari kulit'),
    ('04', 'Satu lesi per foto', 'Foto ulang untuk lesi lainnya'),
  ];

  @override
  Widget build(BuildContext context) {
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
        title: const Text('Tips foto'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _example(context, good: true)),
              const SizedBox(width: 12),
              Expanded(child: _example(context, good: false)),
            ],
          ),
          const SizedBox(height: 20),
          for (final (number, title, body) in _tips) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(number,
                        style: const TextStyle(
                            color: Tokens.primary,
                            fontSize: 19,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 3),
                          Text(body,
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await onPick(ImageSource.camera);
                  },
                  icon: const Icon(Icons.photo_camera_outlined, size: 19),
                  label: const Text('Ambil foto'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await onPick(ImageSource.gallery);
                  },
                  icon: const Icon(Icons.image_outlined, size: 19),
                  label: const Text('Galeri'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Dua contoh skematis: lesi di tengah dan terfokus, versus lesi di pinggir
  /// dengan foto buram.
  Widget _example(BuildContext context, {required bool good}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.25,
              child: Container(
                decoration: BoxDecoration(
                  color: good ? const Color(0xFFE9C9AD) : const Color(0xFF7A6A5C),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Align(
                  alignment: good ? Alignment.center : const Alignment(0.75, 0.6),
                  child: Container(
                    width: good ? 34 : 18,
                    height: good ? 26 : 16,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A2E1F),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  good ? Icons.check_circle : Icons.cancel,
                  size: 17,
                  color: good ? Tokens.primary : Tokens.danger,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    good ? 'Seperti ini' : 'Hindari',
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: good ? Tokens.primary : Tokens.danger,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
