class DateTimeService {
  /// "just now", "25 min ago", "3 h ago", "2 days ago".
  static String timeAgo(DateTime? time, {DateTime? now}) {
    if (time == null) return 'unknown';
    final diff = (now ?? DateTime.now()).difference(time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    return diff.inDays == 1 ? '1 day ago' : '${diff.inDays} days ago';
  }
}
