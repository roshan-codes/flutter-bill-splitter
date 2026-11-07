/// String helper utilities.
class StringUtils {
  StringUtils._();

  /// Extracts up to 2 uppercase initials from a person's name.
  static String getInitials(String name) {
    final parts = name.trim().split(' ').where((e) => e.isNotEmpty);
    if (parts.isEmpty) return '?';
    return parts.map((e) => e[0].toUpperCase()).take(2).join();
  }

  /// Extracts the primary single uppercase initial from a person's name.
  static String getSingleInitial(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed[0].toUpperCase();
  }
}

