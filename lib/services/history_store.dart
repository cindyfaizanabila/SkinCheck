import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/check_record.dart';

/// Riwayat disimpan sebagai berkas JSON plus salinan foto di direktori
/// dokumen aplikasi. Tidak ada yang meninggalkan perangkat.
class HistoryStore {
  HistoryStore._(this._indexFile, this._imageDir);

  final File _indexFile;
  final Directory _imageDir;

  List<CheckRecord>? _cache;

  static Future<HistoryStore> open() async {
    final docs = await getApplicationDocumentsDirectory();
    final imageDir = Directory('${docs.path}/checks');
    if (!imageDir.existsSync()) await imageDir.create(recursive: true);
    return HistoryStore._(File('${docs.path}/history.json'), imageDir);
  }

  /// Terbaru lebih dulu.
  Future<List<CheckRecord>> all() async {
    if (_cache != null) return _cache!;
    if (!_indexFile.existsSync()) return _cache = const [];
    try {
      final raw = jsonDecode(await _indexFile.readAsString()) as List<dynamic>;
      final records = raw
          .map((e) => CheckRecord.fromJson(e as Map<String, dynamic>))
          .where((r) => File(r.imagePath).existsSync())
          .toList()
        ..sort((a, b) => b.takenAt.compareTo(a.takenAt));
      return _cache = records;
    } on FormatException {
      // Berkas rusak lebih baik diabaikan daripada membuat aplikasi gagal start.
      return _cache = const [];
    }
  }

  Future<CheckRecord> add({
    required File image,
    required double score,
    required int inferenceMs,
  }) async {
    final now = DateTime.now();
    final id = now.microsecondsSinceEpoch.toString();
    final stored = await image.copy('${_imageDir.path}/$id.jpg');

    final record = CheckRecord(
      id: id,
      imagePath: stored.path,
      score: score,
      takenAt: now,
      inferenceMs: inferenceMs,
    );
    _cache = [record, ...await all()];
    await _flush();
    return record;
  }

  Future<void> remove(CheckRecord record) async {
    _cache = (await all()).where((r) => r.id != record.id).toList();
    final file = File(record.imagePath);
    if (file.existsSync()) await file.delete();
    await _flush();
  }

  Future<void> _flush() async {
    final data = (_cache ?? const <CheckRecord>[]).map((r) => r.toJson()).toList();
    await _indexFile.writeAsString(jsonEncode(data));
  }
}
