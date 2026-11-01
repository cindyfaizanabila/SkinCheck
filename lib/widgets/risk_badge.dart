import 'package:flutter/material.dart';

import '../theme.dart';

class RiskBadge extends StatelessWidget {
  const RiskBadge({super.key, required this.high, this.compact = false});

  final bool high;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final bg = high ? Tokens.danger : Tokens.mintSoft;
    final fg = high ? Colors.white : Tokens.primary;
    final text = compact
        ? (high ? 'Tinggi' : 'Rendah')
        : (high ? 'Risiko tinggi' : 'Risiko rendah');

    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 12, vertical: 7),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!compact) ...[
            Icon(high ? Icons.warning_amber_rounded : Icons.check,
                size: 15, color: fg),
            const SizedBox(width: 5),
          ],
          // Flexible menjaga badge tetap utuh saat pengguna membesarkan
          // ukuran font sistem.
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: fg, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
