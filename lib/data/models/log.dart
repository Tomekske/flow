class Log {
  final int id;
  final DateTime timestamp;

  Log({required this.id, required this.timestamp});

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
      };

  factory Log.fromJson(Map<String, dynamic> json) => Log(
        id: json['id'],
        timestamp: DateTime.parse(json['timestamp']),
      );
}
