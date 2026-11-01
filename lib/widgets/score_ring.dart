import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../classifier.dart';
import '../theme.dart';

/// Cincin skor dengan garis hitam kecil sebagai penanda ambang 17%.
class ScoreRing extends StatelessWidget {
  const ScoreRing({
    super.key,
    required this.score,
    this.size = 128,
    this.showCaption = true,
  });

  final double score;
  final double size;
  final bool showCaption;

  @override
  Widget build(BuildContext context) {
    final high = score >= Classifier.highRiskThreshold;
    final color = high ? Tokens.danger : Tokens.primary;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          value: score.clamp(0.0, 1.0),
          color: color,
          track: high ? Tokens.dangerSoft : Tokens.mintSoft,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(score * 100).round()}%',
                style: TextStyle(
                  fontSize: size * 0.26,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              if (showCaption)
                Text('skor',
                    style: TextStyle(
                        fontSize: size * 0.1, color: Tokens.muted)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.value, required this.color, required this.track});

  final double value;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.1;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.width - stroke) / 2;
    const start = -math.pi / 2;

    final base = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawCircle(center, radius, base);

    final arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      2 * math.pi * value,
      false,
      arc,
    );

    // Penanda ambang.
    final angle = start + 2 * math.pi * Classifier.highRiskThreshold;
    final inner = radius - stroke * 0.9;
    final outer = radius + stroke * 0.9;
    canvas.drawLine(
      center + Offset(math.cos(angle) * inner, math.sin(angle) * inner),
      center + Offset(math.cos(angle) * outer, math.sin(angle) * outer),
      Paint()
        ..color = Tokens.ink
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color;
}
