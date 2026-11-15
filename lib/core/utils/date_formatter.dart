/// Centralized date formatting utilities for TTMM.
class DateFormatter {
  DateFormatter._();

  static const List<String> monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  /// Formats a [DateTime] as "15 Nov 2026".
  static String formatDisplayDate(DateTime dt) {
    final month = monthNames[(dt.month - 1).clamp(0, 11)];
    return '${dt.day} $month ${dt.year}';
  }

  /// Formats ISO date string into human-readable date & time.
  static String formatExpenseDateTime(String dateStr) {
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return dateStr;

    final now = DateTime.now();
    final isToday = dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final isYesterday = dt.year == now.year &&
        dt.month == now.month &&
        dt.day == now.subtract(const Duration(days: 1)).day;

    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    final timeStr = '$hour:$minute $amPm';

    if (isToday) return 'Today, $timeStr';
    if (isYesterday) return 'Yesterday, $timeStr';

    final month = monthNames[(dt.month - 1).clamp(0, 11)];
    return '${dt.day} $month, $timeStr';
  }

  /// Formats date subtitle for story headers (e.g. "3 members · Nov 15 – 18").
  static String formatStoryDateSubtitle(int memberCount, String? startDate, String? endDate) {
    final memberSuffix = memberCount == 1 ? '1 member' : '$memberCount members';
    if (startDate == null || endDate == null || startDate.isEmpty || endDate.isEmpty) {
      return memberSuffix;
    }

    final start = DateTime.tryParse(startDate);
    final end = DateTime.tryParse(endDate);
    if (start == null || end == null) return memberSuffix;

    final startMonth = monthNames[(start.month - 1).clamp(0, 11)];
    final endMonth = monthNames[(end.month - 1).clamp(0, 11)];

    if (startMonth == endMonth) {
      if (start.day == end.day) {
        return '$memberSuffix · $startMonth ${start.day}';
      }
      return '$memberSuffix · $startMonth ${start.day} – ${end.day}';
    }
    return '$memberSuffix · $startMonth ${start.day} – $endMonth ${end.day}';
  }
}
