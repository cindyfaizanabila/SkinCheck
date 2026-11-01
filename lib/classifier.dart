import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Masukan model yang sudah siap pakai: [1, 224, 224, 3].
typedef ModelInput = List<List<List<List<double>>>>;

class Diagnosis {
  const Diagnosis({required this.score, required this.inferenceMs});

  /// Keluaran sigmoid model: indikasi keganasan, 0 sampai 1.
  final double score;
  final int inferenceMs;

  bool get isHighRisk => score >= Classifier.highRiskThreshold;
  int get percent => (score * 100).round();
}

class Classifier {
  Classifier._(this._interpreter);

  static const modelAsset = 'assets/skin_cancer.tflite';
  static const inputSize = 224;
  static const modelName = 'MobileNetV2';

  /// Ambang risiko tinggi dari spesifikasi design, bukan 0,5 bawaan sigmoid.
  /// Sengaja rendah supaya lesi ganas jarang terlewat, dengan konsekuensi
  /// lebih banyak peringatan palsu.
  static const highRiskThreshold = 0.17;

  final Interpreter _interpreter;

  static Future<Classifier> load() async {
    final interpreter = await Interpreter.fromAsset(
      modelAsset,
      options: InterpreterOptions()..threads = 4,
    );
    return Classifier._(interpreter);
  }

  /// Tahap 1. Berjalan di isolate terpisah agar UI tetap mulus.
  static Future<ModelInput> preprocess(Uint8List bytes) =>
      compute(_preprocess, bytes);

  /// Tahap 2. Sinkron dan cepat, sekalian mencatat durasinya.
  Diagnosis infer(ModelInput input) {
    final output = [List<double>.filled(1, 0)];
    final watch = Stopwatch()..start();
    _interpreter.run(input, output);
    watch.stop();
    return Diagnosis(
      score: output[0][0],
      inferenceMs: watch.elapsedMilliseconds,
    );
  }

  void close() => _interpreter.close();
}

/// Potong bagian tengah menjadi bujur sangkar, lalu skalakan ke 224 piksel.
///
/// Crop tengah ini yang digambarkan garis putus-putus di layar hasil: model
/// hanya melihat area itu. Tanpa crop, foto 3:4 akan digepengkan dan bentuk
/// lesi berubah dari bentuk yang dipelajari model.
///
/// Piksel dikirim mentah 0-255. Graf model sudah memuat layer
/// Rescaling(1/127,5, -1) di depan backbone, jadi normalisasi di sini akan
/// membuat masukan dinormalisasi dua kali.
ModelInput _preprocess(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw const FormatException('Berkas gambar tidak dapat dibaca.');
  }
  final oriented = img.bakeOrientation(decoded);

  final side = math.min(oriented.width, oriented.height);
  final square = img.copyCrop(
    oriented,
    x: (oriented.width - side) ~/ 2,
    y: (oriented.height - side) ~/ 2,
    width: side,
    height: side,
  );
  final resized = img.copyResize(
    square,
    width: Classifier.inputSize,
    height: Classifier.inputSize,
    interpolation: img.Interpolation.linear,
  );

  return [
    List.generate(
      Classifier.inputSize,
      (y) => List.generate(Classifier.inputSize, (x) {
        final p = resized.getPixel(x, y);
        return [p.r.toDouble(), p.g.toDouble(), p.b.toDouble()];
      }),
    ),
  ];
}
