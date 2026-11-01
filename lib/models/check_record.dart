import '../classifier.dart';

/// Satu pemeriksaan yang tersimpan di perangkat.
class CheckRecord {
  const CheckRecord({
    required this.id,
    required this.imagePath,
    required this.score,
    required this.takenAt,
    required this.inferenceMs,
  });

  final String id;
  final String imagePath;
  final double score;
  final DateTime takenAt;
  final int inferenceMs;

  bool get isHighRisk => score >= Classifier.highRiskThreshold;

  /// Skor dalam persen bulat, seperti yang tampil di kartu riwayat.
  int get percent => (score * 100).round();

  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': imagePath,
        'score': score,
        'takenAt': takenAt.toIso8601String(),
        'inferenceMs': inferenceMs,
      };

  factory CheckRecord.fromJson(Map<String, dynamic> json) => CheckRecord(
        id: json['id'] as String,
        imagePath: json['imagePath'] as String,
        score: (json['score'] as num).toDouble(),
        takenAt: DateTime.parse(json['takenAt'] as String),
        inferenceMs: json['inferenceMs'] as int? ?? 0,
      );
}
