/// Format tanggal Bahasa Indonesia tanpa paket intl, supaya aplikasi tetap
/// bebas dependensi tambahan dan tidak perlu memuat data lokal saat start.
abstract class IdDate {
  static const _days = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
  ];
  static const _monthsShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];
  static const _monthsLong = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  static String day(DateTime d) => _days[d.weekday - 1];

  /// "Sabtu, 1 Nov"
  static String dayDate(DateTime d) =>
      '${day(d)}, ${d.day} ${_monthsShort[d.month - 1]}';

  /// "Sabtu, 1 Nov 2026"
  static String dayDateYear(DateTime d) => '${dayDate(d)} ${d.year}';

  /// "1 Nov 2026"
  static String shortDate(DateTime d) =>
      '${d.day} ${_monthsShort[d.month - 1]} ${d.year}';

  /// "November 2026"
  static String monthYear(DateTime d) =>
      '${_monthsLong[d.month - 1]} ${d.year}';

  /// "09.12"
  static String time(DateTime d) =>
      '${d.hour.toString().padLeft(2, '0')}.${d.minute.toString().padLeft(2, '0')}';
}
