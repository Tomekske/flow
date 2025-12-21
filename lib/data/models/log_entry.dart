abstract class LogEntry {
  final int id;
  final DateTime createdAt;

  const LogEntry({
    required this.id,
    required this.createdAt
  });
}