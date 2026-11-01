import 'dart:io';

import 'package:flutter/material.dart';

import '../theme.dart';

/// Foto dengan bingkai putus-putus yang menandai area tengah yang benar-benar
/// dilihat model, supaya pengguna paham bagian mana yang dinilai.
class AnalyzedPhoto extends StatelessWidget {
  const AnalyzedPhoto({
    super.key,
    required this.image,
    this.height = 260,
    this.showLabel = true,
  });

  final File image;
  final double height;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(Tokens.radiusLarge),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(image, fit: BoxFit.cover),
            CustomPaint(painter: _DashedSquarePainter()),
            if (showLabel)
              Positioned(
                left: 12,
                bottom: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Tokens.ink.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Area tengah yang dianalisis',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DashedSquarePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide * 0.76;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: side,
      height: side,
    );
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(14)));

    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    const dash = 7.0;
    const gap = 6.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dash),
          paint,
        );
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
