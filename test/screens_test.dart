import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skin_check/classifier.dart';
import 'package:skin_check/id_date.dart';
import 'package:skin_check/models/check_record.dart';
import 'package:skin_check/screens/abcde_screen.dart';
import 'package:skin_check/screens/photo_tips_screen.dart';
import 'package:skin_check/screens/result_screen.dart';
import 'package:skin_check/theme.dart';

CheckRecord _record(double score) => CheckRecord(
      id: '1',
      imagePath: 'nonexistent.jpg',
      score: score,
      takenAt: DateTime(2026, 11, 1, 9, 12),
      inferenceMs: 84,
    );

/// Ukuran layar vivo 1938, perangkat yang dipakai menguji.
Future<void> _pump(WidgetTester tester, Widget screen) async {
  tester.view.physicalSize = const Size(720, 1544);
  tester.view.devicePixelRatio = 2.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp(theme: buildTheme(), home: screen));
  await tester.pump();
}

/// ListView hanya membangun anak yang terlihat, jadi isi bagian bawah layar
/// harus digulir dulu sebelum bisa dicari.
Future<void> _scrollTo(WidgetTester tester, Finder target) async {
  await tester.scrollUntilVisible(
    target,
    300,
    scrollable: find.byType(Scrollable).first,
  );
}

void main() {
  testWidgets('hasil risiko tinggi menampilkan ambang dan langkah lanjutan',
      (tester) async {
    await _pump(tester, ResultScreen(record: _record(0.72)));

    expect(find.text('Risiko tinggi'), findsOneWidget);
    expect(find.text('72%'), findsOneWidget);
    expect(find.text('Skor di atas ambang 17% (garis hitam)'), findsOneWidget);
    await _scrollTo(tester, find.text('Langkah berikutnya'));
    expect(find.text('Langkah berikutnya'), findsOneWidget);
    await _scrollTo(tester, find.text('84 ms'));
    expect(find.text('84 ms'), findsOneWidget);
  });

  testWidgets('hasil risiko rendah memakai teks pantau berkala',
      (tester) async {
    await _pump(tester, ResultScreen(record: _record(0.06)));

    expect(find.text('Risiko rendah'), findsOneWidget);
    expect(find.text('6%'), findsOneWidget);
    expect(find.text('Skor di bawah ambang 17% (garis hitam)'), findsOneWidget);
    await _scrollTo(tester, find.text('Tetap waspada jika'));
    expect(find.text('Tetap waspada jika'), findsOneWidget);
  });

  testWidgets('skor tepat di ambang dihitung sebagai risiko tinggi',
      (tester) async {
    await _pump(tester, ResultScreen(record: _record(0.17)));
    expect(find.text('Risiko tinggi'), findsOneWidget);
  });

  testWidgets('layar ABCDE memuat lima aturan dan spesifikasi model',
      (tester) async {
    await _pump(tester, const AbcdeScreen());

    for (final letter in ['A', 'B', 'C', 'D', 'E']) {
      expect(find.text(letter), findsOneWidget);
    }
    await _scrollTo(tester, find.text('MobileNetV2'));
    expect(find.text('MobileNetV2'), findsOneWidget);
    expect(find.text('17%'), findsOneWidget);
  });

  testWidgets('layar tips foto memuat empat poin', (tester) async {
    await _pump(tester, PhotoTipsScreen(onPick: (_) async {}));

    for (final number in ['01', '02', '03', '04']) {
      expect(find.text(number), findsOneWidget);
    }
  });

  test('ambang risiko mengikuti spesifikasi design', () {
    expect(Classifier.highRiskThreshold, 0.17);
    expect(_record(0.17).isHighRisk, isTrue);
    expect(_record(0.169).isHighRisk, isFalse);
  });

  test('tanggal diformat dalam Bahasa Indonesia', () {
    final date = DateTime(2026, 11, 1, 9, 12);
    expect(IdDate.dayDateYear(date), 'Minggu, 1 Nov 2026');
    expect(IdDate.monthYear(date), 'November 2026');
    expect(IdDate.time(date), '09.12');
  });
}
